final _plateRegex = RegExp(r'^[A-Z]{1,2}\d{1,4}[A-Z]{0,3}$');

bool isLikelyPlate(String input) {
  final raw = input.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  return _plateRegex.hasMatch(raw);
}

/// Format plat jadi "X 1234 YZ" — sesuaikan dengan formatPlateNumber Cordova-mu.
String normalizePlateForApi(String input) {
  final raw = input.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  final m = RegExp(r'^([A-Z]{1,2})(\d{1,4})([A-Z]{0,3})$').firstMatch(raw);
  if (m == null) return input.trim();
  final parts = [
    m.group(1),
    m.group(2),
    m.group(3),
  ].where((p) => p != null && p.isNotEmpty);
  return parts.join(' ');
}
