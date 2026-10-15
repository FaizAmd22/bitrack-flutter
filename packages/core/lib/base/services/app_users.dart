import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Jenis pengguna build ini: "Customer" atau "Teknisi", dari `VITE_APP_USERS`
/// di `.env` (nama variabelnya warisan app Cordova lama).
///
/// Satu basis kode dipakai untuk dua jenis aplikasi. Saat ini Bitrack Internal
/// adalah build Teknisi; FixTrack dan Bitrack adalah build Customer. Tab Work
/// Order dan Vehicle di bottom navigation hanya muncul di build Teknisi
/// ([isTechnicianApp]).
class AppUsers {
  AppUsers._();

  static const technician = 'Teknisi';
  static const customer = 'Customer';

  /// Nilai mentah dari `.env`, sudah di-trim.
  static String get value => (dotenv.env['VITE_APP_USERS'] ?? '').trim();

  /// True untuk build Teknisi (perbandingan tidak peka huruf besar/kecil).
  static bool get isTechnicianApp =>
      value.toLowerCase() == technician.toLowerCase();
}
