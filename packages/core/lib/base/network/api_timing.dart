import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Mencatat durasi tiap request HTTP.
///
/// Berbeda dari [attachApiLogger] yang hanya aktif di debug, interceptor ini
/// jalan di build apa pun: yang dicatat cuma metode, path, status, dan lama
/// request — tidak ada header maupun body, jadi tidak ada risiko token bocor
/// ke log.
///
/// Pasang PALING AWAL di rantai interceptor supaya jamnya mulai sebelum
/// interceptor lain bekerja, dan angkanya tidak terkontaminasi biaya logging.
/// Selisih antara angka di sini dengan pengukuran di level layar menunjukkan
/// berapa lama waktu yang habis di luar jaringan (parsing, logging, UI).
void attachRequestTiming(Dio dio, {String tag = 'API'}) {
  dio.interceptors.add(_RequestTimingInterceptor(tag));
}

class _RequestTimingInterceptor extends Interceptor {
  _RequestTimingInterceptor(this.tag);

  final String tag;
  static const _startKey = '_timing_started_at';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now();
    handler.next(options);
  }

  void _report(RequestOptions options, String outcome) {
    final started = options.extra[_startKey];
    if (started is! DateTime) return;
    final ms = DateTime.now().difference(started).inMilliseconds;
    final query = options.queryParameters.isEmpty
        ? ''
        : '?${options.queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    debugPrint(
      '[$tag] ${options.method} ${options.path}$query -> $outcome (${ms}ms)',
    );
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _report(response.requestOptions, '${response.statusCode}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _report(err.requestOptions, 'GAGAL ${err.type.name}');
    handler.next(err);
  }
}
