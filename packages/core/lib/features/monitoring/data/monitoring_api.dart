import 'package:bitrack_core/base/localization/locale_controller.dart';
import 'package:bitrack_core/base/network/api_client.dart';
import 'package:bitrack_core/base/services/demo_data.dart';
import 'package:bitrack_core/base/services/demo_mode.dart';

class MonitoringApi {
  // Kosakata server. Nilainya huruf kecil + underscore, persis seperti yang
  // dipakai web tracking-dev (mis. `/monitoring?activity=in_operation`).
  // Sebelumnya app mengirim huruf besar (`IN_OPERATION`) sehingga filter
  // activity berpotensi diabaikan server dan chip menampilkan seluruh armada.
  static const _activityParams = <String, String>{
    'allVehicle': '',
    'inOperation': 'in_operation',
    'moving': 'moving',
    'idle': 'idle',
    'stop': 'stop',
    'silence': 'silence',
    'repair': 'repair',
  };

  // Kunci di `metadata.summary` response `/monitoring` — huruf besar,
  // beda dari parameter query di atas.
  static const _summaryKeys = <String, String>{
    'allVehicle': 'ALL',
    'inOperation': 'IN_OPERATION',
    'moving': 'MOVING',
    'idle': 'IDLE',
    'stop': 'STOP',
    'silence': 'SILENCE',
    'repair': 'REPAIR',
  };

  static String activityParam(String activity) => _activityParams[activity] ?? '';

  static String summaryKey(String activity) => _summaryKeys[activity] ?? 'ALL';

  /// `GET /monitoring` — daftar status kendaraan (tanpa koordinat) plus
  /// `metadata.summary` berisi jumlah kendaraan per activity.
  ///
  /// Ini satu-satunya endpoint yang menerima `activity`, jadi hanya endpoint
  /// ini yang perlu dipanggil ulang saat user mengganti chip activity.
  static Future<Map<String, dynamic>> fetchMonitoring({
    required String status,
    String? licensePlate,
    String? fleetGroupIds,
    String? imei,
    String? cursor,
    int? limit,
  }) async {
    final activity = activityParam(status);

    if (DemoMode.isActive) {
      return DemoData.monitoringStatusList(activity: activity);
    }

    try {
      final response = await ApiClient.dio.get(
        '/monitoring/',
        queryParameters: {
          if (activity.isNotEmpty) 'activity': activity,
          if (licensePlate != null && licensePlate.isNotEmpty)
            'license_plate': licensePlate,
          // Perhatikan bentuk jamak: `/monitoring` memakai `fleet_group_ids`,
          // sedangkan `/monitoring/position` memakai `fleet_group_id`.
          if (fleetGroupIds != null && fleetGroupIds.isNotEmpty)
            'fleet_group_ids': fleetGroupIds,
          if (imei != null && imei.isNotEmpty) 'imei': imei,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          if (limit != null) 'limit': limit,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (_) {
      throw Exception(currentL10n().errLoadMonitoringFailed);
    }
  }

  /// `GET /monitoring/position` — koordinat kendaraan. Response-nya sudah
  /// lengkap untuk membangun marker (latitude, longitude, direction,
  /// vehicle_activity, device_time, ignition, license_plate,
  /// fleet_group_name, vehicle_id), jadi tidak perlu digabung dengan
  /// `/monitoring` untuk menggambar peta.
  ///
  /// Hanya menerima filter search & fleet group — TIDAK menerima activity.
  static Future<Map<String, dynamic>> fetchPosition({
    String? licensePlate,
    String? fleetGroupId,
  }) async {
    if (DemoMode.isActive) {
      return DemoData.monitoringPositionList(
        licensePlate: licensePlate,
        fleetGroupId: fleetGroupId,
      );
    }

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
      throw Exception(currentL10n().errLoadVehiclePositionFailed);
    }
  }
}
