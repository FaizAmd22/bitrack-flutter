import 'package:flutter/material.dart';

class TabContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  final Color? backgroundColor;

  final double maxHeightFactor;

  const TabContainer({
    super.key,
    required this.child,
    this.title,
    this.backgroundColor,
    this.maxHeightFactor = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * maxHeightFactor;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxH),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null && title!.isNotEmpty) ...[
                Text(
                  title!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
