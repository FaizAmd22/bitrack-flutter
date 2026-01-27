class PeriodicPoint {
  final double latitude;
  final double longitude;
  final String deviceTime;

  final double speed;
  final bool ignition;
  final double externalPowerVoltage;
  final double fuelLevel;
  final double dallasTemp1;
  final double dallasTemp2;

  final String eventType; // "SAMPLING" atau alert
  final String eventName;

  const PeriodicPoint({
    required this.latitude,
    required this.longitude,
    required this.deviceTime,
    required this.speed,
    required this.ignition,
    required this.externalPowerVoltage,
    required this.fuelLevel,
    required this.dallasTemp1,
    required this.dallasTemp2,
    required this.eventType,
    required this.eventName,
  });

  factory PeriodicPoint.fromJson(Map<String, dynamic> json) {
    double toD(dynamic v) =>
        (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0;

    return PeriodicPoint(
      latitude: toD(json['latitude']),
      longitude: toD(json['longitude']),
      deviceTime: (json['device_time'] ?? '').toString(),
      speed: toD(json['speed']),
      ignition:
          (json['ignition'] == true ||
          json['ignition'] == 1 ||
          json['ignition'] == '1'),
      externalPowerVoltage: toD(json['external_power_voltage']),
      fuelLevel: toD(json['fuel_level_1_x']),
      dallasTemp1: toD(json['dallas_temperature_1']),
      dallasTemp2: toD(json['dallas_temperature_2']),
      eventType: (json['event_type'] ?? 'SAMPLING').toString(),
      eventName: (json['event_name'] ?? '').toString(),
    );
  }
}
