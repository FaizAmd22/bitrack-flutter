// ignore_for_file: use_build_context_synchronously

import 'package:ams/base/routes/app_routes.dart';
import 'package:ams/base/routes/navigation_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  ApiClient._();

  static String? _token;
  static bool _isLoggingOut = false;

  static void setToken(String token) {
    _token = token;
    _isLoggingOut = false; // reset saat login baru sukses
  }

  static void clearToken() => _token = null;

  static const _storage = FlutterSecureStorage();

  static Future<void> loadTokenFromStorage() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null && token.isNotEmpty) {
      _token = token;
      _isLoggingOut = false; // pastikan flag bersih saat app start
    }
  }

  static Future<void> _performLogout() async {
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

    final navigator = NavigationService.navigatorKey.currentState;
    if (navigator == null) return;

    final currentRoute = ModalRoute.of(navigator.context)?.settings.name;
    if (currentRoute != AppRoutes.loginScreen) {
      navigator.pushNamedAndRemoveUntil(AppRoutes.loginScreen, (_) => false);
    }
  }

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: (dotenv.env['BASE_URL'] ?? '').trim(),
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              // ✅ Login path SELALU lolos, tidak peduli _isLoggingOut
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
              // ✅ Login 401 jangan trigger logout flow
              if (e.response?.statusCode == 401 &&
                  !e.requestOptions.path.endsWith('/login')) {
                await _performLogout();
              }
              handler.next(e);
            },
          ),
        );
}
