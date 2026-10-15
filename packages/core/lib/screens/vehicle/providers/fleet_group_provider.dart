import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitrack_core/screens/vehicle/services/fetch_fleet_group.dart';

/// Service fleet group (bisa diganti versi palsu di tes).
final fleetGroupApiProvider = Provider<FetchFleetGroup>(
  (ref) => FetchFleetGroup(),
);

/// Daftar fleet group milik user (`value` = id, `label` = nama). Dipakai
/// untuk pilihan filter di Home, Notifikasi, dan Vehicle. Di-cache selama app
/// berjalan.
final fleetGroupProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(fleetGroupApiProvider);
  return api.fetch();
});

/// Peta id fleet group -> nama, untuk menampilkan nama dari id. (Saat ini
/// tidak dipakai di halaman mana pun.)
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
