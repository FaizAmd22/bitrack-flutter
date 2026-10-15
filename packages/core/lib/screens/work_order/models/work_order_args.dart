// Argumen route antar halaman Work Order. Karena halaman-halaman ini butuh
// argumen, mereka didaftarkan lewat `onGenerateRoute` di `main.dart`.

/// Argumen halaman daftar detail (task) milik satu work order.
class WorkListArgs {
  final String workOrderId;
  final String workOrderNo;

  const WorkListArgs({required this.workOrderId, required this.workOrderNo});
}

/// Argumen halaman detail satu task work order.
class WorkDetailsArgs {
  final String detailId;

  const WorkDetailsArgs({required this.detailId});
}

/// Argumen halaman buat/ubah detail (task) work order.
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

  /// True = mengubah detail yang sudah ada.
  bool get isUpdate => detail != null;
}
