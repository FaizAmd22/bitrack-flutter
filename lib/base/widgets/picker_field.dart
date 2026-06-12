// lib/base/widgets/picker_field.dart
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/option_picker_sheet.dart';
import 'package:flutter/material.dart';

class PickerField extends StatelessWidget {
  final String label;
  final String hintText;
  final String? value; // selected value
  final List<PickerOption> options;
  final ValueChanged<PickerOption> onSelected;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool searchable;
  final String pickerTitle;
  final String searchHint;

  const PickerField({
    super.key,
    required this.label,
    required this.hintText,
    required this.value,
    required this.options,
    required this.onSelected,
    this.validator,
    this.enabled = true,
    this.searchable = false,
    String? pickerTitle,
    this.searchHint = 'Cari...',
  }) : pickerTitle = pickerTitle ?? label;

  @override
  Widget build(BuildContext context) {
    final selectedOption = value == null
        ? null
        : options
              .where((o) => o.value == value)
              .cast<PickerOption?>()
              .firstOrNull;
    final displayText = selectedOption?.label;

    return FormField<String>(
      initialValue: value,
      validator: validator,
      builder: (state) {
        // sinkronkan nilai eksternal ke FormField
        if (state.value != value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            state.didChange(value);
          });
        }

        final hasError = state.hasError;
        final borderColor = hasError
            ? AppStyles.redColor
            : AppStyles.borderLightGray;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppStyles.textMdBold),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: enabled
                  ? () async {
                      final picked = await OptionPickerSheet.open(
                        context,
                        title: pickerTitle,
                        options: options,
                        selected: selectedOption,
                        searchable: searchable,
                        searchHint: searchHint,
                      );
                      if (picked != null) {
                        onSelected(picked);
                        state.didChange(picked.value);
                      }
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: enabled
                      ? AppStyles.whiteColor
                      : AppStyles.inputDisableBg,
                  border: Border.all(color: borderColor, width: 1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayText ?? hintText,
                        style: AppStyles.textMd.copyWith(
                          color: displayText == null
                              ? AppStyles.textDarkGrayColor
                              : AppStyles.blackColor,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppStyles.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 6),
              Text(
                state.errorText!,
                style: AppStyles.textXs.copyWith(color: AppStyles.redColor),
              ),
            ],
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}
