/// Mode halaman tambah kendaraan: membuat baru atau mengubah yang ada.
enum AddVehicleStatus { create, update }

/// Argumen route `/add-vehicle`. Untuk `update`, isi [id] atau [license]
/// supaya data kendaraan bisa dimuat dari server.
class AddVehicleArgs {
  final AddVehicleStatus status;
  final String? license;
  final String? id;

  const AddVehicleArgs({required this.status, this.license, this.id});
}
