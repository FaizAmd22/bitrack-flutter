import 'package:bitrack_core/base/network/api_response.dart';
import 'dart:async';
import 'dart:convert';

import 'package:bitrack_core/base/network/api_client.dart';
import 'package:bitrack_core/base/services/push_notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bitrack_core/features/auth/data/auth_api.dart';

/// State proses login untuk UI: sedang memuat atau tidak, dan pesan error.
class AuthState {
  final bool isLoading;
  final String? errorMessage;

  const AuthState({this.isLoading = false, this.errorMessage});

  /// Catatan: [errorMessage] TIDAK ikut disalin; tidak mengisinya berarti
  /// menghapus pesan error.
  AuthState copyWith({bool? isLoading, String? errorMessage}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Secure storage untuk data login (bisa diganti versi palsu di tes).
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Logika login dan kredensial biometric. Dipakai form login lewat
/// [authControllerProvider].
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._secureStorage) : super(const AuthState());

  final FlutterSecureStorage _secureStorage;

  /// Login, lalu simpan token (lewat [ApiClient.setToken]) dan data user ke
  /// secure storage, lalu tautkan HP ke OneSignal.
  ///
  /// Mengembalikan response mentah bila sukses, atau null bila gagal (pesan
  /// errornya ada di `state.errorMessage`).
  Future<Map<String, dynamic>?> loginAndPersist({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await AuthApi.login(email: email, password: password);

      // Pengecekan `status` di body sengaja dimatikan: sukses ditentukan HTTP
      // status saja (alasannya di base/network/api_response.dart).
      // final rawStatus = result['status'];
      // final bool status =
      //     rawStatus == true ||
      //     rawStatus == 'true' ||
      //     rawStatus == 1 ||
      //     rawStatus == '1' ||
      //     rawStatus == 'success';

      // if (!status) {
      //   final String errorMsg =
      //       (result['message'] ??
      //               result['error_msg'] ??
      //               'Login gagal, coba lagi')
      //           .toString();

      //   state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      //   return null;
      // }

      final data = result['data'] as Map<String, dynamic>?;
      final token = data?['token']?.toString();
      final dataUser = data?['user'] as Map<String, dynamic>?;

      if (token != null && token.isNotEmpty) {
        // ApiClient.setToken juga menyimpan token ke secure storage.
        // await _secureStorage.write(key: 'auth_token', value: token);
        ApiClient.setToken(token);
      }

      if (dataUser != null) {
        await _secureStorage.write(
          key: 'user_id',
          value: dataUser['id']?.toString() ?? '',
        );
        await _secureStorage.write(
          key: 'user_name',
          value: dataUser['name']?.toString() ?? '',
        );
        await _secureStorage.write(
          key: 'user_email',
          value: dataUser['email']?.toString() ?? '',
        );
        await _secureStorage.write(
          key: 'user_role',
          value: dataUser['role']?.toString() ?? '',
        );
        await _secureStorage.write(
          key: 'user_role_permission',
          value: jsonEncode(dataUser['permission_allowed'] ?? []),
        );
        // Tidak ditunggu supaya login tidak tertahan oleh OneSignal.
        unawaited(
          PushNotificationService.onLogin(dataUser['email']?.toString() ?? ''),
        );
      }

      state = state.copyWith(isLoading: false, errorMessage: null);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: apiErrorText(e));
      return null;
    }
  }

  /// Simpan email + password untuk login biometric berikutnya. Disimpan di
  /// secure storage (Keychain / Android Keystore) dan TIDAK dihapus saat
  /// logout, supaya user bisa login lagi dengan sidik jari / Face ID.
  Future<void> saveBiometricCredential({
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(key: 'biometric_email', value: email);
    await _secureStorage.write(key: 'biometric_password', value: password);
  }

  /// Hapus kredensial biometric (user mematikan login biometric).
  Future<void> clearBiometricCredential() async {
    await _secureStorage.delete(key: 'biometric_email');
    await _secureStorage.delete(key: 'biometric_password');
  }

  /// Kredensial biometric tersimpan; string kosong kalau belum ada.
  Future<Map<String, String>> readBiometricCredential() async {
    final email = await _secureStorage.read(key: 'biometric_email') ?? '';
    final password = await _secureStorage.read(key: 'biometric_password') ?? '';
    return {'email': email, 'password': password};
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider [AuthController]; di-watch form login untuk loading dan error.
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final storage = ref.watch(secureStorageProvider);
    return AuthController(storage);
  },
);
