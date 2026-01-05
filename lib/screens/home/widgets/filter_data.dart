import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bitrack_mobile_flutter/features/auth/providers/auth_providers.dart';
import 'package:bitrack_mobile_flutter/features/monitoring/data/monitoring_api.dart';
import 'package:bitrack_mobile_flutter/screens/home/models/filter_model.dart';
import 'package:bitrack_mobile_flutter/screens/home/models/fleet_geofence_models.dart';

class FilterData {
  final List<FilterOption> fleetGroups;
  final List<FilterOption> geofences;

  const FilterData({required this.fleetGroups, required this.geofences});
}

final filterDataProvider = FutureProvider<FilterData>((ref) async {
  final FlutterSecureStorage storage = ref.read(secureStorageProvider);

  final userId = await storage.read(key: 'user_id');
  if (userId == null || userId.isEmpty) {
    throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
  }

  final result = await MonitoringApi.fetchListGeofence(userId: userId);

  final status = result['status']?.toString();
  if (status != 'true') {
    final msg = result['error_msg']?.toString() ?? 'Gagal memuat data filter';
    throw Exception(msg);
  }

  final parsed = FleetGeofenceResponse.fromJson(result);

  // Fleet Groups
  final fleetOptions = <FilterOption>[
    const FilterOption(value: null, label: 'Semua Fleet Group'),
    ...parsed.data
        .where((e) => e.id.trim().isNotEmpty && e.name.trim().isNotEmpty)
        .map((e) => FilterOption(value: e.id, label: e.name.trim())),
  ];

  // Geofences (unique)
  final seen = <String>{};
  final geoOptions = <FilterOption>[
    const FilterOption(value: null, label: 'Semua Geofence'),
  ];

  for (final fg in parsed.data) {
    for (final g in fg.geofences) {
      final id = g.id.trim();
      final name = g.name.trim();
      if (id.isEmpty || name.isEmpty) continue;
      if (seen.add(id)) {
        geoOptions.add(FilterOption(value: id, label: name));
      }
    }
  }

  return FilterData(fleetGroups: fleetOptions, geofences: geoOptions);
});
