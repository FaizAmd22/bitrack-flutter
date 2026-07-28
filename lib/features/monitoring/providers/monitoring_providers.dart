import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ams/features/monitoring/data/monitoring_api.dart';
import 'package:ams/screens/home/models/vehicle.dart';

// /monitoring/ default limit is 20; pakai limit besar agar seluruh fleet
// tetap tercakup tanpa harus mengimplementasikan cursor pagination di map.
const _monitoringFetchLimit = 1000;

class MonitoringQuery {
  final String activity;
  final String? licensePlate;
  final String? fleetGroupId;

  const MonitoringQuery({
    required this.activity,
    this.licensePlate,
    this.fleetGroupId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonitoringQuery &&
          other.activity == activity &&
          other.licensePlate == licensePlate &&
          other.fleetGroupId == fleetGroupId);

  @override
  int get hashCode => Object.hash(activity, licensePlate, fleetGroupId);
}

final monitoringProvider = FutureProvider.family<List<Vehicle>, MonitoringQuery>((
  ref,
  query,
) async {
  final statusResult = await MonitoringApi.fetchMonitoring(
    status: query.activity,
    limit: _monitoringFetchLimit,
  );

  // /monitoring/position mendukung filter server-side by license_plate
  // (search plat) dan fleet_group_id (filter fleet group).
  final positionResult = await MonitoringApi.fetchPosition(
    licensePlate: query.licensePlate,
    fleetGroupId: query.fleetGroupId,
  );

  final List<dynamic> statusList = (statusResult['data'] as List?) ?? [];
  final List<dynamic> positionList = (positionResult['data'] as List?) ?? [];

  final positionById = <String, Map<String, dynamic>>{
    for (final p in positionList)
      if (p is Map && (p['id'] ?? p['_id']) != null)
        (p['id'] ?? p['_id']).toString(): Map<String, dynamic>.from(p),
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
