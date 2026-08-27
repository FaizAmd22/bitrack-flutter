/// Satu halaman hasil `GET /work-order` (list header work order).
class WorkOrderListPage {
  final List<Map<String, dynamic>> items;
  final int currentPage;
  final int lastPage;

  const WorkOrderListPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasNext => currentPage < lastPage;

  factory WorkOrderListPage.fromResponse(
    Map json, {
    required int requestedPage,
  }) {
    final data = json['data'];
    final rawItems = data is Map ? data['items'] : null;
    final pagination = data is Map ? data['pagination'] : null;

    int asInt(dynamic v, int fallback) {
      if (v is int) return v;
      return int.tryParse('$v') ?? fallback;
    }

    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(growable: false)
        : <Map<String, dynamic>>[];

    // Tanpa pagination, anggap masih ada halaman berikutnya selama rows tidak
    // kosong — sama seperti fallback di work-order.jsx.
    return WorkOrderListPage(
      items: items,
      currentPage: pagination is Map
          ? asInt(
              pagination['page'] ?? pagination['current_page'],
              requestedPage,
            )
          : requestedPage,
      lastPage: pagination is Map
          ? asInt(
              pagination['last_page'] ?? pagination['totalPages'],
              requestedPage,
            )
          : (items.isEmpty ? requestedPage : requestedPage + 1),
    );
  }
}
