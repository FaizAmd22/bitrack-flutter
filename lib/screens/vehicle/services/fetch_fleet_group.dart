import 'package:ams/base/localization/locale_controller.dart';
import 'package:ams/base/network/api_client.dart';
import 'package:ams/base/network/api_response.dart';
import 'package:ams/base/services/demo_data.dart';
import 'package:ams/base/services/demo_mode.dart';
import 'package:dio/dio.dart';

class FetchFleetGroup {
  static const _pageLimit = 100;
  static const _maxPages = 50;

  Future<List<Map<String, dynamic>>> fetch({String? search}) async {
    if (DemoMode.isActive) return DemoData.fleetGroupList();

    final result = <Map<String, dynamic>>[];
    String? cursor;

    try {
      for (var page = 0; page < _maxPages; page++) {
        final res = await ApiClient.dio.get(
          '/master-option/fleet-groups',
          queryParameters: {
            'limit': _pageLimit,
            if (search != null && search.isNotEmpty) 'search': search,
            if (cursor != null) 'cursor': cursor,
          },
        );

        result.addAll(
          apiDataList(res.data, onInvalid: currentL10n().errInvalidResponse),
        );

        // Backend memakai snake_case: {"has_more":false,"next_cursor":null}.
        // Nama camelCase tetap diterima supaya endpoint lama ikut jalan.
        final metadata = res.data is Map ? res.data['metadata'] : null;
        if (metadata is! Map) break;

        final hasNext =
            metadata['has_more'] == true || metadata['hasNext'] == true;
        final next = (metadata['next_cursor'] ?? metadata['next'])?.toString();

        if (!hasNext || next == null || next.isEmpty) break;
        cursor = next;
      }
    } on DioException catch (e) {
      throw Exception(apiErrorText(e, currentL10n().errLoadFleetGroupFailed));
    }

    return result;
  }
}
