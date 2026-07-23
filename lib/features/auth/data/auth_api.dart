import 'package:dio/dio.dart';
import 'package:ams/base/network/api_client.dart';

class AuthApi {
  static const _fieldLabels = {'email': 'Email', 'password': 'Password'};

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/mobile/auth/login',
        data: {'email': email, 'password': password},
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_mapError(e));
    } catch (_) {
      throw Exception('Terjadi kesalahan, coba lagi');
    }
  }

  static String _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi ke server timeout. Periksa koneksi internet Anda dan coba lagi.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      case DioExceptionType.badCertificate:
        return 'Koneksi ke server tidak aman. Hubungi admin.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.badResponse:
        return _mapResponseError(e);
      case DioExceptionType.unknown:
        return 'Tidak ada koneksi internet. Periksa jaringan Anda dan coba lagi.';
    }
  }

  static String _mapResponseError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (data is Map) {
      final serverMessage = data['message']?.toString();
      final detail = data['detail'];

      if (serverMessage == 'Validation error' && detail is List) {
        final fieldNames = detail
            .whereType<Map>()
            .map((d) => d['path']?.toString().replaceAll('/', ''))
            .whereType<String>()
            .map((field) => _fieldLabels[field] ?? field)
            .toSet()
            .toList();

        if (fieldNames.isNotEmpty) {
          return '${fieldNames.join(' dan ')} wajib diisi.';
        }
        return 'Data yang dimasukkan belum lengkap.';
      }

      if (serverMessage == 'Invalid credentials') {
        return 'Email atau password yang Anda masukkan salah.';
      }

      if (serverMessage != null && serverMessage.isNotEmpty) {
        return serverMessage;
      }
    }

    if (statusCode != null && statusCode >= 500) {
      return 'Server sedang bermasalah. Coba lagi beberapa saat lagi.';
    }

    return 'Login gagal, coba lagi.';
  }
}
