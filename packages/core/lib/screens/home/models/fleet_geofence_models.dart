class GeofenceItem {
  final String id;
  final String name;

  const GeofenceItem({required this.id, required this.name});

  factory GeofenceItem.fromJson(Map<String, dynamic> json) {
    return GeofenceItem(
      id: (json['geofence_id'] ?? '').toString(),
      name: (json['geofence_name'] ?? '').toString(),
    );
  }
}

class FleetGroupItem {
  final String id;
  final String name;
  final List<GeofenceItem> geofences;

  const FleetGroupItem({
    required this.id,
    required this.name,
    required this.geofences,
  });

  factory FleetGroupItem.fromJson(Map<String, dynamic> json) {
    final geos = (json['geofence'] is List)
        ? (json['geofence'] as List)
              .whereType<Map>()
              .map((e) => GeofenceItem.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
        : const <GeofenceItem>[];

    return FleetGroupItem(
      id: (json['fleet_group_id'] ?? json['id'] ?? '').toString(),
      name: (json['fleet_group_name'] ?? '').toString(),
      geofences: geos,
    );
  }
}

class FleetGeofenceResponse {
  final List<FleetGroupItem> data;

  const FleetGeofenceResponse({required this.data});

  factory FleetGeofenceResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = (raw is List)
        ? raw
              .whereType<Map>()
              .map((e) => FleetGroupItem.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
        : const <FleetGroupItem>[];

    return FleetGeofenceResponse(data: list);
  }
}
