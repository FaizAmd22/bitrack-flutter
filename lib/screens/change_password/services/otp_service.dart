import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpSendResult {
  final bool ok;
  final bool cooldown;
  final String? reason;
  const OtpSendResult({required this.ok, this.cooldown = false, this.reason});
}

class OtpVerifyResult {
  final bool ok;
  final String? reason;
  const OtpVerifyResult({required this.ok, this.reason});
}

class OtpApi {
  OtpApi()
    : _dio = Dio(
        BaseOptions(
          baseUrl: "https://bitrack-otp-be.onrender.com",
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          // Jangan lempar exception untuk 4xx; kita baca body-nya sendiri.
          // 5xx tetap error (akan melempar DioException).
          validateStatus: (s) => s != null && s < 500,
        ),
      );

  final Dio _dio;

  /// POST /otp/send  { email }
  Future<OtpSendResult> sendOtp(String email) async {
    final res = await _dio.post('/otp/send', data: {'email': email});
    final data = (res.data as Map?)?.cast<String, dynamic>() ?? {};

    if (res.statusCode == 200 && data['ok'] == true) {
      return const OtpSendResult(ok: true);
    }
    if (res.statusCode == 429) {
      return OtpSendResult(
        ok: false,
        cooldown: true,
        reason: data['reason'] as String?,
      );
    }
    return OtpSendResult(ok: false, reason: data['reason'] as String?);
  }

  /// POST /otp/verify  { email, otp }
  Future<OtpVerifyResult> verifyOtp(String email, String otp) async {
    final res = await _dio.post(
      '/otp/verify',
      data: {'email': email, 'otp': otp},
    );
    final data = (res.data as Map?)?.cast<String, dynamic>() ?? {};

    return OtpVerifyResult(
      ok: res.statusCode == 200 && data['ok'] == true,
      reason: data['reason'] as String?,
    );
  }
}

final otpApiProvider = Provider<OtpApi>((ref) => OtpApi());
