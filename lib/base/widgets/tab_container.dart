import 'package:flutter/material.dart';

class TabContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  final Color? backgroundColor;

  const TabContainer({
    super.key,
    required this.child,
    this.title,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.isNotEmpty) ...[
            Text(
              title!,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          Expanded(
            child: Align(alignment: Alignment.topLeft, child: child),
          ),
        ],
      ),
    );
  }
}
