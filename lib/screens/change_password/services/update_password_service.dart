import 'package:ams/base/network/api_client.dart';

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
    final res = await ApiClient.dio.put(
      '/users/update-password/$id',
      data: {'password': password},
    );
    return _parse(res.data);
  }

  UpdatePasswordResult _parse(dynamic body) {
    final status = body is Map ? body['status'] : null;
    final isFalse = status == false || status == 'false';

    if (isFalse) {
      final msg = body is Map
          ? (body['message'] ?? body['error_msg'])?.toString()
          : null;
      return UpdatePasswordResult(success: false, errorMsg: msg);
    }
    return const UpdatePasswordResult(success: true);
  }
}
