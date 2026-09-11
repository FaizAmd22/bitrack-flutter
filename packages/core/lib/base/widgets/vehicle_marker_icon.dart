import 'dart:math' as math;

import 'package:bitrack_core/base/utils/truck_asset.dart';
import 'package:flutter/material.dart';

/// Ikon kendaraan untuk marker di peta.
///
/// Kalau [iconUrl] berisi URL http(s) — kolom `vehicle_category_icon` dari
/// API, terisi saat user memasang ikon custom untuk kategori kendaraannya —
/// gambar itulah yang tampil. Kalau kosong atau bukan URL, tetap aset truk
/// berwarna sesuai aktivitas seperti sebelumnya.
///
/// Dipakai bersama oleh peta home dan peta Vehicle Detail supaya kendaraan
/// yang sama tidak tampil sebagai pesawat di satu layar lalu truk di layar
/// berikutnya.
class VehicleMarkerIcon extends StatelessWidget {
  const VehicleMarkerIcon({
    super.key,
    required this.iconUrl,
    required this.activity,
    required this.bearingDeg,
    this.size = 45,
  });

  final String? iconUrl;
  final String? activity;
  final double bearingDeg;
  final double size;

  /// Hanya URL http/https yang punya host dianggap ikon custom. Nilai lain —
  /// kosong, `"null"`, path relatif — jatuh ke aset truk.
  static bool isCustomIconUrl(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return false;
    final uri = Uri.tryParse(raw);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Aset truk digambar dari atas, jadi memutarnya mengikuti arah memang
    // benar.
    final truck = Transform.rotate(
      angle: bearingDeg * math.pi / 180,
      child: Image.asset(
        resolveTruckAsset(activity),
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );

    if (!isCustomIconUrl(iconUrl)) return truck;

    // Ikon custom sengaja TIDAK diputar. Isinya unggahan user — piktogram
    // tegak, bahkan foto — bukan sprite yang digambar dari atas, sehingga
    // memutarnya ke arah 170° membuatnya tampil terbalik.
    return Image.network(
      iconUrl!.trim(),
      width: size,
      height: size,
      fit: BoxFit.contain,
      // Ikon hanya tampil selebar [size]. Tanpa cacheWidth, PNG unggahan user
      // (bisa ribuan piksel) di-decode dalam resolusi penuh. 3x menutup layar
      // berkepadatan tinggi; marker dengan URL yang sama tetap berbagi satu
      // entri ImageCache.
      cacheWidth: (size * 3).round(),
      // Selama memuat dan saat gagal, tampilkan truk: marker tidak boleh
      // hilang dari peta hanya karena gambarnya lambat atau URL-nya rusak.
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
          frame == null ? truck : child,
      errorBuilder: (context, error, stackTrace) => truck,
    );
  }
}
