class VehiclePage {
  final int currentPage;
  final int lastPage;
  final int total;
  final List<Map<String, dynamic>> items;

  const VehiclePage({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.items,
  });

  bool get hasNext => currentPage < lastPage;

  factory VehiclePage.fromResponse(Map<String, dynamic> json) {
    final status = json['status'];
    if (status != true && status?.toString() != 'true') {
      throw Exception(
        (json['message'] ?? json['error_msg'])?.toString() ??
            'Gagal memuat data',
      );
    }

    final rawItems = json['data'];
    final list = rawItems is List ? rawItems : const [];

    final metadata = json['metadata'];
    final pagination = metadata is Map ? metadata['pagination'] : null;

    int asInt(dynamic v, int fallback) {
      if (v is int) return v;
      return int.tryParse('$v') ?? fallback;
    }

    return VehiclePage(
      currentPage: pagination is Map ? asInt(pagination['page'], 1) : 1,
      lastPage: pagination is Map ? asInt(pagination['totalPages'], 1) : 1,
      total: pagination is Map
          ? asInt(pagination['total'], list.length)
          : list.length,
      items: list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false),
    );
  }
}
