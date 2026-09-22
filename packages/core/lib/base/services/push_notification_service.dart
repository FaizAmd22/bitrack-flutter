import 'dart:async';

import 'package:bitrack_core/base/services/demo_mode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Operasi OneSignal yang dipakai app. Dipisah supaya bisa diganti di tes:
/// plugin aslinya butuh platform channel yang tidak ada di lingkungan tes.
abstract class PushClient {
  Future<void> initialize(String appId);
  Future<void> login(String externalId);
  Future<void> logout();
  Future<bool> requestPermission();
}

class OneSignalPushClient implements PushClient {
  const OneSignalPushClient();

  @override
  Future<void> initialize(String appId) async {
    if (kDebugMode) await OneSignal.Debug.setLogLevel(OSLogLevel.warn);
    await OneSignal.initialize(appId);
  }

  @override
  Future<void> login(String externalId) => OneSignal.login(externalId);

  @override
  Future<void> logout() => OneSignal.logout();

  // Tanpa fallback ke Settings: kalau user sudah menolak, app tidak
  // membukakan halaman pengaturan dengan paksa.
  @override
  Future<bool> requestPermission() =>
      OneSignal.Notifications.requestPermission(false);
}

/// Push notification lewat OneSignal, dipakai ketiga app.
///
/// Tiap app punya App ID OneSignal sendiri di `.env` / `.env.prod`
/// (`ONESIGNAL_APP_ID`). Kosong = push nonaktif tanpa error, supaya build
/// yang belum dikonfigurasi tetap jalan.
///
/// Perangkat ditautkan ke user lewat external ID = `email` dari response
/// login (`data.user.email`), apa adanya. Backend mengirim ke user tertentu
/// lewat REST API OneSignal dengan
/// `"include_aliases": {"external_id": ["<email>"]}`.
///
/// Izin notifikasi TIDAK diminta di sini, melainkan lewat
/// [requestPermission] dari alur login, setelah user memilih menyimpan
/// biometric atau tidak.
///
/// Tidak ada yang boleh menahan UI: semua pemanggil memakai `unawaited`, dan
/// kegagalan plugin hanya dicatat, tidak dilempar.
class PushNotificationService {
  PushNotificationService._();

  @visibleForTesting
  static PushClient client = const OneSignalPushClient();

  static bool _initialized = false;
  static Future<void>? _starting;

  static const _permissionAskedKey = 'push_permission_asked';

  /// Sama dengan storage yang dipakai kode lain untuk membaca `user_id`.
  static const _storage = FlutterSecureStorage();

  static bool get isEnabled => _initialized;

  /// Dipanggil di main() setelah .env dan token dimuat: inisialisasi, lalu
  /// tautkan user yang sesinya masih tersimpan (mis. setelah update app).
  /// Izin notifikasi tidak diminta di sini.
  static Future<void> start() => _starting ??= _start();

  static Future<void> _start() async {
    final appId = (dotenv.maybeGet('ONESIGNAL_APP_ID') ?? '').trim();
    if (appId.isEmpty) {
      debugPrint('OneSignal: ONESIGNAL_APP_ID kosong, push notif nonaktif.');
      return;
    }
    try {
      await client.initialize(appId);
      _initialized = true;
    } catch (e) {
      debugPrint('OneSignal: inisialisasi gagal: $e');
      return;
    }

    // `user_email` dihapus saat logout, jadi keberadaannya berarti masih
    // login. Nilainya disimpan dari response login yang sama.
    String email = '';
    try {
      email = await _storage.read(key: 'user_email') ?? '';
    } catch (e) {
      debugPrint('OneSignal: user_email tidak terbaca: $e');
    }
    if (email.isNotEmpty) await _link(email);
  }

  /// Dipanggil setelah login berhasil, dengan email dari response login.
  static Future<void> onLogin(String email) async {
    // Login bisa terjadi sebelum start() selesai.
    await _starting;
    await _link(email);
  }

  /// Tampilkan dialog izin notifikasi, sekali per instalasi. Dipanggil dari
  /// alur login setelah user memilih menyimpan biometric atau tidak.
  static Future<void> requestPermission() async {
    await _starting;
    if (!_initialized || DemoMode.isActive) return;
    await _requestPermissionOnce();
  }

  /// Dipanggil saat logout, supaya perangkat ini tidak lagi menerima
  /// notifikasi milik user tadi.
  static Future<void> onLogout() async {
    await _starting;
    if (!_initialized) return;
    try {
      await client.logout();
    } catch (e) {
      debugPrint('OneSignal: logout gagal: $e');
    }
  }

  static Future<void> _link(String externalId) async {
    final id = externalId.trim();
    // Akun demo dipakai bersama; jangan tautkan perangkat ke sana.
    if (!_initialized || id.isEmpty || DemoMode.isActive) return;
    try {
      await client.login(id);
    } catch (e) {
      debugPrint('OneSignal: login gagal: $e');
    }
  }

  /// Minta izin notifikasi sekali per instalasi. iOS memang hanya pernah
  /// menampilkan dialognya sekali; Android 13+ bisa berulang, dan menanyakan
  /// setiap kali app dibuka mengganggu.
  static Future<void> _requestPermissionOnce() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_permissionAskedKey) ?? false) return;
      await prefs.setBool(_permissionAskedKey, true);
      await client.requestPermission();
    } catch (e) {
      debugPrint('OneSignal: permintaan izin gagal: $e');
    }
  }

  @visibleForTesting
  static void resetForTest() {
    _initialized = false;
    _starting = null;
    client = const OneSignalPushClient();
  }
}
