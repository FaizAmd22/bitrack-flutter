import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/widgets/option_picker_sheet.dart';
import 'package:flutter/material.dart';

/// Kolom form berbentuk dropdown: menampilkan label pilihan terpilih, dan
/// membuka [OptionPickerSheet] saat diketuk. Bisa divalidasi seperti
/// `TextFormField` lewat [validator] (ikut `Form.validate()`).
///
/// Dipakai di form tambah kendaraan dan form work order.
class PickerField extends StatelessWidget {
  final String label;
  final String hintText;

  /// `value` dari pilihan yang sedang terpilih (bukan label-nya); null =
  /// belum memilih, [hintText] yang tampil.
  final String? value;
  final List<PickerOption> options;
  final ValueChanged<PickerOption> onSelected;
  final String? Function(String?)? validator;
  final bool enabled;
  /// Tampilkan kolom cari di sheet pilihan (berguna untuk daftar panjang).
  final bool searchable;

  /// Judul sheet pilihan; default sama dengan [label].
  final String pickerTitle;
  final String? searchHint;

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
    this.searchHint,
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
        // Nilai dikontrol dari luar (prop [value]). Kalau berbeda dengan nilai
        // internal FormField, samakan setelah frame ini selesai (tidak boleh
        // memanggil didChange saat build).
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
