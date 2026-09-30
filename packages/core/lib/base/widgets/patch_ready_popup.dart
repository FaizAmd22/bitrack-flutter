import 'dart:async';
import 'dart:io';

import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/routes/app_routes.dart';
import 'package:bitrack_core/base/routes/navigation_service.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';

/// Sudah tampil di proses app ini atau belum. Top-level, karena "sekali per
/// sesi" berarti sekali per PROSES: pengecekan terjadi lagi setiap app
/// kembali dari background, tapi pilihan "Nanti" user tidak boleh terlupa.
///
/// Sekali saja sudah cukup: patch yang terunduh tetap aktif sendiri begitu
/// app dibuka dari awal, jadi "Nanti" hanya menunda — tidak membatalkan.
bool _shownThisSession = false;

@visibleForTesting
void resetPatchReadyPopupForTest() => _shownThisSession = false;

/// Sesering apa route yang sedang tampil diperiksa selagi menunggu splash.
const _splashPollInterval = Duration(milliseconds: 500);

/// Batas menunggu splash. Kalau app tertahan di splash lebih lama dari ini
/// (mis. gagal memuat data awal), popup dilewatkan saja — patch-nya tetap
/// aktif sendiri saat app dibuka lagi.
const _splashWaitLimit = Duration(seconds: 30);

/// Batas menunggu restart. Kalau berhasil, prosesnya mati sebelum ini —
/// jadi batas ini hanya berlaku saat plugin restart menggantung (pernah
/// terjadi di lingkungan tanpa implementasi native). Tanpa batas, user hanya
/// melihat tombol berputar tanpa akhir.
const _restartTimeout = Duration(seconds: 5);

/// Dipakai `MaterialApp.builder` tiap app lewat [PatchDownloadBanner].
///
/// Menunggu splash lewat dulu: splash pindah ke login/beranda dengan
/// `pushNamedAndRemoveUntil`, dan dialog yang terbuka saat itu ikut tertutup
/// bersama halaman di bawahnya — user tidak sempat melihatnya.
Future<void> showPatchReadyPopupWhenPossible() async {
  var waited = Duration.zero;
  while (NavigationService.currentRouteName == null ||
      NavigationService.currentRouteName == AppRoutes.splashScreen) {
    if (waited >= _splashWaitLimit) return;
    await Future<void>.delayed(_splashPollInterval);
    waited += _splashPollInterval;
  }

  final context = NavigationService.navigatorKey.currentContext;
  if (context == null || !context.mounted) return;
  await maybeShowPatchReadyPopup(context: context);
}

/// Popup "pembaruan siap": patch Shorebird sudah terunduh tapi belum dipakai,
/// maksimal sekali per sesi.
///
/// Tanpa popup ini patch tetap aktif sendiri, tapi baru di pembukaan app
/// berikutnya — dan app yang dibiarkan hidup di background bisa tertahan
/// berhari-hari di kode lama tanpa user tahu ada perbaikan.
///
/// Sengaja SELALU bisa ditutup: ini perbaikan kecil, bukan pembaruan wajib
/// dari store.
Future<void> maybeShowPatchReadyPopup({required BuildContext context}) async {
  if (_shownThisSession || !context.mounted) return;
  _shownThisSession = true;
  await showDialog<void>(
    context: context,
    builder: (context) => const PatchReadyDialog(),
  );
}

/// Isi popupnya. Tampilannya mengikuti [ConfirmDialog], tapi tombolnya
/// berbeda: di iOS tidak ada tombol "Mulai ulang" sama sekali.
class PatchReadyDialog extends StatefulWidget {
  const PatchReadyDialog({super.key, this.canRestart});

  /// Null = ikut platform (restart otomatis hanya di Android). Diisi hanya
  /// oleh tes, karena `Platform.isAndroid` tidak bisa dipalsukan.
  @visibleForTesting
  final bool? canRestart;

  @override
  State<PatchReadyDialog> createState() => _PatchReadyDialogState();
}

class _PatchReadyDialogState extends State<PatchReadyDialog> {
  /// Restart otomatis hanya di Android. Di iOS restart_app cuma membuat ulang
  /// engine Flutter di proses yang sama, sedangkan patch dipilih saat proses
  /// dimulai — jadi user diminta menutup app sendiri.
  late final bool _canRestart = widget.canRestart ?? Platform.isAndroid;

  bool _restarting = false;
  bool _restartFailed = false;

  Future<void> _restart() async {
    setState(() => _restarting = true);
    // RestartMode.process: yang dimulai ulang harus PROSES-nya, bukan cuma
    // activity — patch Shorebird dimuat saat proses mulai.
    String error;
    try {
      final result = await Restart.restartApp(
        mode: RestartMode.process,
      ).timeout(_restartTimeout);
      if (result.success) return;
      error = '${result.code} ${result.message}';
    } catch (e) {
      // Mis. plugin tidak tersedia di platform ini. Gagal restart tidak boleh
      // menjatuhkan dialog: user masih bisa menutup app sendiri.
      error = '$e';
    }
    if (!mounted) return;
    debugPrint('[patchReady] restart gagal: $error');
    setState(() {
      _restarting = false;
      _restartFailed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final showRestart = _canRestart && !_restartFailed;

    return Dialog(
      backgroundColor: AppStyles.whiteColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.patchReadyTitle,
              textAlign: TextAlign.center,
              style: AppStyles.textMdBold,
            ),
            const SizedBox(height: 20),
            Text(
              _canRestart ? t.patchReadyMessage : t.patchReadyMessageManual,
              textAlign: TextAlign.center,
              style: AppStyles.textSm.copyWith(color: AppStyles.textBlackColor),
            ),
            if (_restartFailed) ...[
              const SizedBox(height: 12),
              Text(
                t.patchReadyRestartFailed,
                textAlign: TextAlign.center,
                style: AppStyles.textSm.copyWith(color: AppStyles.redColor),
              ),
            ],
            const SizedBox(height: 24),
            if (showRestart) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _restarting ? null : _restart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryColor,
                    foregroundColor: AppStyles.whiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _restarting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(t.patchReadyRestart),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _restarting
                    ? null
                    : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppStyles.primaryColor,
                  side: BorderSide(color: AppStyles.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  showRestart ? t.patchReadyLater : t.patchReadyClose,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
