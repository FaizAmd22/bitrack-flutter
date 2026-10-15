// ignore_for_file: use_build_context_synchronously

import 'package:bitrack_core/base/routes/app_routes.dart';
import 'package:bitrack_core/base/routes/navigation_service.dart';
import 'package:bitrack_core/base/network/api_logger.dart';
import 'package:bitrack_core/base/network/api_timing.dart';
import 'dart:async';

import 'package:bitrack_core/base/services/demo_mode.dart';
import 'package:bitrack_core/base/services/push_notification_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Klien HTTP utama ke backend tracking (`BASE_URL` di `.env`).
///
/// Semua service API memakai [ApiClient.dio], bukan membuat `Dio` sendiri,
/// supaya tiga hal berlaku seragam:
/// - header `Authorization: Bearer <token>` ditempel otomatis,
/// - respons 401 (sesi habis) langsung memicu [logout],
/// - request dicatat waktunya ([attachRequestTiming]) dan, di debug, isinya
///   ([attachApiLogger]).
///
/// Token disimpan di memori ([_token]) untuk dipakai request, dan di secure
/// storage (`auth_token`) supaya sesi tetap ada setelah app ditutup. Token
/// dimuat ulang dari storage di `main()` lewat [loadTokenFromStorage].
class ApiClient {
  ApiClient._();

  static String? _token;

  /// True selama proses logout berjalan. Dipakai untuk menolak request baru
  /// (kecuali login) supaya tidak ada request yang membawa token lama dan
  /// memicu logout kedua.
  static bool _isLoggingOut = false;

  // Mode `first_unlock_this_device` (iOS) membuat token tetap terbaca walau
  // app dibuka saat HP terkunci (mis. dari notifikasi), asal HP sudah pernah
  // dibuka sekali sejak dinyalakan.
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Simpan token baru (dipanggil setelah login sukses atau masuk mode demo).
  static Future<void> setToken(String token) async {
    _token = token;
    _isLoggingOut = false;
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Hapus token dari memori saja; storage dihapus oleh [logout].
  static void clearToken() => _token = null;

  /// Muat token tersimpan ke memori. Dipanggil sekali di `main()`.
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
    // Perangkat ini berhenti menerima notifikasi milik user yang keluar.
    unawaited(PushNotificationService.onLogout());

    await Future.wait([
      _storage.delete(key: 'auth_token'),
      _storage.delete(key: 'user_id'),
      _storage.delete(key: 'user_name'),
      _storage.delete(key: 'user_email'),
      _storage.delete(key: 'user_role'),
      _storage.delete(key: 'user_role_permission'),
      DemoMode.clearOnLogout(),
    ]);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.loginScreen,
        (_) => false,
      );
    });
  }

  /// Instance Dio bersama. Dibuat saat pertama dipakai, setelah `.env` dimuat
  /// di `main()` (karena `BASE_URL` dibaca di sini).
  static final Dio dio = _createDio();

  static Dio _createDio() {
    final client = Dio(
      BaseOptions(
        baseUrl: (dotenv.env['BASE_URL'] ?? '').trim(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          // 'Content-Type': 'application/json',
        },
      ),
    );

    // Paling awal supaya jamnya mulai sebelum interceptor lain bekerja.
    attachRequestTiming(client);

    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path.endsWith('/login')) {
            handler.next(options);
            return;
          }

          // Tolak request selain login selama logout berjalan.
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
          // 401 = token tidak berlaku lagi. Pengecualian untuk endpoint login:
          // di sana error berarti kredensial salah (ditangani AuthApi), bukan
          // sesi habis.
          if (e.response?.statusCode == 401 &&
              !e.requestOptions.path.endsWith('/login')) {
            await logout();
          }
          handler.next(e);
        },
      ),
    );

    // Dipasang paling akhir supaya log request sudah memuat header
    // Authorization yang ditempel interceptor di atas.
    attachApiLogger(client);

    return client;
  }
}
