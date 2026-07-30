import 'dart:math' as math;

// Data dummy untuk mode demo (lihat demo_mode.dart). Bentuknya meniru
// persis response API asli supaya model/parsing existing tetap jalan
// tanpa perubahan.
class DemoData {
  DemoData._();

  // Satu wakil untuk tiap kategori aktivitas di ActivityChips
  // (lib/screens/home/widgets/activity_chips.dart: allVehicle, inOperation,
  // moving, idle, stop, silence, repair) supaya filter chip & search benar
  // menyaring, bukan selalu menampilkan semua kendaraan.
  static const _vehicles = [
    {
      'id': 'demo-vehicle-1',
      'license_plate': 'B-1234-DEM',
      'fleet_group_id': 'demo-fleet-group',
      'fleet_group_name': 'PT. Demo Logistik',
      'vehicle_category': 'TRUCK',
      'vehicle_activity': 'MOVING',
      'in_operation': true,
      'ignition': 1,
      'speed': 42,
      'direction': 120,
      'latitude': -6.2088,
      'longitude': 106.8456,
      'fuel_level': 85,
      'odometer': 125430.5,
    },
    {
      'id': 'demo-vehicle-2',
      'license_plate': 'B-5678-DEM',
      'fleet_group_id': 'demo-fleet-group',
      'fleet_group_name': 'PT. Demo Logistik',
      'vehicle_category': 'CHILLER',
      'vehicle_activity': 'STOP',
      'in_operation': false,
      'ignition': 0,
      'speed': 0,
      'direction': 45,
      'latitude': -6.2246,
      'longitude': 106.8006,
      'fuel_level': 60,
      'odometer': 87210.2,
    },
    {
      'id': 'demo-vehicle-3',
      'license_plate': 'B-9012-DEM',
      'fleet_group_id': 'demo-fleet-group',
      'fleet_group_name': 'PT. Demo Logistik',
      'vehicle_category': 'TRUCK',
      'vehicle_activity': 'IDLE',
      'in_operation': true,
      'ignition': 1,
      'speed': 0,
      'direction': 270,
      'latitude': -6.1944,
      'longitude': 106.8229,
      'fuel_level': 40,
      'odometer': 203980.0,
    },
    {
      'id': 'demo-vehicle-4',
      'license_plate': 'B-3456-DEM',
      'fleet_group_id': 'demo-fleet-group',
      'fleet_group_name': 'PT. Demo Logistik',
      'vehicle_category': 'TRUCK',
      'vehicle_activity': 'SILENCE',
      'in_operation': false,
      'ignition': 0,
      'speed': 0,
      'direction': 300,
      'latitude': -6.2153,
      'longitude': 106.8317,
      'fuel_level': 55,
      'odometer': 152340.0,
    },
    {
      'id': 'demo-vehicle-5',
      'license_plate': 'B-7890-DEM',
      'fleet_group_id': 'demo-fleet-group',
      'fleet_group_name': 'PT. Demo Logistik',
      'vehicle_category': 'TRUCK',
      'vehicle_activity': 'REPAIR',
      'in_operation': false,
      'ignition': 0,
      'speed': 0,
      'direction': 0,
      'latitude': -6.1802,
      'longitude': 106.7998,
      'fuel_level': 20,
      'odometer': 301200.0,
    },
  ];

  static Iterable<Map<String, dynamic>> _byActivity(String activity) {
    if (activity.isEmpty) return _vehicles;
    if (activity == 'IN_OPERATION') {
      return _vehicles.where((v) => v['in_operation'] == true);
    }
    return _vehicles.where((v) => v['vehicle_activity'] == activity);
  }

  static String _deviceTime([int minutesAgo = 2]) {
    final t = DateTime.now().subtract(Duration(minutes: minutesAgo));
    return t.toIso8601String().substring(0, 19).replaceFirst('T', ' ');
  }

