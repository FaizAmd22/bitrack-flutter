import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final Dio _geoDio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {},
    validateStatus: (status) => status != null && status < 500,
    responseType: ResponseType.plain,
  ),
);

Future<String> getAddress(double lat, double lng) async {
  try {
    final url = dotenv.env['GEO_REVERSE'];

    if (url == null || url.isEmpty) {
      debugPrint('GEO_REVERSE env missing');
      return '-';
    }

    final res = await _geoDio.get(
      url,
      queryParameters: {'lat': lat, 'lon': lng, 'format': 'json'},
    );

    debugPrint('GEO STATUS: ${res.statusCode}');
    debugPrint('RAW GEO RESPONSE: ${res.data}');

    if (res.statusCode != 200 || res.data == null) {
      return '-';
    }

    final data = jsonDecode(res.data);
    final name = (data['display_name'] ?? '').toString().trim();

    return name.isNotEmpty ? name : '-';
  } catch (e, s) {
    debugPrint('GET ADDRESS ERROR: $e');
    debugPrintStack(stackTrace: s);
    return '-';
  }
}
