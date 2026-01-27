// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';

class TxToggleTile extends StatelessWidget {
  const TxToggleTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final textColor = enabled ? AppStyles.blackColor : AppStyles.darkGrayColor;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppStyles.textMd.copyWith(color: textColor),
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppStyles.whiteColor,
            activeTrackColor: AppStyles.redColor,
            inactiveThumbColor: AppStyles.whiteColor,
            inactiveTrackColor: AppStyles.borderLightGray,
          ),
        ],
      ),
    );
  }
}
