import 'package:bitrack_core/l10n/app_localizations.dart';

/// Satu pilihan di dropdown/picker: [label] yang tampil, [value] yang dikirim
/// ke backend.
class SelectOptions {
  final String label;
  final String value;
  const SelectOptions({required this.label, required this.value});
}

/// Kategori kendaraan di form tambah kendaraan. [value] harus persis seperti
/// yang diharapkan backend, termasuk ejaan `'Passanger'`.
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

/// Merek device GPS yang didukung (form tambah kendaraan, langkah device).
const deviceTypeOptions = <SelectOptions>[
  SelectOptions(label: 'Teltonika', value: 'TELTONIKA'),
  SelectOptions(label: 'Concox', value: 'CONCOX'),
  SelectOptions(label: 'Ruptela', value: 'RUPTELA'),
];

/// Model device GPS (saat ini hanya model Teltonika).
const deviceModelOptions = <SelectOptions>[
  SelectOptions(label: 'FMB130', value: 'FMB130'),
  SelectOptions(label: 'FMB120', value: 'FMB120'),
];
