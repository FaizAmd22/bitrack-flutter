import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

/// Jembatan tipis ke updater Shorebird (code push).
///
/// Unduhan otomatis bawaan Shorebird SENGAJA dimatikan (`auto_update: false`
/// di `apps/<app>/shorebird.yaml`) dan dijalankan sendiri lewat
/// [downloadPatchIfAvailable]. Dengan auto_update menyala, engine mengunduh
/// patch diam-diam di background dan app tidak pernah tahu kapan unduhan
/// mulai atau selesai — jadi tidak ada cara menampilkan "sedang mengunduh
/// pembaruan" ke user (lihat base/widgets/patch_download_banner.dart).
///
/// Konsekuensinya, [downloadPatchIfAvailable] WAJIB dipicu dari akar app
/// (banner global), bukan dari satu halaman: patch yang memperbaiki bug di
/// halaman login pun harus bisa sampai ke user yang belum bisa login.
///
/// Updater native tidak memberi progres unduhan (persen/byte) sama sekali —
/// yang tersedia hanya cek, unduh-sampai-selesai, dan nomor patch. Jadi yang
/// bisa ditampilkan hanya "sedang berjalan", bukan persentase.
///
/// Di build yang tidak memakai engine Shorebird (`flutter run`, `flutter
/// build` biasa), [ShorebirdUpdater.isAvailable] false dan semua fungsi di
/// sini jadi no-op — bukan error.
final ShorebirdUpdater _updater = ShorebirdUpdater();

int? _currentPatchNumber;

/// Menyala selama patch sedang diunduh, tapi baru sesudah unduhannya berjalan
/// lebih dari [_downloadIndicatorDelay]. Dibaca banner global.
final ValueNotifier<bool> patchDownloadInProgress = ValueNotifier(false);

/// Unduhan patch biasanya selesai < 1 detik (patch hanya berisi selisih kode
/// Dart). Indikator yang muncul-hilang sekejap lebih membingungkan daripada
/// tidak muncul sama sekali, jadi baru ditampilkan kalau memang terasa lama.
const _downloadIndicatorDelay = Duration(seconds: 1);

/// Pengecekan yang sedang berjalan. Banner (saat app dibuka & kembali dari
/// background) bisa memanggil [downloadPatchIfAvailable] hampir bersamaan —
/// semuanya menunggu satu proses yang sama, bukan mengunduh dua kali.
Future<bool>? _inFlight;

/// Membaca nomor patch yang sedang BERJALAN. Dipanggil sekali di main(),
/// sebelum runApp().
///
/// Cukup sekali: kode yang berjalan tidak pernah berganti di tengah proses —
/// patch baru baru dipakai sesudah app dimulai ulang.
Future<void> initCurrentPatch() async {
  if (!_updater.isAvailable) return;
  try {
    _currentPatchNumber = (await _updater.readCurrentPatch())?.number;
  } catch (e) {
    // Bukan alasan menggagalkan startup.
    debugPrint('[codePush] gagal membaca patch terpasang: $e');
  }
}

/// Nomor patch yang sedang berjalan; null = belum ada patch (masih kode
/// release) atau build tanpa Shorebird. Dipakai untuk label versi, supaya
/// laporan bug bisa menyebut kode mana yang sedang jalan di HP user.
int? get currentPatchNumber => _currentPatchNumber;

/// Mengunduh patch baru kalau ada, lalu mengembalikan true kalau ada patch
/// yang SUDAH terunduh tapi belum dipakai — artinya app perlu dimulai ulang.
///
/// Semua kegagalan (offline, patch ditolak karena hash mismatch, dsb.)
/// dianggap "tidak ada yang siap": popup yang muncul lalu restart-nya tidak
/// mengubah apa-apa jauh lebih membingungkan daripada tidak muncul.
Future<bool> downloadPatchIfAvailable() {
  return _inFlight ??= _checkAndDownload().whenComplete(() => _inFlight = null);
}

Future<bool> _checkAndDownload() async {
  if (!_updater.isAvailable) return false;
  Timer? showIndicator;
  try {
    var status = await _updater.checkForUpdate();
    if (status == UpdateStatus.outdated) {
      showIndicator = Timer(
        _downloadIndicatorDelay,
        () => patchDownloadInProgress.value = true,
      );
      await _updater.update();
      status = await _updater.checkForUpdate();
    }
    return status == UpdateStatus.restartRequired;
  } catch (e) {
    debugPrint('[codePush] gagal mengecek/mengunduh patch: $e');
    return false;
  } finally {
    showIndicator?.cancel();
    patchDownloadInProgress.value = false;
  }
}
