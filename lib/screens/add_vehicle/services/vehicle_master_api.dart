import 'package:ams/base/network/api_client.dart';
import 'package:dio/dio.dart';

class VehicleMasterApi {
  const VehicleMasterApi();

  Future<List<Map<String, dynamic>>> fetchBrandHierarchy({
    CancelToken? cancelToken,
  }) async {
    final res = await ApiClient.dio.get(
      '/master-vehicle/brands',
      cancelToken: cancelToken,
    );

    final body = res.data;
    if (body is! Map || body['data'] is! List) return [];

    return (body['data'] as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
