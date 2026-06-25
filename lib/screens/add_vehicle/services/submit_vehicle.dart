// lib/screens/add_vehicle/services/submit_vehicle.dart
import 'package:ams/base/network/api_client.dart';
import 'package:ams/screens/add_vehicle/models/add_vehicle_form_data.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class SubmitVehicleResult {
  final bool success;
  final String? errorMsg;
  const SubmitVehicleResult({required this.success, this.errorMsg});
}

class SubmitVehicleService {
  const SubmitVehicleService();

  Map<String, dynamic> _buildPayload(AddVehicleFormData d) {
    int? toNum(String? x) {
      if (x == null || x.trim().isEmpty) return null;
      return int.tryParse(x.trim());
    }

    String? nullableType(String? x) {
      final s = (x ?? '').trim();
      return s.isEmpty ? null : s;
    }

    return {
      'license_plate': d.plateNumber.trim(),
      'vin': d.vin.trim(),
      'vehicle_type': nullableType(d.type),
      'machine_number': d.vin.trim(),
      'vehicle_color': "-",
      'vehicle_brand': (d.brand ?? '').trim(),
      'vehicle_year': d.year.trim(),
      'vehicle_model': (d.model ?? '').trim(),
      'device_type_code': d.deviceTypeCode.trim(),
      'stnk_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'fleet_group_id': (d.fleetGroupId ?? '').trim(),
      'installation_date': d.installationDate?.toIso8601String(),
      'vehicle_category': (d.vehicleCategory ?? '').trim(),
      'vehicle_category_sensor': "-",
      'status': 1,
      'msaccuvehicle_id': "4741CC60-64F0-11EF-A677-B7D8EEDE7787",
      'odometer': toNum(d.odometer),
      'imei_obd_number': d.imeiObdNumber.trim(),
      'simcard_number': d.simCardNumber.trim(),
      'fuel_ratio': "0",
      'device_model_code': (d.deviceModel ?? '').trim(),
      'device_group_code': d.deviceTypeCode.trim(),
      'driver_name': null,
      'driver_phone': null,
      'driver_code': null,
      'kir': null,
    };
  }

  Future<SubmitVehicleResult> create(AddVehicleFormData data) async {
    final payload = _buildPayload(data);
    debugPrint('>>> create vehicle payload: $payload');
    final res = await ApiClient.dio.post('/master-vehicle/', data: payload);
    return _parse(res.data);
  }

  Future<SubmitVehicleResult> update(
    AddVehicleFormData data, {
    required String id,
  }) async {
    final payload = _buildPayload(data);
    debugPrint('>>> update vehicle payload: $payload');
    final res = await ApiClient.dio.put('/master-vehicle/$id', data: payload);
    return _parse(res.data);
  }

  SubmitVehicleResult _parse(dynamic body) {
    debugPrint('>>> submit response: $body');

    final status = body is Map ? body['status'] : null;
    final isFalse = status == false || status == 'false';

    debugPrint('>>> status=$status isFalse=$isFalse');

    if (isFalse) {
      final msg = body is Map
          ? (body['message'] ?? body['error_msg'])?.toString()
          : null;
      return SubmitVehicleResult(success: false, errorMsg: msg);
    }
    return const SubmitVehicleResult(success: true);
  }
}
