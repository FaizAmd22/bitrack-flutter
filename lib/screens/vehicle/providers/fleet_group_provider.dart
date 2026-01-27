import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle/service/fetch_fleet_group.dart';

final fleetGroupApiProvider = Provider<FetchFleetGroup>(
  (ref) => FetchFleetGroup(),
);

final fleetGroupProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(fleetGroupApiProvider);
  return api.fetch();
});

final fleetGroupMapProvider = Provider<AsyncValue<Map<String, String>>>((ref) {
  final asyncList = ref.watch(fleetGroupProvider);

  return asyncList.whenData((list) {
    final map = <String, String>{};
    for (final fg in list) {
      final id = (fg['id'] ?? '').toString().trim();
      final name = (fg['fleet_group_name'] ?? '').toString().trim();
      if (id.isNotEmpty) {
        map[id] = name.isNotEmpty ? name : '-';
      }
    }
    return map;
  });
});
