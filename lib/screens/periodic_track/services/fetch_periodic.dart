import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/periodic_point.dart';

class PeriodicApi {
  final Dio dio;
  PeriodicApi(this.dio);

  static const _pageLimit = 500;
  static const _maxPages = 200;

  Future<List<PeriodicPoint>> fetchPeriodic({
    required DateTime startDate,
    required DateTime endDate,
    required String licensePlate,
    void Function(List<PeriodicPoint> page)? onPage,
  }) async {
    final points = <PeriodicPoint>[];
    String? cursor;

    for (var page = 0; page < _maxPages; page++) {
      final params = {
        'license_plate': licensePlate,
        'date_start': _formatDate(startDate),
        'date_end': _formatDate(endDate),
        'limit': _pageLimit,
        if (cursor != null) 'cursor': cursor,
      };

      Map<String, dynamic> body;
      try {
        final res = await dio.get(
          '/monitoring/playback',
          queryParameters: params,
          options: Options(receiveTimeout: const Duration(seconds: 30)),
        );
        body = res.data is Map
            ? Map<String, dynamic>.from(res.data as Map)
            : <String, dynamic>{};
      } catch (e) {
        debugPrint('periodic page $page fetch failed: $e');
        // Halaman pertama gagal = error sungguhan, lempar ke caller.
        // Halaman selanjutnya gagal = tetap pakai data yang sudah terkumpul
        // daripada seluruh hasil hilang karena satu halaman gagal di tengah.
        if (points.isEmpty) rethrow;
        break;
      }

      final list = _extractList(body);

      final pagePoints = list
          .map((e) {
            try {
              return PeriodicPoint.fromJson(
                Map<String, dynamic>.from(e as Map),
              );
            } catch (err) {
              debugPrint('periodic parse skip: $err');
              return null;
            }
          })
          .whereType<PeriodicPoint>()
          .toList();

      points.addAll(pagePoints);
      if (pagePoints.isNotEmpty) {
        // Isolasi error dari callback UI supaya bug di sisi pemanggil tidak
        // ikut menghentikan loop pagination data.
        try {
          onPage?.call(pagePoints);
        } catch (e) {
          debugPrint('periodic onPage callback error: $e');
        }
      }

      // Sumber kebenaran lanjut/berhenti pagination: metadata.has_more +
      // metadata.next_cursor (bukan dari panjang list), sesuai kontrak API.
      final metadata = body['metadata'];
      final hasMore = metadata is Map && metadata['has_more'] == true;
      final nextCursor = metadata is Map
          ? metadata['next_cursor']?.toString()
          : null;

      debugPrint(
        'periodic page $page: ${pagePoints.length} pts, '
        'total=${points.length}, metadata=$metadata',
      );

      if (!hasMore || nextCursor == null || nextCursor.isEmpty) break;
      cursor = nextCursor;
    }

    return points;
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
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }
}
