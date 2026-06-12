// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:ams/base/res/media.dart';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class PeriodicTruckMarker extends StatelessWidget {
  final String tooltipText;
  final double bearingDeg;

  const PeriodicTruckMarker({
    super.key,
    required this.tooltipText,
    required this.bearingDeg,
  });

  @override
  Widget build(BuildContext context) {
    final rad = bearingDeg * math.pi / 180.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppStyles.primaryColor.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppStyles.primaryColor.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
        ),

        Positioned(
          top: -15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppStyles.blackColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(0, 6),
                  color: Color(0x22000000),
                ),
              ],
            ),
            child: Text(
              tooltipText,
              style: AppStyles.textSm.copyWith(color: AppStyles.whiteColor),
            ),
          ),
        ),

        Transform.rotate(
          angle: rad,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Image.asset(AppMedia.truckMoving, fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }
}
