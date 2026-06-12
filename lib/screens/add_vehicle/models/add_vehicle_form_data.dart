class AddVehicleFormData {
  // Vehicle
  String plateNumber = '';
  String? brand;
  String? model;
  String year = '';
  String? vehicleCategory;
  String odometer = '';
  String vin = '';
  String? fleetGroupId;

  // Device
  DateTime? installationDate;
  String deviceTypeCode = 'TELTONIKA';
  String? deviceModel;
  String simCardNumber = '';
  String imeiObdNumber = '';

  void applyFromVehicleApi(Map<String, dynamic> v, {String? forcedPlate}) {
    plateNumber = (forcedPlate ?? v['license_plate'] ?? '').toString().trim();
    vin = (v['vin'] ?? '').toString();

    brand = _nullable(v['vehicle_brand']);
    model = _nullable(v['vehicle_model']);
    year = (v['vehicle_year'] ?? '').toString();
    vehicleCategory = _nullable(v['vehicle_category']);
    odometer = (v['odometer'] ?? '').toString();
    fleetGroupId = _nullable(v['fleet_group_id']);

    installationDate = _tryParseDate(v['installation_date']);
    deviceTypeCode = (v['device_type_code'] ?? 'TELTONIKA').toString();
    deviceModel = _nullable(v['device_model_code']);
    simCardNumber = (v['simcard_number'] ?? '').toString();
    imeiObdNumber = (v['imei_obd_number'] ?? '').toString();
  }

  String? _nullable(dynamic v) {
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? null : s;
  }

  DateTime? _tryParseDate(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }
}
