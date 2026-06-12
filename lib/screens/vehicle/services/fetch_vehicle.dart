import 'package:ams/base/network/api_client.dart';
import 'package:ams/screens/vehicle/models/vehicle_page.dart';

class FetchVehicle {
  Future<VehiclePage> fetch({required int page, String? licensePlate}) async {
    final res = await ApiClient.dio.get(
      '/vehicle',
      queryParameters: {
        'page': page,
        if (licensePlate != null && licensePlate.trim().isNotEmpty)
          'license_plate': licensePlate.trim(),
      },
    );

    final data = res.data;
    if (data is Map<String, dynamic>) {
      return VehiclePage.fromResponse(data);
    }
    throw Exception('Format response tidak valid');
  }
}
