import 'dart:async';

import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/services/code_push_service.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Pembungkus akar app (dipasang di `MaterialApp.builder`) yang memicu
/// unduhan patch Shorebird dan menampilkan banner "Mengunduh pembaruan…"
/// selama unduhannya berjalan — di halaman mana pun, termasuk login.
///
/// Kenapa di akar, bukan di beranda: unduhan otomatis Shorebird dimatikan
/// (lihat base/services/code_push_service.dart), jadi app sendiri yang harus
/// memulai unduhan. Kalau pemicunya hanya di beranda, patch yang memperbaiki
/// bug di halaman login tidak akan pernah sampai ke user yang tertahan di
/// sana.
///
/// Dipicu dua kali: saat app pertama tampil, dan setiap kali app kembali dari
/// background — app pemantauan sering dibiarkan terbuka berhari-hari, dan
/// patch yang terbit di tengah itu harus tetap terunduh.
class PatchDownloadBanner extends StatefulWidget {
  const PatchDownloadBanner({
    super.key,
    required this.child,
    required this.onPatchReady,
  });

  final Widget child;

  /// Dipanggil setiap pengecekan selesai dengan patch yang sudah terunduh
  /// tapi belum dipakai — tugas pemanggil menampilkan popup "pembaruan siap".
  /// Banner sendiri tidak bisa membuka dialog: ia duduk DI ATAS Navigator
  /// (di `MaterialApp.builder`), jadi context-nya tidak punya Navigator.
  final Future<void> Function() onPatchReady;

  @override
  State<PatchDownloadBanner> createState() => _PatchDownloadBannerState();
}

class _PatchDownloadBannerState extends State<PatchDownloadBanner> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _check() => unawaited(_checkAndNotify());

  Future<void> _checkAndNotify() async {
    final ready = await downloadPatchIfAvailable();
    if (!ready || !mounted) return;
    await widget.onPatchReady();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          left: 16,
          right: 16,
          // Di atas, bukan di bawah: tombol aksi utama dan player Periodic
          // Track ada di bawah layar, dan banner tidak boleh menutupinya.
          top: MediaQuery.paddingOf(context).top + 8,
          // Hanya informasi — sentuhan tetap diteruskan ke halaman di baliknya.
          child: IgnorePointer(
            child: ValueListenableBuilder<bool>(
              valueListenable: patchDownloadInProgress,
              builder: (context, downloading, _) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: downloading
                    ? const _DownloadingCard()
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DownloadingCard extends StatelessWidget {
  const _DownloadingCard();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          color: AppStyles.whiteColor,
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.system_update_alt,
                      size: 18,
                      color: AppStyles.primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.patchDownloading,
                        style: AppStyles.textSm.copyWith(
                          color: AppStyles.textBlackColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Tanpa persen: updater Shorebird tidak memberi progres unduhan
              // sama sekali, jadi bar-nya indeterminate — menandakan "sedang
              // berjalan", bukan berapa yang tersisa.
              LinearProgressIndicator(
                minHeight: 3,
                color: AppStyles.primaryColor,
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
