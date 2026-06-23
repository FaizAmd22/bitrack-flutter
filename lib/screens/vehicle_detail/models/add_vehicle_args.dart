enum AddVehicleStatus { create, update }

class AddVehicleArgs {
  final AddVehicleStatus status;
  final String? license;
  final String? id;

  const AddVehicleArgs({required this.status, this.license, this.id});
}
