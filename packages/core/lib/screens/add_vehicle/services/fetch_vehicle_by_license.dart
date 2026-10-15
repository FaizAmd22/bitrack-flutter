import 'package:bitrack_core/base/network/api_client.dart';

/// Mengambil data satu kendaraan yang sudah ada, untuk mengisi form tambah/
/// ubah kendaraan. Keduanya mengembalikan isi `data`, atau null.
class VehicleApi {
  const VehicleApi();

  /// `GET /master-vehicle/{id}`.
  Future<Map<String, dynamic>?> fetchVehicleById(String id) async {
    final resp = await ApiClient.dio.get('/master-vehicle/$id');

    final data = resp.data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) return inner;
    }
    return null;
  }

  /// `GET /mobile/vehicle?license_plate=...`.
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
