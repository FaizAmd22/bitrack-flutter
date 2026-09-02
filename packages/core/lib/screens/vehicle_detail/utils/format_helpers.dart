import 'package:bitrack_core/base/localization/locale_controller.dart';
import 'package:intl/intl.dart';

/// Pengganti src/functions/getHoursMinutes.js, formatDate.js,
/// getRelativeTime.js, getPlainText.js.

/// Bahasa yang dipakai kalau pemanggil tidak menyebutkannya.
///
/// Dulu default-nya `'id'` yang dihardcode, sehingga setiap pemanggil yang
/// lupa mengoper bahasa diam-diam menampilkan tanggal berbahasa Indonesia
/// walau app di-set ke English — dan itu terjadi di beberapa tempat.
/// Mengambilnya dari [LocaleNotifier.current] membuat "lupa mengoper"
/// menghasilkan perilaku yang benar, bukan yang salah.
String _resolveLanguage(String? language) =>
    language ?? LocaleNotifier.current.languageCode;

/// Locale untuk [DateFormat].
///
/// Kode bahasa dipakai apa adanya karena simbol tanggal untuk locale aktif
/// sudah didaftarkan oleh GlobalMaterialLocalizations. Bahasa di luar yang
/// didukung app jatuh ke `en` supaya tidak melempar LocaleDataException.
String _dateLocale(String? language) {
  final code = _resolveLanguage(language);
  final supported = LocaleNotifier.supportedLocales.any(
    (locale) => locale.languageCode == code,
  );
  return supported ? code : 'en';
}

/// Pengganti getHoursMinutes(isoString) — "HH:mm" waktu lokal.
String getHoursMinutes(String? isoString) {
  if (isoString == null || isoString.isEmpty) return '--:--';
  final date = DateTime.parse(isoString).toLocal();
  final hours = date.hour.toString().padLeft(2, '0');
  final minutes = date.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

enum DateFormatType { standard, withWeekdays, monthYear, withTime, cardShort }

/// Pengganti formatDate(date, language, type).
///
/// [language] opsional — kalau null, dipakai bahasa aktif app. Lihat
/// [_resolveLanguage].
/// Dipakai skeleton ([DateFormat.yMMMMd] dkk), bukan pola literal seperti
/// `'d MMMM y'`. Pola literal mengunci urutan hari-bulan-tahun ala Barat,
/// yang menghasilkan "2 9月 2026" di bahasa Jepang alih-alih "2026年9月2日".
/// Skeleton menyerahkan urutannya ke konvensi masing-masing bahasa.
String formatDate(
  DateTime date, [
  String? language,
  DateFormatType type = DateFormatType.standard,
]) {
  final locale = _dateLocale(language);
  final formatter = switch (type) {
    DateFormatType.withWeekdays => DateFormat.yMMMMEEEEd(locale),
    DateFormatType.monthYear => DateFormat.yMMMM(locale),
    DateFormatType.withTime => DateFormat.yMMMMd(locale).add_Hm(),
    DateFormatType.standard => DateFormat.yMMMMd(locale),
    DateFormatType.cardShort => DateFormat.yMMMd(locale),
  };
  return formatter.format(date.toLocal());
}

/// Pengganti getRelativeTime(dateString, language).
///
/// Teksnya diambil dari berkas bahasa, bukan lagi ditulis di dalam kode.
/// Versi sebelumnya punya cabang id/en, tapi parameter bahasanya berdefault
/// `'id'` dan TIDAK ADA satu pun pemanggil yang mengisinya — jadi cabang
/// Inggrisnya tidak pernah dieksekusi sekali pun. Parameter itu dihapus:
/// bahasanya selalu bahasa aktif app.
///
/// Bentuk tunggal dan jamak diurus ICU plural di berkas .arb, jadi tiap
/// bahasa memilih sendiri apakah perlu membedakannya — bahasa Inggris perlu
/// ("1 minutes ago" salah), bahasa Indonesia, Jepang, Korea, dan Mandarin
/// tidak.
String getRelativeTime(String? dateString) {
  // `device_time` dari API berbentuk "2026-09-02 14:30:00" (spasi, bukan `T`)
  // dan bisa kosong — sama seperti parseDate() di work_order/format_date.dart.
  final raw = (dateString ?? '').trim();
  final parsed = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  if (parsed == null) return '-';

  final date = parsed.toLocal();
  final seconds = DateTime.now().difference(date).inSeconds;
  final t = currentL10n();

  if (seconds < 5) return t.relativeJustNow;
  if (seconds < 60) return t.relativeSeconds(seconds);

  final days = seconds ~/ 86400;
  if (days >= 365) return t.relativeYears(days ~/ 365);
  if (days >= 30) return t.relativeMonths(days ~/ 30);
  if (days >= 7) return t.relativeWeeks(days ~/ 7);
  // "kemarin" lebih alami daripada "1 hari yang lalu".
  if (days >= 1) return days == 1 ? t.relativeYesterday : t.relativeDays(days);

  final hours = seconds ~/ 3600;
  if (hours >= 1) return t.relativeHours(hours);
  return t.relativeMinutes(seconds ~/ 60);
}

/// Pengganti getPlainTextDashboard(html, maxLength) — strip tag HTML kasar
/// (regex, bukan DOM parser karena tidak ada DOM di Flutter).
String getPlainTextDashboard(String html, [int maxLength = 80]) {
  final text = html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  return text.length > maxLength ? '${text.substring(0, maxLength)}...' : text;
}

/// Pengganti formatPeriodLabel(period, language) — period bentuk "YYYY-MM".
///
/// [language] opsional; kalau null dipakai bahasa aktif app.
///
/// Nama bulan diambil dari [DateFormat], bukan lagi dari dua daftar id/en
/// yang ditulis di kode — daftar itu hanya mengenal dua dari lima bahasa
/// yang didukung app, dan bulannya selalu disingkat ala Inggris.
String formatPeriodLabel(String period, [String? language]) {
  if (period.isEmpty) return '';
  final parts = period.split('-');
  if (parts.length < 2) return period;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  if (year == null || month == null) return period;
  return DateFormat.yMMM(
    _dateLocale(language),
  ).format(DateTime(year, month.clamp(1, 12)));
}

/// Pengganti src/functions/calculateDays.js — selisih hari inklusif.
int calculateDays(DateTime start, DateTime end) {
  final startDate = DateTime(start.year, start.month, start.day);
  final endDate = DateTime(end.year, end.month, end.day);
  return endDate.difference(startDate).inDays + 1;
}

/// Pengganti TZ_OFFSET='+07:00' / buildISO(date, time) di
/// usePermissionSubmission.js dan useLeaveSubmission.js — waktu dikirim
/// sebagai WIB (+07:00) eksplisit, bukan berdasarkan timezone lokal device,
/// supaya konsisten dengan zona waktu server.
String toWibIso(DateTime date, {String time = '18:00'}) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-${d}T$time:00+07:00';
}
