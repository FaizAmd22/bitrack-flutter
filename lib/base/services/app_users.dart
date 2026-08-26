import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Padanan `import.meta.env.VITE_APP_USERS` di bitrack-mobile (Cordova).
///
/// Satu basis kode dipakai untuk dua jenis aplikasi: "Customer" dan
/// "Teknisi". Nilai dibaca dari `.env` saat build, jadi menu Work Order &
/// Vehicle hanya tampil pada build Teknisi.
class AppUsers {
  AppUsers._();

  static const technician = 'Teknisi';
  static const customer = 'Customer';

  static String get value => (dotenv.env['VITE_APP_USERS'] ?? '').trim();

  static bool get isTechnicianApp =>
      value.toLowerCase() == technician.toLowerCase();
}
