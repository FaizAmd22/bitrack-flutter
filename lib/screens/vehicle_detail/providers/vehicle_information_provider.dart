import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ams/screens/vehicle_detail/services/fetch_monitoring_detail.dart';
import 'package:ams/screens/vehicle_detail/utils/flatten_monitoring_detail.dart';
import 'package:flutter_riverpod/legacy.dart';

final vehicleIdProvider = StateProvider<String?>((ref) => null);

final vehicleDetailByVehicleIdProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      final detailId = id.trim();
      if (detailId.isEmpty) {
        throw Exception('vehicle_id kosong');
      }

      final api = const FetchMonitoringDetail();

      // DASHBOARD punya latitude/longitude/direction/fuel/sensor, sedangkan
      // INFORMATION punya odometer/battery — gabungkan supaya semua tab di
      // VehicleInformationBottomSheet (Information/Status/Sensor) terisi.
      final results = await Future.wait([
        api.getDetail(detailId, tab: 'DASHBOARD'),
        api.getDetail(detailId, tab: 'INFORMATION'),
      ]);

      return {
        ...flattenMonitoringDetail(results[0], detailId: detailId),
        ...flattenInformationStatus(results[1]),
      };
    });
