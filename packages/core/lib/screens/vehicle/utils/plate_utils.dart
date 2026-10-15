// Pola plat Indonesia tanpa spasi/tanda hubung: 1-2 huruf, 1-4 angka,
// 0-3 huruf (mis. B1234ABC).
final _plateRegex = RegExp(r'^[A-Z]{1,2}\d{1,4}[A-Z]{0,3}$');

/// True kalau teks terlihat seperti plat nomor (spasi dan `-` diabaikan).
/// (Saat ini tidak dipakai.)
bool isLikelyPlate(String input) {
  final raw = input.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  return _plateRegex.hasMatch(raw);
}

/// Format plat jadi `B 1234 ABC` (dipisah spasi). Teks yang tidak cocok
/// dengan pola plat dikembalikan apa adanya (hanya di-trim). (Saat ini tidak
/// dipakai.)
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
