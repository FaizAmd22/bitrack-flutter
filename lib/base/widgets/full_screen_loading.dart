// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FullScreenLoading extends StatelessWidget {
  final double opacity;
  final bool withBackgroundBlur;

  const FullScreenLoading({
    super.key,
    this.opacity = 0.3,
    this.withBackgroundBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.black.withOpacity(opacity)),

        if (withBackgroundBlur)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(color: Colors.transparent),
          ),

        Center(
          child: Lottie.asset(
            'assets/images/loading-blue.json',
            width: 160,
            height: 160,
            fit: BoxFit.contain,
            repeat: true,
          ),
        ),
      ],
    );
  }
}
