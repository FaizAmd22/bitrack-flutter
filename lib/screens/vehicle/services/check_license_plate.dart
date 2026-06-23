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

      final status = body['status'];
      final statusTrue = status == true || status == 'true';

      final metadata = body['metadata'];
      final found = metadata is Map && metadata['found'] == true;

      return statusTrue && found;
    } catch (e) {
      debugPrint('checkLicensePlate error: $e');
      rethrow;
    }
  }
}
