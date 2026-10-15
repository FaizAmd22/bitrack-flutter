import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';

/// Key SharedPreferences tempat kode bahasa pilihan user disimpan.
const String kPrefLocaleCode = 'app_language_code';

/// Bahasa aktif app. Default Inggris sampai pilihan user selesai dibaca dari
/// SharedPreferences (sangat cepat, tapi asinkron).
///
/// Mengganti bahasa: [setLocale], dipanggil dari halaman Bahasa. `MaterialApp`
/// di `main.dart` me-watch [localeProvider], jadi seluruh UI ikut berganti.
class LocaleNotifier extends Notifier<Locale> {
  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// Salinan bahasa aktif di luar widget tree, supaya kelas Dart biasa
  /// (service/API) bisa mengambil teks terjemahan tanpa BuildContext.
  /// Lihat [currentL10n].
  static Locale current = const Locale('en');

  @override
  Locale build() {
    _loadSavedLocale();
    return const Locale('en');
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(kPrefLocaleCode) ?? 'en';
    current = Locale(code);
    state = current;
  }

  Future<void> setLocale(Locale locale) async {
    current = locale;
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kPrefLocaleCode, locale.languageCode);
  }
}

/// Provider bahasa aktif; di-watch `MaterialApp.locale`.
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

/// Teks terjemahan untuk bahasa aktif tanpa BuildContext. Dipakai di
/// service/API untuk menyusun pesan error. Di dalam widget, pakai
/// `AppLocalizations.of(context)`.
AppLocalizations currentL10n() =>
    lookupAppLocalizations(LocaleNotifier.current);
