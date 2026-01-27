class VehiclePage {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final List<Map<String, dynamic>> items;

  const VehiclePage({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.items,
  });

  bool get hasNext => currentPage < lastPage;

  factory VehiclePage.fromResponse(Map<String, dynamic> json) {
    final rootStatus = json['status']?.toString();
    if (rootStatus != 'true') {
      throw Exception(json['error_msg']?.toString() ?? 'Gagal memuat data');
    }

    final data =
        (json['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final rawItems = data['data'];
    final list = rawItems is List ? rawItems : const [];

    return VehiclePage(
      currentPage: (data['current_page'] ?? 1) is int
          ? data['current_page'] as int
          : int.tryParse('${data['current_page']}') ?? 1,
      lastPage: (data['last_page'] ?? 1) is int
          ? data['last_page'] as int
          : int.tryParse('${data['last_page']}') ?? 1,
      perPage: (data['per_page'] ?? 10) is int
          ? data['per_page'] as int
          : int.tryParse('${data['per_page']}') ?? 10,
      total: (data['total'] ?? 0) is int
          ? data['total'] as int
          : int.tryParse('${data['total']}') ?? 0,
      items: list
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false),
    );
  }
}
