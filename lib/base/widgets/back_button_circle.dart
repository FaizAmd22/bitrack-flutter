import 'package:ams/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class BackButtonCircle extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackButtonCircle({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppStyles.whiteColor,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed ?? () => Navigator.maybePop(context),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.arrow_back_ios_rounded,
            size: 18,
            color: AppStyles.blackColor,
          ),
        ),
      ),
    );
  }
}
