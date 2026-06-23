import 'package:ams/base/network/api_client.dart';
import 'package:ams/screens/vehicle/models/vehicle_page.dart';

class FetchVehicle {
  Future<VehiclePage> fetch({
    required int page,
    String? licensePlate,
    String? brand,
    String? fleetGroupId,
    int limit = 20,
  }) async {
    final res = await ApiClient.dio.get(
      '/master-vehicle/',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (licensePlate != null && licensePlate.trim().isNotEmpty)
          'search': licensePlate.trim(),
        if (brand != null && brand.isNotEmpty) 'brand': brand,
        if (fleetGroupId != null && fleetGroupId.isNotEmpty)
          'fleet_group_id': fleetGroupId,
      },
    );

    final data = res.data;
    if (data is Map<String, dynamic>) {
      return VehiclePage.fromResponse(data);
    }
    throw Exception('Format response tidak valid');
  }
}
