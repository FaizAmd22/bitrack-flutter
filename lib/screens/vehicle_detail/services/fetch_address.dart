import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> getAddress(double lat, double lng) async {
  try {
    final dio = Dio();
    final res = await dio.get(
      dotenv.env['API_GEO_REVERSE_URL']!,
      queryParameters: {'lat': lat, 'lon': lng, 'format': 'json'},
    );

    final data = res.data is String ? jsonDecode(res.data) : res.data;
    final name = (data?['display_name'] ?? '').toString().trim();
    return name.isNotEmpty ? name : '-';
  } catch (_) {
    return '-';
  }
}
