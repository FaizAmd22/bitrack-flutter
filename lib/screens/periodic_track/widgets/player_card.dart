import 'package:ams/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class PlayerCard extends StatelessWidget {
  final bool isPlaying;
  final bool canSpeedUp;
  final bool canSpeedDown;
  final VoidCallback onSpeedUp;
  final VoidCallback onSpeedDown;
  final VoidCallback onPlayPause;

  final double value;
  final double max;

  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final ValueChanged<double>? onChangeStart;

  const PlayerCard({
    super.key,
    required this.isPlaying,
    required this.canSpeedUp,
    required this.canSpeedDown,
    required this.onSpeedUp,
    required this.onSpeedDown,
    required this.onPlayPause,
    required this.value,
    required this.max,
    required this.onChanged,
    this.onChangeEnd,
    this.onChangeStart,
  });

  double _safeMax() => max <= 0 ? 1.0 : max;

  double _clampDouble(double v) => v.clamp(0.0, _safeMax()).toDouble();

  @override
  Widget build(BuildContext context) {
    final safeMax = _safeMax();
    final shownValue = _clampDouble(value);

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(18),
      color: AppStyles.whiteColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: canSpeedDown ? onSpeedDown : null,
                icon: Icon(
                  Icons.fast_rewind_rounded,
                  color: canSpeedDown
                      ? AppStyles.blackColor
                      : AppStyles.textLightGrayColor,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: onPlayPause,
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: AppStyles.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: canSpeedUp ? onSpeedUp : null,
                icon: Icon(
                  Icons.fast_forward_rounded,
                  color: canSpeedUp
                      ? AppStyles.blackColor
                      : AppStyles.textLightGrayColor,
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const SizedBox(height: 24),
                Positioned(
                  top: -20,
                  left: 0,
                  right: 0,
                  child: Slider(
                    min: 0.0,
                    max: safeMax,
                    value: shownValue,
                    thumbColor: AppStyles.whiteColor,
                    activeColor: AppStyles.primaryColor,
                    onChangeStart: (safeMax <= 0) ? null : onChangeStart,
                    onChanged: (safeMax <= 0) ? null : onChanged,
                    onChangeEnd: (safeMax <= 0) ? null : onChangeEnd,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
