import 'package:ams/base/network/api_client.dart';

class VehicleApi {
  const VehicleApi();

  Future<Map<String, dynamic>?> fetchVehicleByLicense(
    String licensePlate,
  ) async {
    final resp = await ApiClient.dio.get(
      '/mobile/vehicle',
      queryParameters: {
        if (licensePlate.trim().isNotEmpty)
          'license_plate': licensePlate.trim(),
      },
    );

    final data = resp.data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) return inner;
    }
    return null;
  }
}
