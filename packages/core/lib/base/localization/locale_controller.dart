import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';

const String kPrefLocaleCode = 'app_language_code';

class LocaleNotifier extends Notifier<Locale> {
  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// Tracks the active locale outside of the widget tree so plain Dart
  /// classes (e.g. API/service layers) can resolve translated strings
  /// without a BuildContext.
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

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

/// Resolves [AppLocalizations] for the currently active locale without
/// requiring a BuildContext — for use in service/API classes that need to
/// surface a translated error message.
AppLocalizations currentL10n() =>
    lookupAppLocalizations(LocaleNotifier.current);
