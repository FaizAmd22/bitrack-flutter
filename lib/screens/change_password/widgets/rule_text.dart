// ignore_for_file: deprecated_member_use

import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class RuleText extends StatelessWidget {
  final String text;
  final bool ok;

  const RuleText(this.text, {super.key, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppStyles.textMd.copyWith(
          color: ok ? AppStyles.greenColor : AppStyles.redColor,
          fontSize: 12.5,
        ),
      ),
    );
  }
}
