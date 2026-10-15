import 'package:bitrack_core/base/localization/locale_controller.dart';
import 'dart:convert';

import 'package:bitrack_core/base/network/api_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Klien API dashcam Mettaxiot: membuat token akses dan meminta URL stream
/// video live. Kredensial dan alamatnya dari `.env` (`METTAXIOT_KEY`,
/// `METTAXIOT_SECRET`, `METTAXIOT_CREATE_TOKEN`, `METTAXIOT_VIDEO`).
///
/// Singleton ([I]) supaya token yang sudah dibuat bisa dipakai ulang.
class MettaxiotStreamService {
  MettaxiotStreamService._internal()
    : _dio = Dio(
        BaseOptions(
          baseUrl: '',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          // Server Mettaxiot membalas redirect 302; ikuti otomatis.
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (c) => c != null && c >= 200 && c < 400,
        ),
      ) {
    attachApiLogger(_dio);
  }

  static final MettaxiotStreamService I = MettaxiotStreamService._internal();

  final Dio _dio;

  /// Expose Dio instance agar bisa dipakai di tempat lain (misal DashcamBottomSheet)
  /// tanpa perlu membuat Dio baru — tetap 1 instance dengan config yang sama.
  Dio get dio => _dio;

  String? _cachedToken;
  DateTime? _tokenTime;

  String get _key => _mustEnv('METTAXIOT_KEY');
  String get _secret => _mustEnv('METTAXIOT_SECRET');
  String get _createTokenUrl => _mustEnv('METTAXIOT_CREATE_TOKEN');
  String get _mettaxiotVideoUrl => _mustEnv('METTAXIOT_VIDEO');

  String _mustEnv(String key) {
    final v = dotenv.env[key];
    if (v == null || v.trim().isEmpty) {
      // Detail teknisnya untuk developer; user cukup tahu layanannya mati.
      debugPrint('ENV "$key" belum di-set. Pastikan dotenv.load() dijalankan.');
      throw Exception(currentL10n().dashcamServiceUnavailable);
    }
    return v.trim();
  }

  /// Token akses Mettaxiot. Disimpan dan dipakai ulang selama 10 menit,
  /// setelah itu dibuat baru.
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
      throw Exception(currentL10n().dashcamServiceUnavailable);
    }

    _cachedToken = token.trim();
    _tokenTime = DateTime.now();
    return _cachedToken!;
  }

  /// Minta URL stream video live satu channel. Catatan: channel di app
  /// dimulai dari 0, sedangkan API Mettaxiot dari 1 (karena itu `+ 1`).
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
      _mettaxiotVideoUrl,
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
      throw Exception(
        msg.isEmpty ? currentL10n().dashcamServiceUnavailable : msg,
      );
    }

    return url.trim();
  }
}
