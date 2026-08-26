import 'dart:io';

import 'package:ams/base/localization/locale_controller.dart';
import 'package:ams/base/network/api_client.dart';
import 'package:ams/screens/work_order/models/work_order_list_page.dart';
import 'package:ams/screens/work_order/models/work_order_options.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Semua endpoint Work Order. Padanan folder `pages/work-order/hooks` di
/// bitrack-mobile, dikumpulkan jadi satu kelas supaya gampang dilacak.
class WorkOrderApi {
  const WorkOrderApi();

  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _isTechnicianKey = 'work_order_is_technician';

  // ---------------------------------------------------------------- header

  Future<WorkOrderListPage> fetchWorkOrder({
    required int page,
    int size = 10,
    String? fleetGroupId,
    String? date,
    String? technician,
  }) async {
    final res = await ApiClient.dio.get(
      '/work-order',
      queryParameters: {
        'page': page,
        'size': size,
        if (fleetGroupId != null && fleetGroupId.isNotEmpty)
          'fleet_group_id': fleetGroupId,
        if (date != null && date.isNotEmpty) 'date': date,
        if (technician != null && technician.isNotEmpty)
          'technician': technician,
      },
    );

    final data = res.data;
    if (data is! Map) throw Exception(currentL10n().errInvalidResponse);

    return WorkOrderListPage.fromResponse(data, requestedPage: page);
  }

  Future<WorkOrderOptions> fetchOptions() async {
    final res = await ApiClient.dio.get('/work-order/options');

    final data = res.data;
    final payload = data is Map ? data['data'] : null;
    if (payload is! Map) return WorkOrderOptions.empty;

    return WorkOrderOptions.fromJson(payload);
  }

  Future<Map<String, dynamic>> createWorkOrderHeader({
    required String fleetGroupId,
    required String technician,
    required String dateFrom,
  }) async {
    final res = await ApiClient.dio.post(
      '/work-order',
      data: {
        'fleet_group_id': fleetGroupId,
        'technician': technician,
        'date_from': dateFrom,
      },
    );

    final data = res.data;
    final payload = data is Map ? data['data'] : null;
    if (payload is! Map) throw Exception(currentL10n().errInvalidResponse);

    return Map<String, dynamic>.from(payload);
  }

  Future<void> deleteWorkOrder(String id) async {
    await ApiClient.dio.delete('/work-order/WO/$id');
  }

  // ---------------------------------------------------------------- detail

