import 'package:ams/base/localization/locale_controller.dart';
import 'package:ams/base/network/api_client.dart';
import 'package:ams/base/network/api_response.dart';
import 'package:ams/base/services/demo_data.dart';
import 'package:ams/base/services/demo_mode.dart';
import 'package:ams/screens/vehicle/models/vehicle_page.dart';
import 'package:dio/dio.dart';

class FetchVehicle {
  Future<VehiclePage> fetch({
    required int page,
    String? licensePlate,
    String? brand,
    String? fleetGroupId,
    int limit = 20,
  }) async {
    if (DemoMode.isActive) {
      return VehiclePage.fromResponse(DemoData.vehicleList());
    }

    try {
      final res = await ApiClient.dio.get(
        '/master-vehicle/',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (licensePlate != null && licensePlate.trim().isNotEmpty)
            'search': licensePlate.trim(),
          if (brand != null && brand.isNotEmpty) 'brand': brand,
          if (fleetGroupId != null && fleetGroupId.isNotEmpty)
            'fleet_group_id': fleetGroupId,
        },
      );

      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw Exception(currentL10n().errInvalidResponse);
      }
      return VehiclePage.fromResponse(data);
    } on DioException catch (e) {
      // Pesan gagal dari backend hanya dipercaya kalau HTTP-nya memang gagal.
      throw Exception(apiErrorText(e, currentL10n().failedLoadData));
    }
  }
}
