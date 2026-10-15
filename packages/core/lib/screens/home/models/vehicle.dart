/// Satu kendaraan di peta Home, dari `/monitoring/position`.
///
/// Parsing sengaja toleran: angka bisa datang sebagai string, field bisa
/// bernama beda antar-endpoint (`_id`/`id`, `direction`/`bearing`), dan nilai
/// kosong diganti default (0 / string kosong) supaya satu data rusak tidak
/// membuat seluruh peta gagal.
class Vehicle {
  final String id;
  final String vehicleId;
  final double latitude;
  final double longitude;
  /// Arah hadap kendaraan dalam derajat (0 = utara), untuk memutar ikon.
  final double bearing;

  /// Aktivitas dari server, huruf besar: `MOVING`, `IDLE`, `STOP`, dst.
  final String activity;

  /// Waktu data terakhir dari device GPS (string dari server).
  final String deviceTime;

  /// Status mesin: 1 = menyala, 0 = mati.
  final int ignition;
  final String licensePlate;
  final String fleetGroupName;
  /// URL ikon kategori kendaraan custom (boleh kosong), lihat
  /// [VehicleMarkerIcon].
  final String vehicleCategoryIcon;

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
    required this.vehicleCategoryIcon,
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

  /// Server bisa mengirim ignition sebagai angka, `"ON"`/`"OFF"`, atau
  /// string angka.
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
      vehicleCategoryIcon: (json['vehicle_category_icon'] ?? '').toString(),
    );
  }
}
