import 'package:dio/dio.dart';
import 'package:ams/base/network/api_client.dart';

class AuthApi {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        // '/login',
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      String message = 'Login gagal, coba lagi';

      if (e.response?.data is Map &&
          (e.response?.data as Map).containsKey('message')) {
        message = (e.response?.data as Map)['message'].toString();
      } else if (e.message != null) {
        message = e.message!;
      }

      throw Exception(message);
    } catch (_) {
      throw Exception('Terjadi kesalahan, coba lagi');
    }
  }
}
