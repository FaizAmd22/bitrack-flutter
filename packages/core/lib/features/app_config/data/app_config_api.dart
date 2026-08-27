import 'package:bitrack_core/base/network/api_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Baca flag remote dari tabel `app_settings` di Supabase lewat REST API
/// bawaannya (PostgREST), bukan lewat backend utama (ApiClient) karena
/// key/base URL-nya beda dan hanya butuh 1 endpoint baca sederhana.
///
/// Toggle nilainya dilakukan lewat Postman langsung ke Supabase REST API
/// pakai service_role key (lihat README/instruksi setup Supabase).
class AppConfigApi {
  static const _table = 'app_settings';

  static Future<bool> fetchFlag(String key, {bool fallback = false}) async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      debugPrint('AppConfigApi: SUPABASE_URL/SUPABASE_ANON_KEY belum diset');
      return fallback;
    }

    try {
      final dio = Dio();
      attachApiLogger(dio);

      final response = await dio.get(
        '$url/rest/v1/$_table',
        queryParameters: {'key': 'eq.$key', 'select': 'value'},
        options: Options(
          headers: {'apikey': anonKey, 'Authorization': 'Bearer $anonKey'},
        ),
      );

      final rows = response.data;
      if (rows is List && rows.isNotEmpty) {
        final row = rows.first;
        if (row is Map && row['value'] is bool) {
          return row['value'] as bool;
        }
      }
      return fallback;
    } catch (e) {
      debugPrint('AppConfigApi.fetchFlag($key) gagal: $e');
      return fallback;
    }
  }
}
