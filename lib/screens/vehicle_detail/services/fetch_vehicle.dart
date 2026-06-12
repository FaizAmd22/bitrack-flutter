import 'package:ams/base/network/api_client.dart';
import 'package:dio/dio.dart';

class FetchVehicle {
  const FetchVehicle();

  Future<Map<String, dynamic>> getVehicle(String id) async {
    try {
      final res = await ApiClient.dio.get('/vehicle/$id');

      final body = res.data;
      if (body is! Map) throw Exception('Response bukan JSON object');

      final data = body['data'];
      if (data is Map<String, dynamic>) return data;

      throw Exception('Field "data" kosong / tidak valid');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      if (data is Map && data['error_msg'] != null) {
        throw Exception('Request failed ($status): ${data['error_msg']}');
      }
      throw Exception(
        'Request failed ($status): ${data?.toString() ?? e.message}',
      );
    }
  }
}