  // [activity] adalah kode server (MOVING/IDLE/STOP/SILENCE/REPAIR/
  // IN_OPERATION) atau '' untuk semua kendaraan, hasil dari
  // MonitoringApi._activityParam. summary dihitung dari seluruh armada
  // (bukan hasil yang sudah difilter) supaya cocok dengan totalVehicle yang
  // ditampilkan ActivityChips untuk tiap chip.
  static Map<String, dynamic> monitoringStatusList({String activity = ''}) {
    final filtered = _byActivity(activity);

    int countBy(bool Function(Map<String, dynamic> v) test) =>
        _vehicles.where(test).length;

    return {
      'status': 'success',
      'message': 'OK',
      'data': filtered
          .map(
            (v) => {
              '_id': v['id'],
              'fleet_group_id': v['fleet_group_id'],
              'fleet_group_name': v['fleet_group_name'],
              'license_plate': v['license_plate'],
              'vehicle_id': v['id'],
              'fuel_consumed': 0,
              'dallas_temperature_1': 25.0,
              'dallas_temperature_2': null,
              'dallas_temperature_3': null,
              'dallas_temperature_4': null,
              'device_time': _deviceTime(),
              'fuel_level_1_x': v['fuel_level'],
              'in_operation': v['in_operation'],
              'internal_battery_voltage': 4.05,
              'speed': v['speed'],
              'vehicle_activity': v['vehicle_activity'],
            },
          )
          .toList(),
      'metadata': {
        'has_more': false,
        'next_cursor': null,
        'summary': {
          'ALL': _vehicles.length,
          'MOVING': countBy((v) => v['vehicle_activity'] == 'MOVING'),
          'IDLE': countBy((v) => v['vehicle_activity'] == 'IDLE'),
          'STOP': countBy((v) => v['vehicle_activity'] == 'STOP'),
          'SILENCE': countBy((v) => v['vehicle_activity'] == 'SILENCE'),
          'REPAIR': countBy((v) => v['vehicle_activity'] == 'REPAIR'),
          'IN_OPERATION': countBy((v) => v['in_operation'] == true),
        },
      },
    };
  }

  // [licensePlate] dicocokkan seperti pencarian search bar (contains,
  // case-insensitive), [fleetGroupId] exact match.
  static Map<String, dynamic> monitoringPositionList({
    String? licensePlate,
    String? fleetGroupId,
  }) {
    Iterable<Map<String, dynamic>> filtered = _vehicles;

    if (licensePlate != null && licensePlate.trim().isNotEmpty) {
      final q = licensePlate.trim().toUpperCase();
      filtered = filtered.where(
        (v) => (v['license_plate'] as String).toUpperCase().contains(q),
      );
    }

    if (fleetGroupId != null && fleetGroupId.isNotEmpty) {
      filtered = filtered.where((v) => v['fleet_group_id'] == fleetGroupId);
    }

    return {
      'status': true,
      'message': 'Vehicle positions retrieved successfully',
      'data': filtered
          .map(
            (v) => {
              'id': v['id'],
              'license_plate': v['license_plate'],
              'latitude': v['latitude'],
              'longitude': v['longitude'],
              'direction': v['direction'],
              'vehicle_activity': v['vehicle_activity'],
              'device_time': _deviceTime(),
              'ignition': v['ignition'],
              'fleet_group_name': v['fleet_group_name'],
              'fuel_capacity': v['fuel_level'],
              'odometer': v['odometer'],
              'vehicle_id': v['id'],
              'speed': v['speed'],
              'vehicle_category': v['vehicle_category'],
            },
          )
          .toList(),
      'metadata': {},
    };
  }

  // Shape nested ini meniru persis response asli /monitoring/{id} sebelum
  // di-flatten oleh flattenMonitoringDetail/flattenInformationStatus (lihat
  // lib/screens/vehicle_detail/utils/flatten_monitoring_detail.dart) — kalau
  // dibuat flat langsung, hasil flatten-nya jadi kosong karena field yang
  // dibaca ada di dalam unit_detail/live_tracking/speed/sensor/status.
  // Sengaja tidak menyertakan key `livecam` supaya tombol Dashcam di
  // vehicle_detail.dart otomatis nonaktif (lihat hasDashcam di sana).
  static Map<String, dynamic> vehicleDetail(String id) {
    final v = _vehicles.firstWhere(
      (e) => e['id'] == id,
      orElse: () => _vehicles.first,
    );

    return {
      'unit_detail': {
        'license_plate': v['license_plate'],
        'vehicle_model': v['vehicle_category'],
        'fleet_group_name': v['fleet_group_name'],
        'driver_name': 'Demo Driver',
        'imei': '000000000000000',
        'chiller': v['vehicle_category'] == 'CHILLER',
      },
      'live_tracking': {
        'latitude': v['latitude'],
        'longitude': v['longitude'],
        'direction': v['direction'],
        'vehicle_activity': v['vehicle_activity'],
        'device_time': _deviceTime(),
        'ignition': v['ignition'],
      },
      'speed': {'speed': v['speed']},
      'sensor': {
        'dleft': 'CLOSE',
        'drear': 'CLOSE',
        'dright': 'CLOSE',
        'temperature': 25.0,
      },
      'fuel_consumption': [
        {'fuel_consumption': v['fuel_level']},
      ],
      'status': {
        'internal_battery': 4.05,
        'external_battery': 92,
        'odometer': v['odometer'],
      },
    };
  }

