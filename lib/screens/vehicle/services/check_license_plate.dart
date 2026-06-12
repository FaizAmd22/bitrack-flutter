import 'package:ams/base/network/api_client.dart';
import 'package:flutter/foundation.dart';

class CheckLicensePlateService {
  const CheckLicensePlateService();

  Future<bool> isPlateExists(String licensePlate) async {
    final plate = licensePlate.trim();
    try {
      final res = await ApiClient.dio.get(
        '/mobile/vehicle/check-create-mobile',
        queryParameters: {if (plate.isNotEmpty) 'license_plate': plate},
      );

      final status = res.data is Map ? res.data['status'] : null;
      final exists = status == false || status == 'false';

      return exists;
    } catch (e) {
      debugPrint('checkLicensePlate error: $e');
      rethrow;
    }
  }
}
