import 'package:ams/base/localization/locale_controller.dart';
import 'package:ams/base/network/api_response.dart';

class VehiclePage {
  final int currentPage;
  final int lastPage;
  final int total;
  final List<Map<String, dynamic>> items;
  final bool _hasMore;

  const VehiclePage({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.items,
    bool hasMore = false,
  }) : _hasMore = hasMore;

  bool get hasNext => _hasMore || currentPage < lastPage;

  /// Sukses/gagal sudah ditentukan HTTP status code sebelum sampai ke sini —
  /// lihat [apiDataList]. Yang dibaca cuma isi datanya.
  factory VehiclePage.fromResponse(Map<String, dynamic> json) {
    final items = apiDataList(
      json,
      onInvalid: currentL10n().errInvalidResponse,
    );

    // Nama field pagination berbeda antar-endpoint (`totalPages` vs
    // `total_pages`, offset vs cursor), jadi semuanya dibaca toleran dan
    // jatuh ke default aman kalau tidak ada.
    final metadata = json['metadata'];
    final meta = metadata is Map ? metadata : const {};
    final pagination = meta['pagination'] is Map
        ? meta['pagination'] as Map
        : meta;

    final hasMore =
        pagination['has_more'] == true ||
        pagination['hasNext'] == true ||
        pagination['hasMore'] == true;

    return VehiclePage(
      currentPage: metaInt(pagination, ['page', 'current_page']) ?? 1,
      lastPage:
          metaInt(pagination, ['totalPages', 'total_pages', 'last_page']) ?? 1,
      total: metaInt(pagination, ['total', 'total_data']) ?? items.length,
      items: items,
      hasMore: hasMore,
    );
  }
}
