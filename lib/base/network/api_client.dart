// ignore_for_file: use_build_context_synchronously

import 'package:ams/base/routes/app_routes.dart';
import 'package:ams/base/routes/navigation_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  ApiClient._();

  static String? _token;
  static bool _isLoggingOut = false;
  // Use first_unlock_this_device so the token survives device lock/sleep
  // without requiring the screen to be unlocked at app launch.
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> setToken(String token) async {
    _token = token;
    _isLoggingOut = false;
    await _storage.write(key: 'auth_token', value: token);
  }

  static void clearToken() => _token = null;

  static Future<void> loadTokenFromStorage() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null && token.isNotEmpty) {
      _token = token;
      _isLoggingOut = false;
    }
  }

  // Satu-satunya jalur logout (dipicu otomatis saat 401 maupun manual dari
  // UI seperti tombol Sign Out / sukses ganti password). Sengaja hapus key
  // sesi saja, BUKAN deleteAll(), supaya kredensial biometric (disimpan
  // terpisah agar bisa login cepat lagi tanpa ketik ulang) tidak ikut hilang.
  static Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    clearToken();

    await Future.wait([
      _storage.delete(key: 'auth_token'),
      _storage.delete(key: 'user_id'),
      _storage.delete(key: 'user_name'),
      _storage.delete(key: 'user_email'),
      _storage.delete(key: 'user_role'),
      _storage.delete(key: 'user_role_permission'),
    ]);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      NavigationService.navigatorKey.currentState
          ?.pushNamedAndRemoveUntil(AppRoutes.loginScreen, (_) => false);
    });
  }

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: (dotenv.env['BASE_URL'] ?? '').trim(),
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Accept': 'application/json',
              // 'Content-Type': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path.endsWith('/login')) {
                handler.next(options);
                return;
              }

              // Reject request non-login saat sedang logout
              if (_isLoggingOut) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    type: DioExceptionType.cancel,
                    message: 'Logging out',
                  ),
                );
                return;
              }

              if (_token != null) {
                options.headers['Authorization'] = 'Bearer $_token';
              }
              handler.next(options);
            },
            onError: (DioException e, handler) async {
              if (e.response?.statusCode == 401 &&
                  !e.requestOptions.path.endsWith('/login')) {
                await logout();
              }
              handler.next(e);
            },
          ),
        );
}
