import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/services/code_push_service.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Label versi app + nomor patch Shorebird yang sedang berjalan, mis.
/// `v1.2.0 (15) • Patch 3`. Dipasang di halaman login dan profil supaya user
/// (dan laporan bug) bisa menyebut kode mana yang jalan di HP-nya.
///
/// Versi dan build number dibaca dari platform (nilai `version:` di
/// pubspec.yaml app saat di-build), bukan dari kode Dart — jadi patch tidak
/// bisa mengubahnya. Yang membedakan satu patch dari patch lain hanya nomor
/// patch di belakangnya.
///
/// Bagian "Patch" hilang kalau belum ada patch terpasang (masih kode release)
/// atau build tanpa engine Shorebird (`flutter run` biasa).
class AppVersionLabel extends StatelessWidget {
  const AppVersionLabel({super.key, this.color});

  /// Warna teks; default abu-abu [AppStyles.textXs].
  final Color? color;

  /// Satu pembacaan untuk seluruh umur proses: versi tidak berubah selama app
  /// berjalan, dan label ini tampil di lebih dari satu halaman.
  static final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _packageInfo,
      builder: (context, snapshot) {
        final info = snapshot.data;
        // Belum terbaca / gagal dibaca: kosong, bukan teks versi yang salah.
        if (info == null) return const SizedBox.shrink();

        final patch = currentPatchNumber;
        final label = StringBuffer('v${info.version}');
        if (info.buildNumber.isNotEmpty) label.write(' (${info.buildNumber})');
        if (patch != null) label.write(' • Patch $patch');

        return Text(
          label.toString(),
          textAlign: TextAlign.center,
          style: AppStyles.textXs.copyWith(color: color),
        );
      },
    );
  }
}