  static String address() => 'Jl. Jendral Sudirman, Jakarta Selatan (Demo)';

  // Shape mengikuti VehiclePage.fromResponse (lib/screens/vehicle/models/vehicle_page.dart)
  // dan field yang dibaca card_vehicle.dart (id, license_plate, brand, model,
  // year, status, created_at, fleet_group.name).
  static Map<String, dynamic> vehicleList() {
    return {
      'status': true,
      'message': 'OK',
      'data': _vehicles
          .map(
            (v) => {
              'id': v['id'],
              'license_plate': v['license_plate'],
              'brand': 'Demo',
              'model': v['vehicle_category'],
              'year': '2024',
              'status': 'active',
              'created_at': _deviceTime(0),
              'fleet_group': {'name': v['fleet_group_name']},
            },
          )
          .toList(),
      'metadata': {
        'pagination': {'page': 1, 'totalPages': 1, 'total': _vehicles.length},
      },
    };
  }

  // Shape value/label, dipakai langsung sebagai FilterOption di
  // notification_screen.dart dan sejenisnya.
  static List<Map<String, dynamic>> fleetGroupList() {
    return const [
      {'value': 'demo-fleet-group', 'label': 'PT. Demo Logistik'},
    ];
  }

  static List<Map<String, dynamic>> alertTypes() {
    return const [
      {'value': 'OVERSPEED', 'label': 'Overspeed'},
      {'value': 'ENGINE_OFF', 'label': 'Engine Off'},
    ];
  }

  // Shape mengikuti AlertModel.fromJson (lib/screens/notification/models/alert_model.dart).
  static List<Map<String, dynamic>> notificationAlerts() {
    return [
      {
        'id': 'demo-alert-1',
        'license_plate': 'B-1234-DEM',
        'event_type': 'OVERSPEED',
        'event': 'Overspeed',
        'latitude': -6.2088,
        'longitude': 106.8456,
        'device_time': _deviceTime(10),
        'driver_name': 'Demo Driver',
        'fleet_group_name': 'PT. Demo Logistik',
        'speed': 82.0,
        'status': 'unread',
        'status_text': 'Unread',
      },
      {
        'id': 'demo-alert-2',
        'license_plate': 'B-9012-DEM',
        'event_type': 'ENGINE_OFF',
        'event': 'Engine Idle Too Long',
        'latitude': -6.1944,
        'longitude': 106.8229,
        'device_time': _deviceTime(45),
        'driver_name': 'Demo Driver',
        'fleet_group_name': 'PT. Demo Logistik',
        'duration': 35,
        'status': 'read',
        'status_text': 'Read',
      },
    ];
  }

  // Shape mengikuti PeriodicPoint.fromJson (lib/screens/periodic_track/models/periodic_point.dart).
  // Jalur pendek zig-zag di sekitar koordinat dasar kendaraan, tersebar rata
  // di rentang startDate-endDate, dengan satu event OVERSPEED di tengah
  // supaya chart/marker event terlihat ada isinya.
  static List<Map<String, dynamic>> periodicPoints({
    required String licensePlate,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final v = _vehicles.firstWhere(
      (e) => e['license_plate'] == licensePlate,
      orElse: () => _vehicles.first,
    );

    const pointCount = 24;
    final totalMinutes = endDate.difference(startDate).inMinutes;
    final stepMinutes = totalMinutes > 0 ? totalMinutes / pointCount : 5.0;

    final baseLat = (v['latitude'] as num).toDouble();
    final baseLng = (v['longitude'] as num).toDouble();
    var fuel = (v['fuel_level'] as num).toDouble();
    final overspeedIndex = pointCount ~/ 2;

    return List.generate(pointCount, (i) {
      final t = startDate.add(Duration(minutes: (stepMinutes * i).round()));
      final progress = i / (pointCount - 1);
      final isEdge = i == 0 || i == pointCount - 1;
      final isOverspeed = i == overspeedIndex;

      fuel = (fuel - 0.3).clamp(0, 100);

      return {
        'latitude': baseLat + 0.01 * math.sin(progress * math.pi * 2),
        'longitude': baseLng + 0.01 * progress,
        'device_time': _formatDateTime(t),
        'speed': isEdge ? 0.0 : (isOverspeed ? 95.0 : 40 + 20 * progress),
        'ignition': isEdge ? 0 : 1,
        'external_power_voltage': 12.6,
        'fuel_level_1_x': fuel,
        'dallas_temperature_1': 25.0,
        'dallas_temperature_2': 24.0,
        'event_type': isOverspeed ? 'OVERSPEED' : 'SAMPLING',
        'event': isOverspeed ? 'Overspeed' : null,
      };
    });
  }

  static String _formatDateTime(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}
