import 'package:bitrack_core/base/network/api_client.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mode demo: melewati login asli agar reviewer App Store bisa mencoba
/// seluruh fitur tanpa akun nyata.
///
/// Cara kerjanya:
/// - Tombol "Lanjut dengan demo" di halaman login (muncul bila flag Supabase
///   `show_register` = true) memanggil [activate].
/// - [activate] menyimpan token palsu `DEMO_MODE_TOKEN` dan data user dummy,
///   jadi guard dan halaman lain menganggap user sudah login.
/// - Setiap service API mengecek [isActive] lebih dulu dan mengembalikan data
///   dari `demo_data.dart`, bukan memanggil server.
/// - Logout memanggil [clearOnLogout].
///
/// Dibuat untuk lolos review App Store, bukan fitur publik permanen.
class DemoMode {
  DemoMode._();

  static bool _active = false;
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// True selama user berada di mode demo. Dicek di semua service API.
  static bool get isActive => _active;

  static Future<void> activate() async {
    _active = true;

    await Future.wait([
      _storage.write(key: 'demo_mode_active', value: 'true'),
      _storage.write(key: 'auth_token', value: 'DEMO_MODE_TOKEN'),
      _storage.write(key: 'user_id', value: 'demo-user'),
      _storage.write(key: 'user_name', value: 'Demo User'),
      _storage.write(key: 'user_email', value: 'demo@treffix.id'),
      _storage.write(key: 'user_role', value: 'Administrator'),
      _storage.write(key: 'user_role_permission', value: '[]'),
    ]);

    await ApiClient.setToken('DEMO_MODE_TOKEN');
  }

  /// Dipanggil dari `ApiClient.logout`. Data user lain dihapus di sana.
  static Future<void> clearOnLogout() async {
    _active = false;
    await _storage.delete(key: 'demo_mode_active');
  }

  /// Pulihkan status demo setelah app dibuka ulang. Dipanggil di `main()`.
  static Future<void> loadFromStorage() async {
    final value = await _storage.read(key: 'demo_mode_active');
    _active = value == 'true';
  }
}

/// Versi reaktif [DemoMode.isActive] untuk widget (dipakai [DemoBanner]).
/// Diperbarui manual dari halaman login saat mode demo dimulai/berakhir.
final demoModeProvider = StateProvider<bool>((ref) => DemoMode.isActive);
