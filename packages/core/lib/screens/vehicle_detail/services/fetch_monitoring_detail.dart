import 'package:bitrack_core/base/localization/locale_controller.dart';
import 'package:bitrack_core/base/network/api_response.dart';
import 'package:bitrack_core/base/network/api_client.dart';
import 'package:bitrack_core/base/services/demo_data.dart';
import 'package:bitrack_core/base/services/demo_mode.dart';
import 'package:dio/dio.dart';

class FetchMonitoringDetail {
  const FetchMonitoringDetail();

  Future<Map<String, dynamic>> getDetail(
    String id, {
    String tab = 'DASHBOARD',
  }) async {
    if (DemoMode.isActive) return DemoData.vehicleDetail(id);

    try {
      final res = await ApiClient.dio.get(
        '/monitoring/$id',
        queryParameters: {'tab': tab},
        // Sengaja melampaui 15 detik milik ApiClient. Endpoint ini menghitung
        // agregasi per jam (average_speed & fuel_consumption) sebelum
        // menjawab, dan di produksi kerap tembus 15 detik sehingga request
        // dibatalkan tepat sebelum data sampai. Menunggu lebih lama jauh
        // lebih baik daripada gagal: layar sudah menampilkan data awal plus
        // skeleton, jadi menunggu tidak berarti layar kosong.
        //
        // Ini menambal gejala, bukan sebabnya — lihat catatan di
        // flattenMonitoringDetail: average_speed tidak dipakai sama sekali
        // dan fuel_consumption hanya diambil entri terakhirnya.
        options: Options(receiveTimeout: const Duration(seconds: 45)),
      );

      final body = res.data;
      if (body is! Map) {
        throw Exception(currentL10n().errInvalidResponse);
      }

      final data = body['data'];
      if (data is Map<String, dynamic>) return data;

      return <String, dynamic>{};
    } on DioException catch (e) {
      throw Exception(apiErrorText(e, currentL10n().failedLoadData));
    }
  }
}
