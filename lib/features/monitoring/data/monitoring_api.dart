import 'package:ams/base/network/api_client.dart';

class MonitoringApi {
  static String _activityParam(String status) {
    switch (status) {
      case 'moving':
        return 'MOVING';
      case 'idle':
        return 'IDLE';
      case 'stop':
        return 'STOP';
      case 'silence':
        return 'SILENCE';
      case 'inOperation':
        return 'IN_OPERATION';
      case 'repair':
        return 'REPAIR';
      case 'allVehicle':
      default:
        return '';
    }
  }

  static Future<Map<String, dynamic>> fetchMonitoring({
    required String status,
    String? licensePlate,
    String? fleetGroupIds,
    String? imei,
    String? cursor,
    int? limit,
  }) async {
    try {
      final activity = _activityParam(status);

      final response = await ApiClient.dio.get(
        '/monitoring/',
        queryParameters: {
          if (activity.isNotEmpty) 'activity': activity,
          if (licensePlate != null && licensePlate.isNotEmpty)
            'license_plate': licensePlate,
          if (fleetGroupIds != null && fleetGroupIds.isNotEmpty)
            'fleet_group_ids': fleetGroupIds,
          if (imei != null && imei.isNotEmpty) 'imei': imei,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          if (limit != null) 'limit': limit,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Terjadi kesalahan saat memuat monitoring');
    }
  }

  static Future<Map<String, dynamic>> fetchPosition({
    String? licensePlate,
    String? fleetGroupId,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/monitoring/position',
        queryParameters: {
          if (licensePlate != null && licensePlate.isNotEmpty)
            'license_plate': licensePlate,
          if (fleetGroupId != null && fleetGroupId.isNotEmpty)
            'fleet_group_id': fleetGroupId,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Terjadi kesalahan saat memuat posisi kendaraan');
    }
  }
}
