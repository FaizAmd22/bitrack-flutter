import 'dart:convert';
import 'package:bitrack_core/base/network/api_logger.dart';
import 'package:bitrack_core/base/services/demo_data.dart';
import 'package:bitrack_core/base/services/demo_mode.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final Dio _geoDio = _createGeoDio();

Dio _createGeoDio() {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': '*/*'},
      validateStatus: (status) => status != null && status < 500,
      responseType: ResponseType.plain,
    ),
  );
  attachApiLogger(dio);
  return dio;
}

// Beberapa hasil reverse-geocoding memuat aksara non-Latin (mis. aksara Jawa
// atau Sunda) yang tidak terbaca oleh mayoritas pengguna. Sanitasi ini
// menyamakan perilaku dengan sanitizeText di web: buang karakter di luar
// ASCII cetak + Latin beraksen, lalu rapikan spasi/koma.
String _sanitizeAddress(String value) {
  return value
      .replaceAll(RegExp(r'[^\x20-\x7EÀ-ɏ]'), '')
      .replaceAll(RegExp(r'\s{2,}'), ' ')
      .replaceAll(RegExp(r'\s+,'), ',')
      .trim();
}

Future<String> getAddress(double lat, double lng) async {
  if (DemoMode.isActive) return DemoData.address();

  try {
    final url = dotenv.env['GEO_REVERSE'];
    if (url == null || url.isEmpty) {
      return '-';
    }

    final res = await _geoDio.get(
      url,
      queryParameters: {'lat': lat, 'lon': lng, 'format': 'json'},
    );

    if (res.statusCode != 200 || res.data == null) return '-';

    final data = jsonDecode(res.data);
    final name = _sanitizeAddress((data['display_name'] ?? '').toString());
    return name.isNotEmpty ? name : '-';
  } catch (e, s) {
    debugPrint('GET ADDRESS ERROR: $e');
    debugPrintStack(stackTrace: s);
    return '-';
  }
}
