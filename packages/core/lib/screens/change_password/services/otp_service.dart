import 'package:bitrack_core/base/network/api_logger.dart';
import 'package:bitrack_core/base/services/demo_mode.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hasil kirim OTP. [cooldown] true = server menolak karena OTP baru saja
/// dikirim (HTTP 429); user harus menunggu sebelum minta lagi. [reason] =
/// alasan dari server, bila ada.
class OtpSendResult {
  final bool ok;
  final bool cooldown;
  final String? reason;
  const OtpSendResult({required this.ok, this.cooldown = false, this.reason});
}

/// Hasil verifikasi OTP: [ok] true kalau kode benar dan belum kedaluwarsa.
class OtpVerifyResult {
  final bool ok;
  final String? reason;
  const OtpVerifyResult({required this.ok, this.reason});
}

/// Klien server OTP (repo terpisah `bitrack-be-otp`: Node.js + Redis +
/// Brevo untuk email), dipakai di alur Ganti Password.
///
/// Server ini BUKAN backend tracking utama, jadi memakai `Dio` sendiri
/// (bukan [ApiClient]) dan alamatnya ditulis langsung di sini, tidak di
/// `.env`. Server di-host di Render; setelah lama idle, respons pertamanya
/// bisa lebih lama dari timeout 10 detik (lihat
/// `docs/16-masalah-dan-hal-terbuka.md`).
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
      ) {
    attachApiLogger(_dio);
  }

  final Dio _dio;

  /// `POST /otp/send {email}`: kirim kode OTP ke email user. Di mode demo
  /// selalu dianggap berhasil tanpa memanggil server.
  Future<OtpSendResult> sendOtp(String email) async {
    if (DemoMode.isActive) return const OtpSendResult(ok: true);

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

  /// `POST /otp/verify {email, otp}`: cocokkan kode yang diketik user. Di mode
  /// demo selalu dianggap benar.
  Future<OtpVerifyResult> verifyOtp(String email, String otp) async {
    if (DemoMode.isActive) return const OtpVerifyResult(ok: true);

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

/// Provider [OtpApi] (bisa diganti versi palsu di tes).
final otpApiProvider = Provider<OtpApi>((ref) => OtpApi());
