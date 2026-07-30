import 'package:ams/base/network/api_client.dart';
import 'package:ams/base/services/demo_data.dart';
import 'package:ams/base/services/demo_mode.dart';

class FetchAlertType {
  Future<List<Map<String, dynamic>>> fetch() async {
    if (DemoMode.isActive) return DemoData.alertTypes();

    final res = await ApiClient.dio.get('/master-option/alert');

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Format response tidak valid');
    }

    if (data['status']?.toString() != 'true') {
      throw Exception(
        (data['message'] ?? data['error_msg'])?.toString() ??
            'Gagal memuat alert type',
      );
    }

    final raw = data['data'];
    final list = raw is List ? raw : const [];

    return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
