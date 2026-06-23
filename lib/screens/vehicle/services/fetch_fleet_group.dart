import 'package:ams/base/network/api_client.dart';

class FetchFleetGroup {
  static const _pageLimit = 100;
  static const _maxPages = 50;

  Future<List<Map<String, dynamic>>> fetch({String? search}) async {
    final result = <Map<String, dynamic>>[];
    String? cursor;

    for (var page = 0; page < _maxPages; page++) {
      final res = await ApiClient.dio.get(
        '/master-option/fleet-groups',
        queryParameters: {
          'limit': _pageLimit,
          if (search != null && search.isNotEmpty) 'search': search,
          if (cursor != null) 'cursor': cursor,
        },
      );

      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Format response tidak valid');
      }

      if (data['status']?.toString() != 'true') {
        throw Exception(
          (data['message'] ?? data['error_msg'])?.toString() ??
              'Gagal memuat fleet group',
        );
      }

      final raw = data['data'];
      final list = raw is List ? raw : const [];

      result.addAll(
        list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
      );

      final metadata = data['metadata'];
      final hasNext = metadata is Map && metadata['hasNext'] == true;
      final next = metadata is Map ? metadata['next']?.toString() : null;

      if (!hasNext || next == null || next.isEmpty) break;
      cursor = next;
    }

    return result;
  }
}
