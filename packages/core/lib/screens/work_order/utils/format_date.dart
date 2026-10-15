// Format tanggal untuk halaman Work Order (porting `functions/formatDate.js`
// dari app Cordova lama). Catatan: hanya membedakan Indonesia vs Inggris;
// bahasa lain memakai format Inggris.

import 'package:intl/intl.dart';

/// Baca tanggal dari server (`yyyy-MM-dd HH:mm:ss` atau ISO). Kosong/tidak
/// valid = null.
DateTime? parseDate(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return null;

  return DateTime.tryParse(value.replaceFirst(' ', 'T'));
}

/// "12 Agustus 2026" / "12 August 2026"
String formatDateWithText(String? raw, String languageCode) {
  final date = parseDate(raw);
  if (date == null) return '-';

  return DateFormat('d MMMM y', _locale(languageCode)).format(date);
}

/// "12 Agu 2026" / "12 Aug 2026"
String formatDateCard(String? raw, String languageCode) {
  final date = parseDate(raw);
  if (date == null) return '-';

  return DateFormat('d MMM y', _locale(languageCode)).format(date);
}

/// Format yang dikirim ke API: `yyyy-MM-dd`.
String formatDatePayload(DateTime date) =>
    DateFormat('yyyy-MM-dd').format(date);

String _locale(String languageCode) => languageCode == 'id' ? 'id_ID' : 'en_US';
