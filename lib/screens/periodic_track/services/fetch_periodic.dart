import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/periodic_point.dart';

class PeriodicApi {
  final Dio dio;
  PeriodicApi(this.dio);

  Future<List<PeriodicPoint>> fetchPeriodic({
    required DateTime startDate,
    required DateTime endDate,
    required String licensePlate,
  }) async {
    final params = {
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
      'license_plate': licensePlate,
    };

    final res = await dio.get('/mw-mapping-history', queryParameters: params);

    final list = _extractList(res.data);

    return list
        .map((e) {
          try {
            return PeriodicPoint.fromJson(Map<String, dynamic>.from(e as Map));
          } catch (err) {
            debugPrint('periodic parse skip: $err');
            return null;
          }
        })
        .whereType<PeriodicPoint>()
        .toList();
  }

  List<dynamic> _extractList(dynamic body) {
    if (body is Map) {
      final d = body['data'];
      if (d is List) return d;
      if (d is Map && d['data'] is List) return d['data'];
    }
    if (body is List) return body;
    return [];
  }

  String _formatDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}
