import 'dart:convert';

import 'package:ams/base/network/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

const _alertConfigMapping = {
  'accident': 'CRASH',
  'accu_low': 'ACCU_LOW',
  'accu_high': 'ACCU_HIGH',
  'geofence_in': 'GEO_IN',
  'geofence_out': 'GEO_OUT',
  'overstay_engine_on': 'OVERSTAY_ENGINE_ON',
  'overstay_engine_off': 'OVERSTAY_ENGINE_OFF',
  'main_battery_disconnected': 'MB_CN',
  'smoking': 'smoking',
  'seatbelt': 'seatbelt',
  'occlusion': 'occlusion',
  'overspeed': 'OVERSPEED',
  'fatigueWarn': 'fatigueWarn',
  'harsh_break': 'HARSH_BRK',
  'driverChange': 'driverChange',
  'fatigueAlarm': 'fatigueAlarm',
  'matching_fail': 'Matching Fail',
  'identification': 'identification',
  'towing_detected': 'TOWING_DETECTED',
  'handheldPhoneCall': 'handheldPhoneCall',
  'harsh_acceleration': 'harsh_acceleration',
  'longTimeWithoutLookingAhead': 'longTimeWithoutLookingAhead',
};

class NotificationService {
  final _storage = const FlutterSecureStorage();
  final _fmt = DateFormat('yyyy-MM-dd HH:mm:ss');

  // Cache credentials
  String _userId = '';
  String? _permJson;
  bool _credLoaded = false;

  Future<void> _ensureCredentials() async {
    if (_credLoaded && _userId.isNotEmpty) return;
    try {
      final id =
          await _storage
              .read(key: 'user_id')
              .timeout(const Duration(seconds: 5), onTimeout: () => null) ??
          '';
      final perm = await _storage
          .read(key: 'user_role_permission')
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      _userId = id;
      _permJson = perm;
      _credLoaded = id.isNotEmpty;
      debugPrint('>>> creds loaded: userId="$_userId"');
    } catch (e) {
      debugPrint('>>> creds error: $e');
    }
  }

  String _fmtDate(DateTime dt) => _fmt.format(dt);

  List<String> _buildAlertConfig(String? permJson) {
    if (permJson == null || permJson.trim().isEmpty) return [];
    try {
      final parsed = jsonDecode(permJson);
      if (parsed is! Map) return [];
      final urgent = (parsed['alert']?['urgent']) as Map? ?? {};
      final summary = (parsed['alert']?['summary']) as Map? ?? {};
      final keys = [
        ...urgent.entries
            .where((e) => e.value == true)
            .map((e) => e.key.toString()),
        ...summary.entries
            .where((e) => e.value == true)
            .map((e) => e.key.toString()),
      ];
      return keys.map((k) => _alertConfigMapping[k] ?? k).toList();
    } catch (e) {
      debugPrint('_buildAlertConfig error: $e');
      return [];
    }
  }

  // Safely extract the items array from various response shapes:
  // { data: { data: [...] } }  ← Laravel paginated
  // { data: [...] }            ← flat
  // [...]                      ← raw array
  List<dynamic> _parseItems(dynamic body) {
    try {
      if (body is Map) {
        final d = body['data'];
        if (d is List) return d;
        if (d is Map) {
          final items = d['data'];
          if (items is List) return items;
        }
      }
      if (body is List) return body;
    } catch (e) {
      debugPrint('_parseItems error: $e');
    }
    return [];
  }

  Map<String, dynamic> _buildParams({
    required int page,
    required String userId,
    required List<String> alertConfig,
    required DateTime start,
    required DateTime end,
    String? eventType,
    String? fleetGroupId,
    String? statusVerified,
    String? licensePlate,
  }) {
    final params = <String, dynamic>{
      'start_date': _fmtDate(start),
      'end_date': _fmtDate(end),
      'limit': 10,
      'page': page,
      'fleet_group_id': fleetGroupId ?? userId,
      'alert_config': jsonEncode(alertConfig),
    };
    if (eventType != null && eventType.isNotEmpty) {
      params['event_type'] = eventType;
    }
    if (statusVerified != null && statusVerified.isNotEmpty) {
      params['status_verified'] = statusVerified;
    }
    if (licensePlate != null && licensePlate.trim().isNotEmpty) {
      params['license_plate'] = licensePlate.trim();
    }
    return params;
  }

  // static const _storageTimeout = Duration(seconds: 5);

  // Future<String?> _readStorage(String key) =>
  //     _storage.read(key: key).timeout(_storageTimeout, onTimeout: () => null);

  Future<List<dynamic>> fetchAlertUrgent({
    required int page,
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
    String? fleetGroupId,
    String? statusVerified,
    String? licensePlate,
  }) async {
    try {
      await _ensureCredentials(); // ← satu kali saja, hasil di-cache

      final alertConfig = _buildAlertConfig(_permJson);

      debugPrint('>>> permJson: $_permJson');
      debugPrint('>>> alertConfig built: $alertConfig');
      final now = DateTime.now();
      final start =
          startDate ?? DateTime(now.year, now.month, now.day, 0, 0, 1);
      final end = endDate ?? DateTime(now.year, now.month, now.day, 23, 59, 0);

      final params = _buildParams(
        page: page,
        userId: _userId, // ← pakai cache
        alertConfig: alertConfig,
        start: start,
        end: end,
        eventType: eventType,
        fleetGroupId: fleetGroupId,
        statusVerified: statusVerified,
        licensePlate: licensePlate,
      );

      debugPrint('>>> URGENT params: $params');

      final res = await ApiClient.dio.get(
        '/mw-mapping-alert/alert',
        queryParameters: params,
      );

      debugPrint('>>> URGENT raw response: ${res.data}');

      final items = _parseItems(res.data);
      return items;
    } catch (e) {
      debugPrint('fetchAlertUrgent error: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchAlertSummary({
    required int page,
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
    String? fleetGroupId,
    String? statusVerified,
    String? licensePlate,
  }) async {
    try {
      await _ensureCredentials(); // ← cache, tidak baca ulang storage

      final alertConfig = _buildAlertConfig(_permJson);

      final now = DateTime.now();
      final start =
          startDate ?? DateTime(now.year, now.month, now.day, 0, 0, 1);
      final end = endDate ?? DateTime(now.year, now.month, now.day, 23, 59, 0);

      final params = _buildParams(
        page: page,
        userId: _userId, // ← pakai cache
        alertConfig: alertConfig,
        start: start,
        end: end,
        eventType: eventType,
        fleetGroupId: fleetGroupId,
        statusVerified: statusVerified,
        licensePlate: licensePlate,
      );

      final res = await ApiClient.dio.get(
        '/mw-mapping-alert-summary',
        queryParameters: params,
      );

      final items = _parseItems(res.data);
      return items;
    } catch (e) {
      debugPrint('fetchAlertSummary error: $e');
      return [];
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _ensureCredentials();
      await ApiClient.dio.post(
        '/mw-mapping-alert/mark-all-as-read',
        data: {'user_id': _userId, 'fleet_group_ids': _userId},
      );
    } catch (e) {
      debugPrint('markAllAsRead error: $e');
    }
  }

  void clearCache() {
    _userId = '';
    _permJson = null;
    _credLoaded = false;
  }
}
