import 'package:ams/base/network/api_client.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Mode demo: melewati login/register asli agar reviewer App Store bisa
// mengakses seluruh fitur tanpa akun nyata. Data yang ditampilkan semuanya
// dummy (lihat demo_data.dart). Bersifat sementara, dibuat untuk lolos
// App Store review, bukan fitur publik permanen.
class DemoMode {
  DemoMode._();

  static bool _active = false;
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

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

  static Future<void> clearOnLogout() async {
    _active = false;
    await _storage.delete(key: 'demo_mode_active');
  }

  static Future<void> loadFromStorage() async {
    final value = await _storage.read(key: 'demo_mode_active');
    _active = value == 'true';
  }
}

final demoModeProvider = StateProvider<bool>((ref) => DemoMode.isActive);
