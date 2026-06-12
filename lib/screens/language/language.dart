import 'package:ams/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ams/base/localization/locale_controller.dart';
import 'package:ams/l10n/app_localizations.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translate = AppLocalizations.of(context);
    final selected = ref.watch(localeProvider).languageCode;

    Widget item(String title, String code) {
      final isSelected = selected == code;

      return InkWell(
        onTap: () => ref.read(localeProvider.notifier).setLocale(Locale(code)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 14)),
              ),
              if (isSelected)
                const Icon(
                  Icons.check,
                  size: 18,
                  color: AppStyles.primaryColor,
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        surfaceTintColor: AppStyles.bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(translate.language, style: AppStyles.textLBold),
      ),
      body: Column(
        children: [
          const SizedBox(height: 6),
          item(translate.english, 'en'),
          item(translate.indonesian, 'id'),
        ],
      ),
    );
  }
}
