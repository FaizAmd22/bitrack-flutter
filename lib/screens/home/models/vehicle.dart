class Vehicle {
  final String id;
  final String vehicleId;
  final double latitude;
  final double longitude;
  final double bearing;
  final String activity;
  final String deviceTime;
  final int ignition;
  final String licensePlate;
  final String fleetGroupName;

  const Vehicle({
    required this.id,
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    required this.bearing,
    required this.activity,
    required this.deviceTime,
    required this.ignition,
    required this.licensePlate,
    required this.fleetGroupName,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return 0.0;
      return double.tryParse(s) ?? 0.0;
    }
    return 0.0;
  }

  static int _toIgnition(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    final s = v.toString().trim().toUpperCase();
    if (s.isEmpty) return 0;
    if (s == 'ON') return 1;
    if (s == 'OFF') return 0;
    return int.tryParse(s) ?? 0;
  }

  static String _activityNormalize(dynamic v) {
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return '';
    return s.toUpperCase();
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      vehicleId: (json['vehicle_id'] ?? '').toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      bearing: _toDouble(json['direction'] ?? json['bearing']),
      activity: _activityNormalize(
        json['vehicle_activity'] ?? json['activity'],
      ),
      deviceTime: (json['device_time'] ?? '').toString(),
      ignition: _toIgnition(json['ignition']),
      licensePlate: (json['license_plate'] ?? '').toString(),
      fleetGroupName: (json['fleet_group_name'] ?? '').toString(),
    );
  }
}
