// ignore_for_file: deprecated_member_use

import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class TxPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;

  const TxPasswordField({
    super.key,
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: TextInputType.visiblePassword,
      style: AppStyles.textMd.copyWith(color: AppStyles.blackColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppStyles.textMd.copyWith(
          color: AppStyles.textDarkGrayColor,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppStyles.borderLightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppStyles.borderLightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppStyles.primaryColor, width: 1.2),
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppStyles.primaryColor,
          ),
        ),
      ),
    );
  }
}
