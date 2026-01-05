import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/services/fetch_vehicle_detail.dart';
import 'package:flutter_riverpod/legacy.dart'
    show StateProvider, StateNotifier, StateNotifierProvider;

final vehicleIdProvider = StateProvider<String?>((ref) => null);

class VehicleInformationState {
  final String vehicleId;
  final Map<String, dynamic> detailVehicle;

  const VehicleInformationState({
    required this.vehicleId,
    required this.detailVehicle,
  });
}

class VehicleInformationNotifier
    extends StateNotifier<AsyncValue<VehicleInformationState>> {
  VehicleInformationNotifier(this.ref) : super(const AsyncValue.loading());

  final Ref ref;
  final _fetchVehicle = const FetchVehicleDetail();

  Future<void> load(String vehicleId) async {
    state = const AsyncValue.loading();

    try {
      final id = vehicleId.trim();
      if (id.isEmpty) throw Exception('vehicleId kosong');

      // simpan agar bisa dipakai di widget lain
      ref.read(vehicleIdProvider.notifier).state = id;

      // fetch /vehicle_id
      final vehicleData = await _fetchVehicle.getVehicleByVehicleId(id);

      state = AsyncValue.data(
        VehicleInformationState(vehicleId: id, detailVehicle: vehicleData),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final vehicleInformationProvider = StateNotifierProvider.autoDispose
    .family<
      VehicleInformationNotifier,
      AsyncValue<VehicleInformationState>,
      String
    >((ref, vehicleId) {
      final notifier = VehicleInformationNotifier(ref);
      notifier.load(vehicleId);
      return notifier;
    });
