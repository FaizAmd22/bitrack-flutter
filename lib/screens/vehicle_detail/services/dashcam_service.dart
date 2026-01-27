import 'dart:convert';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/services/mettaxiot_stream_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bitrack_mobile_flutter/base/network/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DashcamStatusResult {
  final bool hasDashcam;
  final bool isStreamAvailable;
  final bool isChiller;
  final String? deviceId;
  final String? streamUrl;
  final String? errorMessage;

  const DashcamStatusResult({
    required this.hasDashcam,
    required this.isStreamAvailable,
    required this.isChiller,
    this.deviceId,
    this.streamUrl,
    this.errorMessage,
  });
}

class DashcamService {
  DashcamService({Dio? dashcamDio}) : _dashcamDio = dashcamDio ?? Dio();

  final Dio _api = ApiClient.dio;
  final Dio _dashcamDio;

  Map<String, dynamic> _asMap(dynamic v) {
    if (v == null) return <String, dynamic>{};
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    if (v is String) {
      try {
        final decoded = jsonDecode(v);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _unwrapVehicle(dynamic raw) {
    final m = _asMap(raw);
    if (m.isEmpty) return <String, dynamic>{};

    final inner = m['data'];
    if (inner == null) return m;

    final innerMap = _asMap(inner);

    if (innerMap['data'] is Map || innerMap['data'] is String) {
      final inner2 = _asMap(innerMap['data']);
      if (inner2.isNotEmpty) return inner2;
    }

    return innerMap.isNotEmpty ? innerMap : m;
  }

  String _getDeviceIdFromDashcam(dynamic dashcam) {
    final m = _asMap(dashcam);
    if (m.isEmpty) return '';

    final id1 = (m['device_id'] ?? '').toString().trim();
    if (id1.isNotEmpty) return id1;

    final id2 = (m['deviceId'] ?? '').toString().trim();
    if (id2.isNotEmpty) return id2;

    final deviceNested = _asMap(m['device']);
    final id3 = (deviceNested['device_id'] ?? deviceNested['deviceId'] ?? '')
        .toString()
        .trim();
    return id3;
  }

  Future<Map<String, dynamic>> fetchVehicle(String vehicleId) async {
    final res = await _api.get('/vehicle/$vehicleId');
    final raw = res.data;
    final vehicle = _unwrapVehicle(raw);

    debugPrint('METTAXIOT_VIDEO = ${dotenv.env['METTAXIOT_VIDEO']}');
    debugPrint(
      'METTAXIOT_CREATE_TOKEN = ${dotenv.env['METTAXIOT_CREATE_TOKEN']}',
    );

    debugPrint('fetchVehicle vehicle keys: ${vehicle.keys}');
    debugPrint(
      'fetchVehicle dashcam runtimeType: ${vehicle['dashcam']?.runtimeType}',
    );
    debugPrint('fetchVehicle dashcam value: ${vehicle['dashcam']}');

    return vehicle;
  }

  Future<String> createToken() async {
    final res = await _api.post('/dashcam/token');
    dynamic raw = res.data;

    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {}
    }

    final m = _asMap(raw);
    if (m.isEmpty) return '';

    final t1 = (m['token'] ?? '').toString().trim();
    if (t1.isNotEmpty) return t1;

    final d = _asMap(m['data']);
    final t2 = (d['token'] ?? '').toString().trim();
    if (t2.isNotEmpty) return t2;

    return '';
  }

  Future<DashcamStatusResult> checkDashcamStream({
    required String vehicleId,
  }) async {
    String deviceId = '';
    bool hasDashcam = false;
    bool isChiller = false;

    try {
      final vehicle = await fetchVehicle(vehicleId);
      final category = (vehicle['vehicle_category'] ?? '').toString().trim();
      isChiller = category.toLowerCase() == 'chiller';

      final dashcam = vehicle['dashcam'];
      final dashcamMap = _asMap(dashcam);
      final mettax = MettaxiotStreamService.I;

      hasDashcam = dashcam != null && (dashcam is Map || dashcamMap.isNotEmpty);
      deviceId = _getDeviceIdFromDashcam(dashcam);

      if (!hasDashcam) {
        return DashcamStatusResult(
          hasDashcam: false,
          isStreamAvailable: false,
          isChiller: isChiller,
        );
      }

      if (deviceId.isEmpty) {
        return DashcamStatusResult(
          hasDashcam: true,
          isStreamAvailable: false,
          isChiller: isChiller,
          deviceId: null,
          errorMessage: 'device_id kosong',
        );
      }

      final token = await createToken();
      if (token.isEmpty) {
        return DashcamStatusResult(
          hasDashcam: true,
          isStreamAvailable: false,
          isChiller: isChiller,
          deviceId: deviceId,
          errorMessage: 'Token kosong',
        );
      }

      final payload = {
        "deviceId": deviceId,
        "channelId": 1,
        "bitstreamType": 0,
      };

      final url = (dotenv.env['API_METTAXIOT_URL'] ?? '').toString().trim();
      if (url.isEmpty) {
        return DashcamStatusResult(
          hasDashcam: true,
          isStreamAvailable: false,
          isChiller: isChiller,
          deviceId: deviceId,
          errorMessage: 'API_METTAXIOT_URL kosong',
        );
      }

      final res = await _dashcamDio.post(
        url,
        data: payload,
        options: Options(
          headers: {'Content-Type': 'application/json', 'Authorization': token},
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (code) => code != null && code >= 200 && code < 400,
        ),
      );

      dynamic body = res.data;
      if (body is String) {
        try {
          body = jsonDecode(body);
        } catch (_) {}
      }

      final stream = await mettax.getLiveStreamUrl(
        deviceId: deviceId,
        channelId: 0,
      );

      return DashcamStatusResult(
        hasDashcam: true,
        isStreamAvailable: stream.trim().isNotEmpty,
        isChiller: isChiller,
        deviceId: deviceId,
        streamUrl: stream,
      );
    } on DioException catch (e) {
      debugPrint('checkDashcamStream DioException: ${e.message}');
      return DashcamStatusResult(
        hasDashcam: hasDashcam,
        isStreamAvailable: false,
        isChiller: isChiller,
        deviceId: deviceId.isEmpty ? null : deviceId,
        errorMessage: 'DioException ${e.response?.statusCode}: ${e.message}',
      );
    } catch (e) {
      debugPrint('checkDashcamStream error: $e');
      return DashcamStatusResult(
        hasDashcam: hasDashcam,
        isStreamAvailable: false,
        isChiller: isChiller,
        deviceId: deviceId.isEmpty ? null : deviceId,
        errorMessage: e.toString(),
      );
    }
  }
}
