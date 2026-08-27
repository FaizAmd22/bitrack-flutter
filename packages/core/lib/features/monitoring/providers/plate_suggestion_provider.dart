import 'package:bitrack_core/features/monitoring/providers/monitoring_providers.dart';
import 'package:bitrack_core/screens/home/models/vehicle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Daftar plat untuk autocomplete search bar.
///
/// Di-key oleh [MonitoringFilter], bukan activity: saran plat tidak perlu
/// ikut menyempit saat user mengganti chip activity, dan dengan begitu ia
/// memakai cache /monitoring/position yang sama dengan peta (tanpa request
/// tambahan) selama filter-nya sama.
final plateSuggestionProvider =
    Provider.family<List<String>, MonitoringFilter>((ref, filter) {
      final asyncVehicles = ref.watch(vehiclePositionProvider(filter));
      final vehicles = asyncVehicles.asData?.value ?? const <Vehicle>[];

      final seen = <String>{};
      final out = <String>[];

      for (final v in vehicles) {
        final p = v.licensePlate.trim();
        if (p.isEmpty) continue;
        if (seen.add(p)) out.add(p);
      }

      return out;
    });
