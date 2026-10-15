import 'package:bitrack_core/base/network/api_client.dart';
import 'package:dio/dio.dart';

/// Data master kendaraan untuk pilihan di form tambah kendaraan.
class VehicleMasterApi {
  const VehicleMasterApi();

  /// `GET /master-vehicle/brands`: daftar merek beserta model/tipe di
  /// bawahnya (bertingkat). [cancelToken] dipakai untuk membatalkan request
  /// saat halaman ditutup.
  Future<List<Map<String, dynamic>>> fetchBrandHierarchy({
    CancelToken? cancelToken,
  }) async {
    final res = await ApiClient.dio.get(
      '/master-vehicle/brands',
      cancelToken: cancelToken,
    );

    final body = res.data;
    if (body is! Map || body['data'] is! List) return [];

    return (body['data'] as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
