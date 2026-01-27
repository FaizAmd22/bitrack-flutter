String safeTextFrom(
  Map<String, dynamic>? data,
  String key, {
  String fallback = '-',
}) {
  if (data == null) return fallback;
  final v = data[key];
  if (v == null) return fallback;
  final s = v.toString().trim();
  return s.isEmpty ||
          s.toLowerCase() == 'null' ||
          s.toLowerCase() == 'undefined'
      ? fallback
      : s;
}

double safeDoubleFrom(
  Map<String, dynamic>? data,
  String key, {
  double fallback = 0,
}) {
  if (data == null) return fallback;
  final v = data[key];
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  final s = v.toString().trim();
  return double.tryParse(s) ?? fallback;
}

int safeIntFrom(Map<String, dynamic>? data, String key, {int fallback = 0}) {
  if (data == null) return fallback;
  final v = data[key];
  if (v == null) return fallback;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  return int.tryParse(s) ?? fallback;
}

bool safeBoolFrom(
  Map<String, dynamic>? data,
  String key, {
  bool fallback = false,
}) {
  if (data == null) return fallback;
  final v = data[key];
  if (v == null) return fallback;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().trim().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return fallback;
}
