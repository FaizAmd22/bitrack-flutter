import 'package:bitrack_mobile_flutter/screens/home/models/filter_model.dart';
import 'package:dio/dio.dart';

class GeofenceRepo {
  final Dio dio;
  GeofenceRepo(this.dio);

  Future<List<FilterOption>> fetchGeofenceOptions(String userId) async {
    final res = await dio.get('/vehicle-monitoring/child/fleet-group/$userId');
    final data = res.data;

    final out = <FilterOption>[
      const FilterOption(value: null, label: 'All Geofence'),
    ];

    if (data is Map<String, dynamic>) {
      final list = data['data'];
      if (list is List) {
        final seen = <String>{};
        for (final item in list) {
          if (item is! Map) continue;
          final geos = item['geofence'];
          if (geos is! List) continue;

          for (final g in geos) {
            if (g is! Map) continue;
            final id = (g['geofence_id'] ?? '').toString();
            final name = (g['geofence_name'] ?? '').toString().trim();
            if (id.isEmpty || name.isEmpty) continue;
            if (seen.add(id)) {
              out.add(FilterOption(value: id, label: name));
            }
          }
        }
      }
    }

    return out;
  }
}
