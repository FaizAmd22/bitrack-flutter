import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ams/screens/vehicle_detail/services/fetch_vehicle_detail.dart';
import 'package:flutter_riverpod/legacy.dart';

final vehicleIdProvider = StateProvider<String?>((ref) => null);

final vehicleDetailByVehicleIdProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, id) async {
      final vehicleId = id.trim();
      if (vehicleId.isEmpty) {
        throw Exception('vehicle_id kosong');
      }

      final api = const FetchVehicleDetail();
      final data = await api.getVehicleByVehicleId(vehicleId);
      return data;
    });
