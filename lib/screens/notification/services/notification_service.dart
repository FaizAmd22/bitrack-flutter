import 'package:ams/base/network/api_client.dart';
import 'package:ams/screens/notification/models/alert_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class AlertPageResult {
  final List<dynamic> items;
  final int page;
  final int totalPages;
  final int total;

  const AlertPageResult({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.total,
  });
}

class NotificationService {
  final _storage = const FlutterSecureStorage();
  final _fmt = DateFormat('yyyy-MM-dd HH:mm:ss');

  static const _limit = 20;

  String _fmtDate(DateTime dt) => _fmt.format(dt);

  Future<AlertPageResult> fetchAlerts({
    required int page,
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
    String? fleetGroupId,
    String? status,
    String? licensePlate,
  }) async {
    try {
      final now = DateTime.now();
      final start =
          startDate ?? DateTime(now.year, now.month, now.day, 0, 0, 1);
      final end = endDate ?? DateTime(now.year, now.month, now.day, 23, 59, 59);

      final params = <String, dynamic>{
        'date_start': _fmtDate(start),
        'date_end': _fmtDate(end),
        'page': page,
        'limit': _limit,
        if (status != null && status.isNotEmpty) 'status': status,
        if (fleetGroupId != null && fleetGroupId.isNotEmpty)
          'fleet_group_id': fleetGroupId,
        if (licensePlate != null && licensePlate.trim().isNotEmpty)
          'license_plate': licensePlate.trim(),
        if (eventType != null && eventType.isNotEmpty)
          'event_type': eventType,
      };

      final res = await ApiClient.dio.get(
        '/transaction-alert/',
        queryParameters: params,
      );

      final body = res.data;
      final items = (body is Map && body['data'] is List)
          ? body['data'] as List
          : <dynamic>[];

      final metadata = body is Map ? body['metadata'] : null;
      final pagination = metadata is Map ? metadata['pagination'] : null;
      final totalPages = (pagination is Map && pagination['totalPages'] is num)
          ? (pagination['totalPages'] as num).toInt()
          : page;
      final total = (pagination is Map && pagination['total'] is num)
          ? (pagination['total'] as num).toInt()
          : items.length;

      return AlertPageResult(
        items: items,
        page: page,
        totalPages: totalPages,
        total: total,
      );
    } catch (e) {
      debugPrint('fetchAlerts error: $e');
      return AlertPageResult(
        items: const [],
        page: page,
        totalPages: page,
        total: 0,
      );
    }
  }

  Future<AlertModel?> fetchAlertDetail(String id) async {
    try {
      final res = await ApiClient.dio.get('/transaction-alert/$id');
      final body = res.data;
      if (body is! Map || body['data'] is! Map) return null;

      return AlertModel.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } catch (e) {
      debugPrint('fetchAlertDetail error: $e');
      return null;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final userId = await _storage.read(key: 'user_id') ?? '';
      await ApiClient.dio.post(
        '/mw-mapping-alert/mark-all-as-read',
        data: {'user_id': userId, 'fleet_group_ids': userId},
      );
    } catch (e) {
      debugPrint('markAllAsRead error: $e');
    }
  }
}
