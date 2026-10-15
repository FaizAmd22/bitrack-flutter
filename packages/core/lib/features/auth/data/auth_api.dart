import 'package:bitrack_core/base/network/api_response.dart';
import 'package:dio/dio.dart';
import 'package:bitrack_core/base/localization/locale_controller.dart';
import 'package:bitrack_core/base/network/api_client.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';

/// Panggilan API autentikasi (saat ini hanya login).
///
/// Hasil mentah dipakai [AuthController], yang menyimpan token dan data user.
/// Semua kegagalan dilempar sebagai `Exception` berisi pesan siap tampil.
class AuthApi {
  /// Nama field dari backend -> label terjemahan, untuk pesan validasi.
  static Map<String, String> _fieldLabels(AppLocalizations t) => {
    'email': t.email,
    'password': t.password,
  };

  /// `POST /mobile/auth/login`. Response sukses berbentuk
  /// `{data: {token, user: {id, name, email, role, permission_allowed}}}`.
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
      throw Exception(currentL10n().errGenericTryAgain);
    }
  }

  /// Hanya menangani kasus yang khas login; sisanya diserahkan ke
  /// [apiErrorText] supaya pesan jaringan seragam dengan layar lain.
  static String _mapError(DioException e) {
    final t = currentL10n();

    if (e.type == DioExceptionType.badResponse) {
      final specific = _loginResponseError(e, t);
      if (specific != null) return specific;
    }

    return apiErrorText(e, t.loginFailedTryAgain);
  }

  /// Kenali dua bentuk penolakan khas endpoint login: `Validation error`
  /// (field kosong/salah format, dengan daftar field di `detail`) dan
  /// `Invalid credentials` (email atau password salah). Null = bukan kasus
  /// khas login.
  static String? _loginResponseError(DioException e, AppLocalizations t) {
    final data = e.response?.data;

    if (data is Map) {
      final serverMessage = data['message']?.toString();
      final detail = data['detail'];

      if (serverMessage == 'Validation error' && detail is List) {
        final fieldLabels = _fieldLabels(t);
        final fieldNames = detail
            .whereType<Map>()
            .map((d) => d['path']?.toString().replaceAll('/', ''))
            .whereType<String>()
            .map((field) => fieldLabels[field] ?? field)
            .toSet()
            .toList();

        if (fieldNames.isNotEmpty) {
          return t.errFieldsRequired(fieldNames.join(' ${t.errFieldsJoiner} '));
        }
        return t.errIncompleteData;
      }

      if (serverMessage == 'Invalid credentials') {
        return t.errInvalidCredentials;
      }
    }

    return null;
  }
}
