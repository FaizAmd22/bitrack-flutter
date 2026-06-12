import 'package:ams/base/network/api_client.dart';
import 'package:dio/dio.dart';

class VehicleMasterApi {
  const VehicleMasterApi();

  Future<List<Map<String, dynamic>>> fetchBrandsRaw({
    CancelToken? cancelToken,
  }) async {
    final res = await ApiClient.dio.get('/brand', cancelToken: cancelToken);
    final data = (res.data['data'] as List?) ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchModelsRaw({
    CancelToken? cancelToken,
  }) async {
    final res = await ApiClient.dio.get('/model', cancelToken: cancelToken);
    final data = (res.data['data'] as List?) ?? [];
    return data.cast<Map<String, dynamic>>();
  }
}
