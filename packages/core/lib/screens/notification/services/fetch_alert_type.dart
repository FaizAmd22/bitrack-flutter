import 'package:bitrack_core/base/localization/locale_controller.dart';
import 'package:bitrack_core/base/network/api_client.dart';
import 'package:bitrack_core/base/network/api_response.dart';
import 'package:bitrack_core/base/services/demo_data.dart';
import 'package:bitrack_core/base/services/demo_mode.dart';
import 'package:dio/dio.dart';

class FetchAlertType {
  Future<List<Map<String, dynamic>>> fetch() async {
    if (DemoMode.isActive) return DemoData.alertTypes();

    try {
      final res = await ApiClient.dio.get('/master-option/alert');
      return apiDataList(res.data, onInvalid: currentL10n().errInvalidResponse);
    } on DioException catch (e) {
      throw Exception(apiErrorText(e, currentL10n().errLoadAlertTypeFailed));
    }
  }
}
