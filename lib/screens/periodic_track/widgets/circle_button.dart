import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const CircleBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppStyles.whiteColor,
      elevation: 3,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: AppStyles.primaryColor),
        ),
      ),
    );
  }
}
