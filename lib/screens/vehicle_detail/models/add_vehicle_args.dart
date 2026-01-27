enum AddVehicleStatus { create, update }

class AddVehicleArgs {
  final AddVehicleStatus status;
  final String? license;

  const AddVehicleArgs({required this.status, this.license});
}
