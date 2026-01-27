import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MettaxiotStreamService {
  MettaxiotStreamService._internal()
    : _dio = Dio(
        BaseOptions(
          baseUrl: '',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (c) => c != null && c >= 200 && c < 400,
        ),
      );

  static final MettaxiotStreamService I = MettaxiotStreamService._internal();

  final Dio _dio;

  String? _cachedToken;
  DateTime? _tokenTime;

  String get _key => _mustEnv('METTAXIOT_KEY');
  String get _secret => _mustEnv('METTAXIOT_SECRET');
  String get _createTokenUrl => _mustEnv('METTAXIOT_CREATE_TOKEN');
  String get _mettaxiotVideoUrl => _mustEnv('METTAXIOT_VIDEO');

  String _mustEnv(String key) {
    final v = dotenv.env[key];
    if (v == null || v.trim().isEmpty) {
      throw Exception(
        'ENV "$key" belum di-set. Pastikan dotenv.load() sudah dijalankan.',
      );
    }
    return v.trim();
  }

  Future<String> createToken() async {
    if (_cachedToken != null &&
        _tokenTime != null &&
        DateTime.now().difference(_tokenTime!).inMinutes < 10) {
      return _cachedToken!;
    }

    final res = await _dio.post(
      _createTokenUrl,
      data: {'apiKey': _key, 'apiSecret': _secret},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    final body = res.data;
    final token = (body is Map) ? (body['data']?.toString() ?? '') : '';
    if (token.trim().isEmpty) {
      throw Exception('Failed to get token');
    }

    _cachedToken = token.trim();
    _tokenTime = DateTime.now();
    return _cachedToken!;
  }

  Future<String> getLiveStreamUrl({
    required String deviceId,
    required int channelId,
  }) async {
    final token = await createToken();

    final payload = {
      'deviceId': deviceId,
      'channelId': channelId + 1,
      'bitstreamType': 0,
    };

    debugPrint('HIT METTAXIOT_VIDEO => $_mettaxiotVideoUrl');
    final res = await _dio.post(
      _mettaxiotVideoUrl, // pastikan ini FULL URL, bukan path relative
      data: payload,
      options: Options(
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      ),
    );

    debugPrint('METTAXIOT status=${res.statusCode} headers=${res.headers.map}');

    dynamic body = res.data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } catch (_) {}
    }
    final url = (body is Map) ? (body['data']?.toString() ?? '') : '';
    if (url.trim().isEmpty) {
      final msg = (body is Map) ? (body['msg']?.toString() ?? '') : '';
      throw Exception(msg.isEmpty ? 'Failed to get stream URL' : msg);
    }

    return url.trim();
  }
}
