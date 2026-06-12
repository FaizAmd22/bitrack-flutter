import 'package:ams/base/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ams/features/auth/data/auth_api.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;

  const AuthState({this.isLoading = false, this.errorMessage});

  AuthState copyWith({bool? isLoading, String? errorMessage}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._secureStorage) : super(const AuthState());

  final FlutterSecureStorage _secureStorage;

  Future<Map<String, dynamic>?> loginAndPersist({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await AuthApi.login(email: email, password: password);

      final rawStatus = result['status'];
      final bool status =
          rawStatus == true ||
          rawStatus == 'true' ||
          rawStatus == 1 ||
          rawStatus == '1';

      if (!status) {
        final String errorMsg =
            (result['error_msg'] ?? 'Login gagal, coba lagi').toString();

        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return null;
      }

      final data = result['data'] as Map<String, dynamic>?;
      final token = data?['token']?.toString();
      final userList = data?['user_data'] as List<dynamic>?;
      final dataUser = (userList != null && userList.isNotEmpty)
          ? userList[0]
          : null;

      if (token != null && token.isNotEmpty) {
        await _secureStorage.write(key: 'auth_token', value: token);
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
          value: dataUser['role']?['role_name']?.toString() ?? '',
        );
        await _secureStorage.write(
          key: 'user_role_permission',
          value:
              dataUser['role']?['role_permession']?['permession']?.toString() ??
              '',
        );
      }

      state = state.copyWith(isLoading: false, errorMessage: null);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  Future<void> saveBiometricCredential({
    required String email,
    required String password,
  }) async {
    await _secureStorage.write(key: 'biometric_email', value: email);
    await _secureStorage.write(key: 'biometric_password', value: password);
  }

  Future<void> clearBiometricCredential() async {
    await _secureStorage.delete(key: 'biometric_email');
    await _secureStorage.delete(key: 'biometric_password');
  }

  Future<Map<String, String>> readBiometricCredential() async {
    final email = await _secureStorage.read(key: 'biometric_email') ?? '';
    final password = await _secureStorage.read(key: 'biometric_password') ?? '';
    return {'email': email, 'password': password};
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final storage = ref.watch(secureStorageProvider);
    return AuthController(storage);
  },
);
