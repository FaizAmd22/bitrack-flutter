// Padanan `schemas/workOrderStepTwoSchema.js` + `utils/workOrderValidation.js`.
// Di Flutter validasi dijalankan lewat Form/TextFormField, jadi yang dibutuhkan
// hanya potongan validator-nya. Pesan error dikirim dari pemanggil supaya bisa
// ikut bahasa aktif.

class WoValidators {
  WoValidators._();

  static final _digitsOnly = RegExp(r'^\d+$');

  static String? requiredField(String? value, String message) {
    return (value == null || value.trim().isEmpty) ? message : null;
  }

  static String? numeric(String? value, String message) {
    if (value == null || value.trim().isEmpty) return null;
    return _digitsOnly.hasMatch(value.trim()) ? null : message;
  }

  static String? maxLength(String? value, int max, String message) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim().length > max ? message : null;
  }

  /// Jalankan beberapa validator berurutan, ambil error pertama.
  static String? Function(String?) chain(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validate in validators) {
        final error = validate(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}

/// Jenis form step dua — menentukan field apa yang ditampilkan & divalidasi.
/// Urutannya mengikuti percabangan di `step-two-form.jsx`.
enum WorkDetailFormKind {
  gpsInspection,
  inspection,
  simCardReplacement,
  gpsInstallationReplacement,
  dashcamInstallationReplacement,
  sensorInstallationReplacement,
  none,
}

WorkDetailFormKind resolveFormKind(String? category, String? type) {
  final t = (type ?? '').toLowerCase().replaceAll('_', ' ');
  final c = (category ?? '').toLowerCase();

  if (c.contains('gps') && t == 'inspection') {
    return WorkDetailFormKind.gpsInspection;
  }
  if (t == 'inspection') return WorkDetailFormKind.inspection;
  if (t == 'sim card replacement' || t == 'simcard replacement') {
    return WorkDetailFormKind.simCardReplacement;
  }
  if (c.contains('gps') &&
      (t.contains('installation') || t.contains('replacement'))) {
    return WorkDetailFormKind.gpsInstallationReplacement;
  }
  if (c == 'dashcam' && (t == 'installation' || t == 'replacement')) {
    return WorkDetailFormKind.dashcamInstallationReplacement;
  }
  if (t == 'installation' || t == 'replacement') {
    return WorkDetailFormKind.sensorInstallationReplacement;
  }
  return WorkDetailFormKind.none;
}

bool isDismantle(String? type) => (type ?? '').toLowerCase() == 'dismantle';

bool isInspection(String? type) => (type ?? '').toLowerCase() == 'inspection';

bool isGpsCategory(String? category) => (category ?? '').toLowerCase() == 'gps';
