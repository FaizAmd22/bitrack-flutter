import 'package:bitrack_mobile_flutter/base/network/api_client.dart';

class FetchFleetGroup {
  Future<List<Map<String, dynamic>>> fetch() async {
    final res = await ApiClient.dio.get('/fleet-group');

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Format response tidak valid');
    }

    if (data['status']?.toString() != 'true') {
      throw Exception(
        data['error_msg']?.toString() ?? 'Gagal memuat fleet group',
      );
    }

    final raw = data['data'];
    final list = raw is List ? raw : const [];

    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }
}
