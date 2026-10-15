import 'package:bitrack_core/base/network/api_client.dart';
import 'package:bitrack_core/base/services/demo_mode.dart';

/// Hasil ganti password.
class UpdatePasswordResult {
  final bool success;
  final String? errorMsg;
  const UpdatePasswordResult({required this.success, this.errorMsg});
}

/// Menyimpan password baru ke backend tracking, setelah OTP terverifikasi.
class UpdatePasswordService {
  const UpdatePasswordService();

  /// `PUT /users/update-password/{id} {password}`; [id] = `user_id` dari
  /// secure storage. Di mode demo selalu dianggap berhasil.
  Future<UpdatePasswordResult> updatePassword({
    required String id,
    required String password,
  }) async {
    if (DemoMode.isActive) return const UpdatePasswordResult(success: true);

    final res = await ApiClient.dio.put(
      '/users/update-password/$id',
      data: {'password': password},
    );
    return _parse(res.data);
  }

  /// HTTP 2xx = berhasil. Kegagalan datang sebagai DioException dan
  /// ditangani di change_password.dart.
  UpdatePasswordResult _parse(dynamic body) =>
      const UpdatePasswordResult(success: true);
}
