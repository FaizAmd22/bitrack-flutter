class AlertModel {
  final String? id;
  final String? licensePlate;
  final String? eventType;
  final String? eventName;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? deviceTime;
  final String? verifiedBy;
  final String? driverName;
  final String? fleetGroupName;
  final double? speed;
  final int? duration;
  final String? note;
  final List<String>? attachment;
  final String? noteValidation;
  final List<String>? attachmentValidation;
  final String? status;
  final String? statusText;
  final String? statusValidation;
  final String? statusValidationText;

  const AlertModel({
    this.id,
    this.licensePlate,
    this.eventType,
    this.eventName,
    this.latitude,
    this.longitude,
    this.address,
    this.deviceTime,
    this.verifiedBy,
    this.driverName,
    this.fleetGroupName,
    this.speed,
    this.duration,
    this.note,
    this.attachment,
    this.noteValidation,
    this.attachmentValidation,
    this.status,
    this.statusText,
    this.statusValidation,
    this.statusValidationText,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id']?.toString(),
      licensePlate: json['license_plate']?.toString(),
      eventType: json['event_type']?.toString(),
      eventName: (json['event'] ?? json['event_name'])?.toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      deviceTime:
          json['device_time']?.toString() ?? json['created_at']?.toString(),
      verifiedBy: json['verified_by']?.toString(),
      driverName: json['driver_name']?.toString(),
      fleetGroupName: json['fleet_group_name']?.toString(),
      speed: _toDouble(json['speed']),
      duration: _toInt(json['duration']),
      note: json['note']?.toString(),
      attachment: _toStringList(json['attachment']),
      noteValidation: json['note_validation']?.toString(),
      attachmentValidation: _toStringList(json['attachment_validation']),
      status: json['status']?.toString(),
      statusText: json['status_text']?.toString(),
      statusValidation: json['status_validation']?.toString(),
      statusValidationText: json['status_validation_text']?.toString(),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    return v is double ? v : double.tryParse(v.toString());
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    return v is int ? v : int.tryParse(v.toString());
  }

  // attachment bisa null, List, atau String tunggal
  static List<String>? _toStringList(dynamic v) {
    if (v == null) return null;
    if (v is List) {
      final out = v
          .map((e) => e?.toString() ?? '')
          .where((e) => e.trim().isNotEmpty)
          .toList();
      return out.isEmpty ? null : out;
    }
    if (v is String && v.trim().isNotEmpty) {
      return [v.trim()];
    }
    return null;
  }

  AlertModel copyWith({String? address}) {
    return AlertModel(
      id: id,
      licensePlate: licensePlate,
      eventType: eventType,
      eventName: eventName,
      latitude: latitude,
      longitude: longitude,
      address: address ?? this.address,
      deviceTime: deviceTime,
      verifiedBy: verifiedBy,
      driverName: driverName,
      fleetGroupName: fleetGroupName,
      speed: speed,
      duration: duration,
      note: note,
      attachment: attachment,
      noteValidation: noteValidation,
      attachmentValidation: attachmentValidation,
      status: status,
      statusText: statusText,
      statusValidation: statusValidation,
      statusValidationText: statusValidationText,
    );
  }
}
