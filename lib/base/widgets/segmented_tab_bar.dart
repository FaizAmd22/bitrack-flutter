// lib/base/widgets/segmented_tab_bar.dart
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class SegmentedTabBar extends StatelessWidget {
  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onChanged;
  final EdgeInsetsGeometry padding;

  const SegmentedTabBar({
    super.key,
    required this.labels,
    required this.activeIndex,
    required this.onChanged,
    this.padding = const EdgeInsets.all(4),
  });

  @override
  Widget build(BuildContext context) {
    final count = labels.length;
    final resolved = padding.resolve(Directionality.of(context));

    return LayoutBuilder(
      builder: (context, constraints) {
        // Lebar area dalam (setelah padding) dibagi rata per tab
        final innerWidth = constraints.maxWidth - resolved.horizontal;
        final tabWidth = innerWidth / count;

        return Container(
          decoration: BoxDecoration(
            color: AppStyles.inputDisableBg,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: padding,
          child: Stack(
            children: [
              // Indikator putih tunggal yang bergeser
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: tabWidth * activeIndex,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Label-label di atas indikator
              Row(
                children: List.generate(count, (i) {
                  final isActive = i == activeIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(i),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: isActive
                              ? AppStyles.textSmBold.copyWith(
                                  color: AppStyles.primaryColor,
                                )
                              : AppStyles.textSm.copyWith(
                                  color: AppStyles.textDarkGrayColor,
                                ),
                          child: Text(labels[i]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
