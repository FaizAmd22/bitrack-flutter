import 'package:flutter/material.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';

class AppDraggableSheet extends StatelessWidget {
  final String title;
  final List<double> snapSizes;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  final Widget Function(BuildContext, ScrollController) sliverBuilder;
  final Widget? bottom;

  const AppDraggableSheet({
    super.key,
    required this.title,
    required this.sliverBuilder,
    this.bottom,
    this.snapSizes = const [0.35, 0.55, 0.92],
    this.initialChildSize = 0.55,
    this.minChildSize = 0.35,
    this.maxChildSize = 0.92,
  });

  static bool _handleDismissOnMin(
    BuildContext context,
    DraggableScrollableNotification n,
  ) {
    if (n.extent <= (n.minExtent + 0.01) && n.extent == n.minExtent) {
      Navigator.maybePop(context);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      snap: true,
      snapSizes: snapSizes,
      builder: (context, scrollController) {
        return SheetSurface(
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (n) => _handleDismissOnMin(context, n),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  const _DragHandle(),
                  const SizedBox(height: 12),
                  _SheetHeader(title: title),
                  const SizedBox(height: 8),

                  Expanded(child: sliverBuilder(context, scrollController)),

                  if (bottom != null) bottom!,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SheetSurface extends StatelessWidget {
  final Widget child;
  const SheetSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppStyles.whiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 18)],
        ),
        child: child,
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 4,
      decoration: BoxDecoration(
        color: AppStyles.borderLightGray,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  const _SheetHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Align(alignment: Alignment.centerLeft, child: _HeaderText()),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
