import 'package:ams/base/network/api_client.dart';
import 'package:flutter/foundation.dart';

class CheckLicensePlateService {
  const CheckLicensePlateService();

  Future<bool> isPlateExists(String licensePlate) async {
    final plate = licensePlate.trim();
    try {
      final res = await ApiClient.dio.get(
        '/master-vehicle/check-fleetify',
        queryParameters: {if (plate.isNotEmpty) 'license_plate': plate},
      );

      final body = res.data;
      if (body is! Map) return false;

      // Request yang gagal sudah jadi DioException dan di-rethrow di bawah,
      // jadi di titik ini cukup baca hasil pengecekannya saja.
      final metadata = body['metadata'];
      return metadata is Map && metadata['found'] == true;
    } catch (e) {
      debugPrint('checkLicensePlate error: $e');
      rethrow;
    }
  }
}
