import 'package:dio/dio.dart';
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

    final raw = res.data;

    // Sesuaikan jika struktur kamu bukan raw['data']
    final list = List<Map<String, dynamic>>.from(raw['data'] as List);

    return list.map((e) => PeriodicPoint.fromJson(e)).toList();
  }

  String _formatDate(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}:00';
  }
}
