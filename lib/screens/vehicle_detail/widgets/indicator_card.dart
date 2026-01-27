// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';

class IndicatorItemData {
  final String icon;
  final String label;
  final Color background;
  final Color color;

  const IndicatorItemData({
    required this.icon,
    required this.label,
    required this.background,
    required this.color,
  });
}

class IndicatorCard extends StatelessWidget {
  final List<IndicatorItemData> items;

  const IndicatorCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Expanded(child: _IndicatorItem(data: items[i])),
            if (i != items.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _IndicatorItem extends StatelessWidget {
  final IndicatorItemData data;

  const _IndicatorItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
        decoration: BoxDecoration(
          color: data.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/${data.icon}',
              width: 30,
              height: 30,
              color: data.color,
            ),
            const SizedBox(height: 3),
            Text(
              data.label,
              style: AppStyles.textSm.copyWith(color: data.color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
