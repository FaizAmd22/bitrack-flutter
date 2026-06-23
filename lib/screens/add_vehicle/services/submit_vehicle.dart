// lib/screens/add_vehicle/services/submit_vehicle.dart
import 'package:ams/base/network/api_client.dart';
import 'package:ams/screens/add_vehicle/models/add_vehicle_form_data.dart';
import 'package:flutter/foundation.dart';

class SubmitVehicleResult {
  final bool success;
  final String? errorMsg;
  const SubmitVehicleResult({required this.success, this.errorMsg});
}

class SubmitVehicleService {
  const SubmitVehicleService();

  /// Bangun payload, sama seperti buildUpdateVehiclePayload di Cordova.
  Map<String, dynamic> _buildPayload(
    AddVehicleFormData d, {
    required String createdBy,
  }) {
    int? toNum(String? x) {
      if (x == null || x.trim().isEmpty) return null;
      return int.tryParse(x.trim());
    }

    String fmtDate(DateTime? dt) {
      if (dt == null) return '';
      String two(int v) => v.toString().padLeft(2, '0');
      return '${dt.year}-${two(dt.month)}-${two(dt.day)}';
    }

    return {
      'license_plate': d.plateNumber.trim(),
      'vin': d.vin.trim(),
      'vehicle_category': (d.vehicleCategory ?? '').trim(),

      // Cordova inject default ini
      'machine_number': '-',
      'end_points': 'TRACK_CPAAS_DEV',

      'vehicle_brand': (d.brand ?? '').trim(),
      'vehicle_model': (d.model ?? '').trim(),
      'vehicle_type': (d.type ?? '').trim(),
      'vehicle_year': toNum(d.year),
      'odometer': toNum(d.odometer),
      'fleet_group_id': (d.fleetGroupId ?? '').trim(),
      'created_by': createdBy,

      'device_type_code': d.deviceTypeCode.trim(),
      'device_model_code': (d.deviceModel ?? '').trim(),
      'simcard_number': d.simCardNumber.trim(),
      'imei_obd_number': d.imeiObdNumber.trim(),
      'installation_date': fmtDate(d.installationDate),
      'updated_by': DateTime.now().toIso8601String(),
    };
  }

  Future<SubmitVehicleResult> create(
    AddVehicleFormData data, {
    required String createdBy,
  }) async {
    final payload = _buildPayload(data, createdBy: createdBy);
    debugPrint('>>> create vehicle payload: $payload');
    final res = await ApiClient.dio.post('/mobile/vehicle', data: payload);
    return _parse(res.data);
  }

  Future<SubmitVehicleResult> update(
    AddVehicleFormData data, {
    required String id,
    required String createdBy,
  }) async {
    final payload = _buildPayload(data, createdBy: createdBy);
    debugPrint('>>> update vehicle payload: $payload');
    final res = await ApiClient.dio.put('/mobile/vehicle/$id', data: payload);
    return _parse(res.data);
  }

  SubmitVehicleResult _parse(dynamic body) {
    debugPrint('>>> submit response: $body');

    final status = body is Map ? body['status'] : null;
    final isFalse = status == false || status == 'false';

    debugPrint('>>> status=$status isFalse=$isFalse');

    if (isFalse) {
      final msg = body is Map ? body['error_msg']?.toString() : null;
      return SubmitVehicleResult(success: false, errorMsg: msg);
    }
    return const SubmitVehicleResult(success: true);
  }
}