  Future<List<Map<String, dynamic>>> fetchWorkOrderDetail(
    String id, {
    int page = 1,
  }) async {
    final res = await ApiClient.dio.get(
      '/work-order/detail',
      queryParameters: {'id': id, 'page': page},
    );

    final data = res.data;
    final payload = data is Map ? data['data'] : null;

    // API bisa mengembalikan list langsung atau dibungkus `{ data: [...] }`.
    final rows = payload is Map ? payload['data'] : payload;
    if (rows is! List) return const [];

    return rows
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> fetchWorkOrderDetailById(String id) async {
    final res = await ApiClient.dio.get(
      '/work-order/detail-single',
      queryParameters: {'id': id},
    );

    final data = res.data;
    final payload = data is Map ? data['data'] : null;
    if (payload is! Map) throw Exception(currentL10n().errInvalidResponse);

    return Map<String, dynamic>.from(payload);
  }

  Future<void> createWorkOrderDetail(Map<String, dynamic> payload) async {
    await ApiClient.dio.post('/work-order/detail', data: payload);
  }

  Future<void> deleteWorkOrderDetail(String id) async {
    await ApiClient.dio.delete('/work-order/WO_DETAIL/$id');
  }

  Future<WorkOrderDetailOptions> fetchDetailOptions(String category) async {
    final normalized = category.toLowerCase().replaceAll(RegExp(r'\s+'), '_');

    final res = await ApiClient.dio.get(
      '/work-order/option-detail',
      queryParameters: {'category': normalized},
    );

    final data = res.data;
    final payload = data is Map ? data['data'] : null;
    if (payload is! Map) return WorkOrderDetailOptions.empty;

    return WorkOrderDetailOptions.fromJson(payload);
  }

  // -------------------------------------------------------------- evidence

  Future<void> uploadEvidence({
    required List<File> files,
    required String workOrderDetailId,
    required String event,
  }) async {
    if (files.isEmpty) return;

    final form = FormData();
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final name = file.path.split(RegExp(r'[\\/]')).last;
      form.files.add(
        MapEntry(
          'files[]',
          await MultipartFile.fromFile(
            file.path,
            filename: name.isEmpty ? 'photo_$i.jpg' : name,
          ),
        ),
      );
    }
    form.fields
      ..add(MapEntry('work_order_detail_id', workOrderDetailId))
      ..add(MapEntry('event', event));

    await ApiClient.dio.post(
      '/work-order/evidence',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<void> deleteEvidence(String fileUrl) async {
    await ApiClient.dio.delete(
      '/work-order/evidence',
      queryParameters: {'file_url': fileUrl},
    );
  }

  Future<void> updateNotes({
    required String workOrderDetailId,
    required String notes,
  }) async {
    await ApiClient.dio.post(
      '/work-order/notes',
      data: {'work_order_detail_id': workOrderDetailId, 'notes': notes},
    );
  }

  // ----------------------------------------------------------------- misc

  /// Menentukan apakah akun yang login berperan sebagai teknisi lapangan.
  /// Teknisi tidak boleh membuat/menghapus work order maupun menandai
  /// pekerjaan selesai. Hasilnya di-cache seperti `localStorage.isTechnician`.
  Future<bool> fetchIsTechnician() async {
    final res = await ApiClient.dio.get('/work-order/check-technician');

    final data = res.data;
    final payload = data is Map ? data['data'] : null;
    final raw = payload is Map ? payload['is_technician'] : null;

    final isTechnician = raw == true || raw?.toString() == 'true';
    await _storage.write(key: _isTechnicianKey, value: '$isTechnician');

    return isTechnician;
  }

  Future<bool> cachedIsTechnician() async {
    final raw = await _storage.read(key: _isTechnicianKey);
    return raw == 'true';
  }

  Future<bool> gpsSignal(String? imei) async {
    if (imei == null || imei.isEmpty) return false;

    final res = await ApiClient.dio.get(
      '/work-order/gps-signal',
      queryParameters: {'imei': imei},
    );

    // Endpoint balas non-2xx saat device belum mengirim data, dan itu sudah
    // ditangkap caller sebagai "belum aktif". Flag eksplisit di body dipakai
    // kalau ada; kalau tidak, response 2xx sendiri sudah berarti ada sinyal.
    final payload = res.data is Map ? res.data['data'] : null;
    if (payload is bool) return payload;
    if (payload is Map && payload['is_active'] is bool) {
      return payload['is_active'] as bool;
    }
    return true;
  }

  Future<Map<String, dynamic>> vehicleInformation(String licensePlate) async {
    final res = await ApiClient.dio.get(
      '/work-order/vehicle-information',
      queryParameters: {'license_plate': licensePlate},
    );

    final data = res.data;
    final payload = data is Map ? data['data'] : null;
    if (payload is! Map) throw Exception(currentL10n().errInvalidResponse);

    return Map<String, dynamic>.from(payload);
  }
}

/// Isi `GET /work-order/option-detail`: dipakai step dua form detail WO.
class WorkOrderDetailOptions {
  final List<OptionItem> option;
  final List<OptionItem> position;
  final List<OptionItem> condition;
  final List<OptionItem> action;

  const WorkOrderDetailOptions({
    required this.option,
    required this.position,
    required this.condition,
    required this.action,
  });

  static const empty = WorkOrderDetailOptions(
    option: [],
    position: [],
    condition: [],
    action: [],
  );

  factory WorkOrderDetailOptions.fromJson(Map json) {
    return WorkOrderDetailOptions(
      option: OptionItem.listFrom(json['option']),
      position: OptionItem.listFrom(json['position']),
      condition: OptionItem.listFrom(json['condition']),
      action: OptionItem.listFrom(json['action']),
    );
  }
}
