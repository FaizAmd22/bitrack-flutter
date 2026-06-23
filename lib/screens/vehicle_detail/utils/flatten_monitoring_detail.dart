Map<String, dynamic> flattenMonitoringDetail(
  Map<String, dynamic> data, {
  String? detailId,
}) {
  final unit = (data['unit_detail'] as Map?)?.cast<String, dynamic>() ?? {};
  final live = (data['live_tracking'] as Map?)?.cast<String, dynamic>() ?? {};
  final speedMap = (data['speed'] as Map?)?.cast<String, dynamic>() ?? {};
  final sensor = (data['sensor'] as Map?)?.cast<String, dynamic>() ?? {};
  final fuelHistory = (data['fuel_consumption'] as List?) ?? [];

  num? latestFuel;
  if (fuelHistory.isNotEmpty) {
    final last = fuelHistory.last;
    if (last is Map) latestFuel = last['fuel_consumption'] as num?;
  }

  return {
    ...unit,
    ...live,
    if (detailId != null) 'vehicle_id': detailId,
    'speed': speedMap['speed'] ?? 0,
    'dleft': sensor['dleft'],
    'drear': sensor['drear'],
    'dright': sensor['dright'],
    'fuel_consumed': latestFuel ?? 0,
    'livecam': data['livecam'],
  };
}

Map<String, dynamic> flattenInformationStatus(Map<String, dynamic> data) {
  final status = (data['status'] as Map?)?.cast<String, dynamic>() ?? {};

  return {
    'internal_battery_voltage': status['internal_battery'],
    'external_power_voltage': status['external_battery'],
    'total_odometer': status['odometer'],
  };
}
