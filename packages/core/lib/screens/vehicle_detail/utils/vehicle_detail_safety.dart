// Pembaca nilai map API yang aman: tidak pernah melempar, dan nilai kosong
// / null / tipe salah diganti `fallback`. Dipakai di seluruh Vehicle Detail
// karena field response sering kosong atau berganti tipe.

/// Teks dari [key]; string kosong, "null", dan "undefined" dianggap kosong.
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

/// Angka desimal dari [key] (boleh berupa string).
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

/// Angka bulat dari [key] (boleh berupa string).
int safeIntFrom(Map<String, dynamic>? data, String key, {int fallback = 0}) {
  if (data == null) return fallback;
  final v = data[key];
  if (v == null) return fallback;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  return int.tryParse(s) ?? fallback;
}

/// Boolean dari [key]: menerima bool, angka (0/bukan 0), atau string
/// "true"/"false"/"1"/"0".
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
