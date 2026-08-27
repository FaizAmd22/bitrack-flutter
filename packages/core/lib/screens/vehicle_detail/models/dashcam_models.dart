import 'dart:convert';

class DashcamConfig {
  final String type; // 'METTAX' | 'STONKAM'
  final String deviceId;
  final List<int> channels; // contoh: [0, 1, 2, 3]

  const DashcamConfig({
    required this.type,
    required this.deviceId,
    required this.channels,
  });

  /// Parse dari JSON langsung (misal dari API response body).
  factory DashcamConfig.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] ?? 'METTAX').toString().trim();
    final deviceId = (json['device_id'] ?? '').toString().trim();
    final channels = _parseChannels(json['channels']);
    return DashcamConfig(type: type, deviceId: deviceId, channels: channels);
  }

  /// Parse dari vehicle map hasil API (field `dashcam` bisa String atau Map).
  /// Return null jika data tidak valid (deviceId kosong atau tidak ada channel).
  static DashcamConfig? fromVehicleDetail(Map<String, dynamic> vehicle) {
    final raw = vehicle['dashcam'];
    if (raw == null) return null;

    Map<String, dynamic> dashcam;
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map) return null;
        dashcam = Map<String, dynamic>.from(decoded);
      } catch (_) {
        return null;
      }
    } else if (raw is Map) {
      dashcam = Map<String, dynamic>.from(raw);
    } else {
      return null;
    }

    final type = (dashcam['type'] ?? 'METTAX').toString().trim();
    final deviceId = (dashcam['device_id'] ?? '').toString().trim();
    final channels = _parseChannels(dashcam['channels']);

    if (deviceId.isEmpty || channels.isEmpty) return null;

    return DashcamConfig(type: type, deviceId: deviceId, channels: channels);
  }

  static List<int> _parseChannels(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => int.tryParse('$e')).whereType<int>().toList();
  }
}
