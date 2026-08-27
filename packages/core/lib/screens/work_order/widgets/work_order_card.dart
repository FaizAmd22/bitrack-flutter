// ignore_for_file: deprecated_member_use

import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/screens/work_order/utils/format_date.dart';
import 'package:bitrack_core/screens/work_order/widgets/work_order_status_badge.dart';
import 'package:flutter/material.dart';

/// Padanan `components/work-order-card.jsx`.
class WorkOrderCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final String fleetGroupName;
  final String technicianName;
  final String languageCode;
  final VoidCallback onTap;

  const WorkOrderCard({
    super.key,
    required this.item,
    required this.fleetGroupName,
    required this.technicianName,
    required this.languageCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFrom = item['date_from']?.toString();
    final dateTo = item['date_to']?.toString();

    final dateText = [
      formatDateWithText(dateFrom, languageCode),
      if (dateTo != null && dateTo.trim().isNotEmpty)
        formatDateWithText(dateTo, languageCode),
    ].join(' - ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: AppStyles.whiteColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fleetGroupName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.textMdBold.copyWith(
                              color: AppStyles.blackColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (item['work_order_no'] ?? '-').toString(),
                            style: AppStyles.textSm.copyWith(
                              color: AppStyles.textDarkGrayColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    WorkOrderStatusBadge(status: item['status']?.toString()),
                  ],
                ),
                const SizedBox(height: 14),
                _IconLine(icon: Icons.calendar_today_outlined, text: dateText),
                const SizedBox(height: 6),
                _IconLine(icon: Icons.person_outline, text: technicianName),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppStyles.textDarkGrayColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.textSm.copyWith(color: AppStyles.textBlackColor),
          ),
        ),
      ],
    );
  }
}
