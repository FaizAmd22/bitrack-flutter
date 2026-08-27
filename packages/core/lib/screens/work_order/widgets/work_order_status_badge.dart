import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/screens/work_order/utils/format_label.dart';
import 'package:flutter/material.dart';

class WorkOrderStatusBadge extends StatelessWidget {
  final String? status;

  const WorkOrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final raw = status;
    if (raw == null || raw.trim().isEmpty) return const SizedBox.shrink();

    late final Color background;
    late final Color foreground;

    switch (raw.toLowerCase()) {
      case 'on_process':
        background = AppStyles.bgYellowColor;
        foreground = AppStyles.yellowColor;
        break;
      case 'completed':
        background = AppStyles.bgGreenColor;
        foreground = AppStyles.greenColor;
        break;
      default:
        background = AppStyles.bgGrayColor;
        foreground = AppStyles.darkGrayColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        formatStatus(raw),
        style: AppStyles.textXs.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
