import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ams/screens/vehicle/services/fetch_fleet_group.dart';

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
      final id = (fg['value'] ?? '').toString().trim();
      final name = (fg['label'] ?? '').toString().trim();
      if (id.isNotEmpty) {
        map[id] = name.isNotEmpty ? name : '-';
      }
    }
    return map;
  });
});
