// ignore_for_file: deprecated_member_use

import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class AppTabBar<T> extends StatelessWidget {
  final List<AppTabItem<T>> tabs;
  final T activeValue;
  final ValueChanged<T> onChanged;
  final EdgeInsets padding;
  final double height;
  final BorderRadius borderRadius;

  const AppTabBar({
    super.key,
    required this.tabs,
    required this.activeValue,
    required this.onChanged,
    this.padding = const EdgeInsets.all(4),
    this.height = 44,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppStyles.bgGrayColor,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: tabs.map((tab) {
          final isActive = tab.value == activeValue;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => onChanged(tab.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? AppStyles.whiteColor : Colors.transparent,
                  borderRadius: borderRadius,
                ),
                child:
                    tab.child ??
                    Text(
                      tab.label ?? '',
                      style: AppStyles.textMd.copyWith(
                        color: isActive
                            ? AppStyles.primaryColor
                            : AppStyles.textDarkGrayColor,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AppTabItem<T> {
  final T value;
  final String? label;
  final Widget? child;

  const AppTabItem({required this.value, this.label, this.child})
    : assert(label != null || child != null);
}
