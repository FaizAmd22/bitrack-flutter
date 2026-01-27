import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitrack_mobile_flutter/features/monitoring/providers/monitoring_providers.dart';
import 'package:bitrack_mobile_flutter/screens/home/models/vehicle.dart';

final plateSuggestionProvider = Provider.family<List<String>, String>((
  ref,
  activity,
) {
  final asyncVehicles = ref.watch(monitoringProvider(activity));
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
