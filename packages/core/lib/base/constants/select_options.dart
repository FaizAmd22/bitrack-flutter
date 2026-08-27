import 'package:bitrack_core/l10n/app_localizations.dart';

class SelectOptions {
  final String label;
  final String value;
  const SelectOptions({required this.label, required this.value});
}

List<SelectOptions> vehicleCategoryOptions(AppLocalizations t) => [
  SelectOptions(label: t.vehicleCategoryBus, value: 'Bus'),
  SelectOptions(label: t.vehicleCategoryPassenger, value: 'Passanger'),
  SelectOptions(label: t.vehicleCategoryTruck, value: 'Truck'),
  SelectOptions(label: t.vehicleCategoryChiller, value: 'Chiller'),
  SelectOptions(label: t.vehicleCategoryFreezer, value: 'Freezer'),
  SelectOptions(
    label: t.vehicleCategoryChillerFreezer,
    value: 'Chiller & Freezer',
  ),
  SelectOptions(
    label: t.vehicleCategoryFreezerChiller,
    value: 'Freezer & Chiller',
  ),
];

const deviceTypeOptions = <SelectOptions>[
  SelectOptions(label: 'Teltonika', value: 'TELTONIKA'),
  SelectOptions(label: 'Concox', value: 'CONCOX'),
  SelectOptions(label: 'Ruptela', value: 'RUPTELA'),
];

const deviceModelOptions = <SelectOptions>[
  SelectOptions(label: 'FMB130', value: 'FMB130'),
  SelectOptions(label: 'FMB120', value: 'FMB120'),
];
