/// Argumen route Vehicle Detail: id kendaraan plus data yang SUDAH dipegang
/// layar pemanggil saat marker ditekan.
///
/// Tanpa data awal ini, layar detail menahan seluruh tampilan di balik scrim
/// loading selama menunggu `/monitoring/{id}?tab=DASHBOARD` — request yang di
/// lapangan bisa memakan tujuh detik atau lebih. Padahal plat, posisi, arah,
/// aktivitas, dan status mesin sudah ada di memori sejak layar home memuat
/// daftar kendaraan. Mengopernya ke sini membuat layar bisa langsung dipaint,
/// dan response API tinggal melengkapi field yang belum diketahui (model,
/// pengemudi, bahan bakar, sensor, dashcam).
class VehicleDetailArgs {
  const VehicleDetailArgs({
    required this.id,
    this.licensePlate = '',
    this.fleetGroupName = '',
    this.latitude,
    this.longitude,
    this.direction = 0,
    this.activity = '',
    this.ignition = 0,
    this.deviceTime = '',
    this.vehicleCategoryIcon = '',
  });

  final String id;
  final String licensePlate;
  final String fleetGroupName;
  final double? latitude;
  final double? longitude;
  final double direction;
  final String activity;
  final int ignition;
  final String deviceTime;

  /// URL ikon custom kategori kendaraan, atau kosong. Ikut dioper supaya
  /// peta detail menampilkan ikon yang sama dengan marker yang baru ditekan
  /// sejak frame pertama, tanpa menunggu response detail.
  final String vehicleCategoryIcon;

  bool get hasCoordinate => latitude != null && longitude != null;

  /// Bentuknya sengaja mengikuti keluaran `flattenMonitoringDetail` supaya
  /// `VehicleDetailContent` tidak perlu tahu datanya berasal dari seed atau
  /// dari response API.
  Map<String, dynamic> toSeedData() => {
    'vehicle_id': id,
    'license_plate': licensePlate,
    'fleet_group_name': fleetGroupName,
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    'direction': direction,
    'vehicle_activity': activity,
    'ignition': ignition,
    'device_time': deviceTime,
    'vehicle_category_icon': vehicleCategoryIcon,
    // buildIndicators() di VehicleDetailContent membandingkan
    // `fuel_consumed >= 50` tanpa penjagaan null, jadi kedua field ini WAJIB
    // ada dan numerik walaupun nilainya belum diketahui.
    'speed': 0,
    'fuel_consumed': 0,
  };
}
