// ignore_for_file: deprecated_member_use

import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class AppStepper extends StatefulWidget {
  const AppStepper({
    super.key,
    required this.steps,
    required this.stepContents,
    required this.formKeys,
    this.initialStep = 0,
    this.onStepChanged,
    this.onSubmit,
    this.nextLabel = 'Next',
    this.prevLabel = 'Previous',
    this.submitLabel = 'Add Vehicle',
    this.activeColor = AppStyles.primaryColor,
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.finishedColor = AppStyles.primaryColor,
    this.contentPadding = const EdgeInsets.fromLTRB(16, 12, 16, 16),
    this.buttonsPadding = const EdgeInsets.fromLTRB(16, 12, 16, 16),
    this.topGap = 0,
  });

  final List<String> steps;
  final List<Widget> stepContents;

  final List<GlobalKey<FormState>?> formKeys;

  final int initialStep;
  final ValueChanged<int>? onStepChanged;
  final VoidCallback? onSubmit;

  final String nextLabel;
  final String prevLabel;
  final String submitLabel;

  final Color activeColor;
  final Color inactiveColor;
  final Color finishedColor;

  final EdgeInsets contentPadding;
  final EdgeInsets buttonsPadding;
  final double topGap;

  @override
  State<AppStepper> createState() => _AppStepperState();
}

class _AppStepperState extends State<AppStepper> {
  late int _activeStep;

  int get _lastIndex => widget.steps.length - 1;
  bool get _isFirst => _activeStep == 0;
  bool get _isLast => _activeStep == _lastIndex;

  @override
  void initState() {
    super.initState();
    _activeStep = widget.initialStep.clamp(0, _lastIndex);
  }

  bool _validateCurrentStep() {
    if (_activeStep >= widget.formKeys.length) return true;
    final key = widget.formKeys[_activeStep];
    if (key == null) return true;

    final ok = key.currentState?.validate() ?? true;
    return ok;
  }

  void _goTo(int index) {
    final next = index.clamp(0, _lastIndex);
    if (next == _activeStep) return;
    setState(() => _activeStep = next);
    widget.onStepChanged?.call(_activeStep);
  }

  void _next() {
    if (_isLast) return;
    if (!_validateCurrentStep()) return;

    _goTo(_activeStep + 1);
  }

  void _prev() {
    if (_isFirst) return;
    _goTo(_activeStep - 1);
  }

  void _submit() {
    if (!_validateCurrentStep()) return;
    widget.onSubmit?.call();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.steps.length == widget.stepContents.length,
      'steps.length harus sama dengan stepContents.length',
    );
    assert(
      widget.formKeys.length == widget.steps.length,
      'formKeys.length harus sama dengan steps.length (boleh isi null untuk step tanpa form)',
    );

    return Column(
      children: [
        SizedBox(height: widget.topGap),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: 40,
            child: ClipRect(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(widget.steps.length, (i) {
                    final isDone = i < _activeStep;
                    final isActive = i == _activeStep;

                    return _TxStepHeaderItem(
                      title: widget.steps[i],
                      index: i,
                      isActive: isActive,
                      isDone: isDone,
                      activeColor: widget.activeColor,
                      inactiveColor: widget.inactiveColor,
                      doneColor: widget.finishedColor,
                      showConnector: i != widget.steps.length - 1,
                    );
                  }),
                ),
              ),
            ),
          ),
        ),

        Expanded(
          child: Padding(
            padding: widget.contentPadding,
            child: widget.stepContents[_activeStep],
          ),
        ),

        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(right: 10, left: 10, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isFirst ? null : _prev,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(
                        color: widget.activeColor.withOpacity(
                          _isFirst ? 0.4 : 1,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.prevLabel,
                      style: AppStyles.textMd.copyWith(
                        color: AppStyles.primaryColor.withOpacity(
                          _isFirst ? 0.4 : 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLast ? _submit : _next,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: widget.activeColor,
                      foregroundColor: AppStyles.whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isLast ? widget.submitLabel : widget.nextLabel,
                      style: AppStyles.textMd.copyWith(
                        color: AppStyles.whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TxStepHeaderItem extends StatelessWidget {
  const _TxStepHeaderItem({
    required this.title,
    required this.index,
    required this.isActive,
    required this.isDone,
    required this.activeColor,
    required this.inactiveColor,
    required this.doneColor,
    required this.showConnector,
  });

  final String title;
  final int index;
  final bool isActive;
  final bool isDone;

  final Color activeColor;
  final Color inactiveColor;
  final Color doneColor;

  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    final circleBg = isActive
        ? activeColor
        : (isDone ? doneColor : inactiveColor);
    const segmentGap = 60.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircleAvatar(
                backgroundColor: circleBg,
                child: isDone
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: AppStyles.whiteColor,
                      )
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppStyles.whiteColor,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 165),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.textMdBold,
              ),
            ),
          ],
        ),
        if (showConnector) ...[
          const SizedBox(width: 10),
          CustomPaint(
            size: const Size(segmentGap, 2),
            painter: _DashedLinePainter(
              color: isDone ? doneColor : inactiveColor,
              dashWidth: 6,
              dashSpace: 3,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final y = size.height / 2;

    while (startX < size.width) {
      final endX = (startX + dashWidth).clamp(0, size.width);
      canvas.drawLine(Offset(startX, y), Offset(endX.toDouble(), y), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
