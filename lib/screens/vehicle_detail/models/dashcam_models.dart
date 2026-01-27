import 'dart:convert';

class DashcamConfig {
  final String type; // "METTAX" / "STONKAM"
  final String deviceId;
  final List<int> channels; // contoh: [0,1,2,3]

  const DashcamConfig({
    required this.type,
    required this.deviceId,
    required this.channels,
  });

  static DashcamConfig? fromVehicleDetail(Map<String, dynamic> vehicle) {
    final raw = vehicle['dashcam'];
    if (raw == null) return null;

    dynamic dashcam = raw;
    if (dashcam is String) {
      try {
        dashcam = jsonDecode(dashcam);
      } catch (_) {
        return null;
      }
    }
    if (dashcam is! Map) return null;

    final type = (dashcam['type'] ?? 'METTAX').toString().trim();
    final deviceId = (dashcam['device_id'] ?? '').toString().trim();

    final chRaw = dashcam['channels'];
    final channels = <int>[];
    if (chRaw is List) {
      for (final v in chRaw) {
        final n = int.tryParse('$v');
        if (n != null) channels.add(n);
      }
    }

    if (deviceId.isEmpty || channels.isEmpty) return null;

    return DashcamConfig(type: type, deviceId: deviceId, channels: channels);
  }
}
