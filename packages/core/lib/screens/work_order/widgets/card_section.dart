// ignore_for_file: deprecated_member_use

import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

/// Padanan `components/cardSection.jsx` + `components/rowItem.jsx`.
class CardSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const CardSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppStyles.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.textMdBold.copyWith(color: AppStyles.blackColor),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class RowItem extends StatelessWidget {
  final String label;
  final String? value;

  const RowItem({super.key, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final text = (value ?? '').trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppStyles.textSm.copyWith(
                color: AppStyles.textDarkGrayColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text.isEmpty ? '-' : text,
              textAlign: TextAlign.right,
              style: AppStyles.textSm.copyWith(
                color: AppStyles.blackColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
