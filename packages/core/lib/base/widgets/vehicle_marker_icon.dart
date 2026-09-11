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
    final truck = Image.asset(
      resolveTruckAsset(activity),
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    final Widget icon = isCustomIconUrl(iconUrl)
        ? Image.network(
            iconUrl!.trim(),
            width: size,
            height: size,
            fit: BoxFit.contain,
            // Ikon hanya tampil selebar [size]. Tanpa cacheWidth, PNG
            // unggahan user (bisa ribuan piksel) di-decode dalam resolusi
            // penuh. 3x menutup layar berkepadatan tinggi; marker dengan URL
            // yang sama tetap berbagi satu entri ImageCache.
            cacheWidth: (size * 3).round(),
            // Selama memuat dan saat gagal, tampilkan truk: marker tidak boleh
            // hilang dari peta hanya karena gambarnya lambat atau URL-nya
            // rusak.
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                frame == null ? truck : child,
            errorBuilder: (context, error, stackTrace) => truck,
          )
        : truck;

    // Rotasi dipasang SEKALI di sini, bukan di masing-masing ikon: truk
    // cadangan di frameBuilder/errorBuilder berada di dalam Image.network,
    // jadi kalau truk dan ikon custom diputar sendiri-sendiri, cadangannya
    // ikut terputar dua kali.
    //
    // Ikon custom ikut berputar mengikuti arah, sama seperti truk. Karena itu
    // ikon yang diunggah sebaiknya digambar tampak atas dengan moncong
    // menghadap ke atas (utara); gambar tegak atau foto akan tampil miring.
    return Transform.rotate(angle: bearingDeg * math.pi / 180, child: icon);
  }
}
