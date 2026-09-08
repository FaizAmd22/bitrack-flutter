import 'package:bitrack_core/base/localization/locale_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitrack_core/screens/vehicle_detail/services/fetch_monitoring_detail.dart';
import 'package:bitrack_core/screens/vehicle_detail/utils/flatten_monitoring_detail.dart';
import 'package:flutter_riverpod/legacy.dart';

final vehicleIdProvider = StateProvider<String?>((ref) => null);

/// Data DASHBOARD yang sudah dipegang layar Vehicle Detail, sudah di-flatten.
///
/// Diisi VehicleDetail setiap kali response `?tab=DASHBOARD` tiba, dan
/// dikosongkan saat layarnya ditutup. Tujuannya supaya sheet Informasi tidak
/// menembak ulang endpoint yang sama — endpoint itu butuh ~9,5 detik di
/// server (terukur, TTFB), jadi mengambilnya dua kali berarti pengguna
/// menunggu selama itu lagi untuk data yang sudah ada di memori.
final vehicleDashboardCacheProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

final vehicleDetailByVehicleIdProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      final detailId = id.trim();
      if (detailId.isEmpty) {
        throw Exception(currentL10n().failedLoadData);
      }

      final api = const FetchMonitoringDetail();

      // DASHBOARD punya latitude/longitude/direction/fuel/sensor, sedangkan
      // INFORMATION punya odometer/battery — gabungkan supaya semua tab di
      // VehicleInformationBottomSheet (Information/Status/Sensor) terisi.
      //
      // Bagian DASHBOARD-nya diambil dari layar detail kalau tersedia. Cek
      // `vehicle_id` memastikan cache-nya milik kendaraan yang sedang dibuka,
      // bukan sisa kendaraan sebelumnya.
      final cached = ref.read(vehicleDashboardCacheProvider);
      final reusable = cached != null && cached['vehicle_id'] == detailId;

      if (reusable) {
        final information = await api.getDetail(detailId, tab: 'INFORMATION');
        return {...cached, ...flattenInformationStatus(information)};
      }

      // Tanpa cache (sheet dibuka sebelum response detail pertama tiba),
      // keduanya diambil paralel lewat Future.wait supaya kalau salah satu
      // gagal, future satunya tetap punya handler.
      final results = await Future.wait([
        api.getDetail(detailId, tab: 'DASHBOARD'),
        api.getDetail(detailId, tab: 'INFORMATION'),
      ]);

      return {
        ...flattenMonitoringDetail(results[0], detailId: detailId),
        ...flattenInformationStatus(results[1]),
      };
    });
