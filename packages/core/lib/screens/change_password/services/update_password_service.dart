import 'package:bitrack_core/base/network/api_client.dart';
import 'package:bitrack_core/base/services/demo_mode.dart';

class UpdatePasswordResult {
  final bool success;
  final String? errorMsg;
  const UpdatePasswordResult({required this.success, this.errorMsg});
}

class UpdatePasswordService {
  const UpdatePasswordService();

  /// PUT /users/update-password/{id}  { password }
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
