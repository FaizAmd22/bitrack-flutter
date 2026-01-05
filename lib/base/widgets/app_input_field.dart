import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class AppInputField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final Color? prefixIconColor;
  final Color? suffixIconColor;

  const AppInputField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIconColor,
    this.suffixIconColor,
  });

  OutlineInputBorder _inputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final isFilled = value.text.trim().isNotEmpty;
        final baseColor = isFilled
            ? AppStyles.greenColor
            : const Color(0xFFE0E0E0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppStyles.textMdBold),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: keyboardType,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: placeholder,
                prefixIcon: prefixIcon != null
                    ? Icon(
                        prefixIcon,
                        color: prefixIconColor ?? AppStyles.textBlackColor,
                      )
                    : null,
                suffixIcon: suffixIcon != null
                    ? IconTheme(
                        data: IconThemeData(
                          color: suffixIconColor ?? AppStyles.textBlackColor,
                        ),
                        child: suffixIcon!,
                      )
                    : null,
                filled: true,
                fillColor: AppStyles.whiteColor,
                enabledBorder: _inputBorder(baseColor),
                focusedBorder: _inputBorder(baseColor),
                errorBorder: _inputBorder(AppStyles.redColor),
                focusedErrorBorder: _inputBorder(AppStyles.redColor),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
