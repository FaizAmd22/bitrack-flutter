import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logging request/response Dio ke console — mengikuti pola di hrms_flutter.
///
/// Pakai [LogInterceptor] bawaan Dio (bukan package tambahan), dibungkus supaya
/// endpoint yang terlalu berisik bisa dikecualikan lewat [excludePaths].
/// Hanya aktif di debug build: di release interceptor-nya tidak dipasang sama
/// sekali, jadi tidak ada risiko token/body bocor ke log produksi.
void attachApiLogger(Dio dio, {List<String> excludePaths = const []}) {
  if (!kDebugMode) return;
  dio.interceptors.add(ApiLogInterceptor(excludePaths: excludePaths));
}

class ApiLogInterceptor extends Interceptor {
  ApiLogInterceptor({this.excludePaths = const []});

  final List<String> excludePaths;

  // debugPrint (bukan print) supaya baris panjang di-throttle dan tidak
  // dipotong logcat saat response-nya besar, mis. list kendaraan.
  final LogInterceptor _logger = LogInterceptor(
    request: true,
    requestHeader: true,
    requestBody: true,
    responseHeader: false,
    responseBody: true,
    error: true,
    logPrint: (obj) => debugPrint(obj.toString()),
  );

  bool _isExcluded(RequestOptions options) =>
      excludePaths.any((path) => options.path.contains(path));

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_isExcluded(options)) {
      handler.next(options);
    } else {
      _logger.onRequest(options, handler);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_isExcluded(response.requestOptions)) {
      handler.next(response);
    } else {
      _logger.onResponse(response, handler);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_isExcluded(err.requestOptions)) {
      handler.next(err);
    } else {
      _logger.onError(err, handler);
    }
  }
}
