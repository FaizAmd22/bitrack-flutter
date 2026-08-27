// Argumen navigasi antar halaman Work Order. Di bitrack-mobile ini dikirim
// lewat parameter route Framework7 + `props`.

class WorkListArgs {
  final String workOrderId;
  final String workOrderNo;

  const WorkListArgs({required this.workOrderId, required this.workOrderNo});
}

class WorkDetailsArgs {
  final String detailId;

  const WorkDetailsArgs({required this.detailId});
}

class CreateDetailWoArgs {
  /// Nilai mentah yang dikirim ke API, mis. "GPS" / "INSTALLATION".
  final String category;
  final String type;

  /// Label yang ditampilkan ke user (dari option work category).
  final String categoryLabel;
  final String typeLabel;

  final String technician;
  final String workOrderId;

  /// Diisi saat mode update — data detail yang sedang diubah.
  final Map<String, dynamic>? detail;

  const CreateDetailWoArgs({
    required this.category,
    required this.type,
    required this.categoryLabel,
    required this.typeLabel,
    required this.technician,
    required this.workOrderId,
    this.detail,
  });

  bool get isUpdate => detail != null;
}
