import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Padanan `pages/work-details/components/notes-tab.jsx`.
class NotesTab extends StatelessWidget {
  final TextEditingController controller;
  final bool readOnly;
  final ValueChanged<String> onChanged;

  const NotesTab({
    super.key,
    required this.controller,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(t.woNotesTitle, style: AppStyles.textMdBold),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          enabled: !readOnly,
          maxLines: 8,
          style: AppStyles.textMd.copyWith(
            color: readOnly ? AppStyles.darkGrayColor : AppStyles.blackColor,
          ),
          decoration: InputDecoration(
            hintText: t.woNotesPlaceholder,
            hintStyle: AppStyles.textMd.copyWith(
              color: AppStyles.textDarkGrayColor,
            ),
            filled: true,
            fillColor: readOnly ? AppStyles.inputDisableBg : Colors.transparent,
            contentPadding: const EdgeInsets.all(14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppStyles.borderLightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppStyles.primaryColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppStyles.inputDisableBg),
            ),
          ),
        ),
      ],
    );
  }
}
