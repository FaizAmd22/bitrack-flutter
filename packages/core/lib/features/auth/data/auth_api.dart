import 'package:bitrack_core/base/network/api_response.dart';
import 'package:dio/dio.dart';
import 'package:bitrack_core/base/localization/locale_controller.dart';
import 'package:bitrack_core/base/network/api_client.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';

class AuthApi {
  static Map<String, String> _fieldLabels(AppLocalizations t) => {
    'email': t.email,
    'password': t.password,
  };

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
