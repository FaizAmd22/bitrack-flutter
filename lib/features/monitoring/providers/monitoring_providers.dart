import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ams/features/monitoring/data/monitoring_api.dart';
import 'package:ams/screens/home/models/vehicle.dart';

// /monitoring/ default limit is 20; pakai limit besar agar seluruh fleet
// tetap tercakup tanpa harus mengimplementasikan cursor pagination di map.
const _monitoringFetchLimit = 1000;

final monitoringProvider = FutureProvider.family<List<Vehicle>, String>((
  ref,
  activity,
) async {
  final statusResult = await MonitoringApi.fetchMonitoring(
    status: activity,
    limit: _monitoringFetchLimit,
  );

  if (statusResult['status']?.toString() != 'true') {
    final msg = (statusResult['message'] ?? statusResult['error_msg'])
            ?.toString() ??
        'Gagal memuat data';
    throw Exception(msg);
  }

  final positionResult = await MonitoringApi.fetchPosition();

  if (positionResult['status']?.toString() != 'true') {
    final msg = (positionResult['message'] ?? positionResult['error_msg'])
            ?.toString() ??
        'Gagal memuat posisi kendaraan';
    throw Exception(msg);
  }

  final List<dynamic> statusList = (statusResult['data'] as List?) ?? [];
  final List<dynamic> positionList = (positionResult['data'] as List?) ?? [];

  final positionById = <String, Map<String, dynamic>>{
    for (final p in positionList)
      if (p is Map && p['_id'] != null)
        p['_id'].toString(): Map<String, dynamic>.from(p),
  };

  final vehicles = <Vehicle>[];
  for (final item in statusList) {
    if (item is! Map) continue;

    final position = positionById[item['_id']?.toString()];
    if (position == null) continue;

    vehicles.add(
      Vehicle.fromJson({...Map<String, dynamic>.from(item), ...position}),
    );
  }

  return vehicles;
});
