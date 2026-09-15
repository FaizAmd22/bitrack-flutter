import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/periodic_track/models/playback_speed.dart';
import 'package:flutter/material.dart';

class PlayerCard extends StatelessWidget {
  final bool isPlaying;

  /// Ada titik sebelum/sesudah titik yang sedang aktif.
  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPlayPause;

  final PlaybackSpeed speed;
  final ValueChanged<PlaybackSpeed> onSpeedChanged;

  final double value;
  final double max;

  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final ValueChanged<double>? onChangeStart;

  /// Teks di atas tombol slider selama slider ditekan atau digeser, mis.
  /// waktu titik yang sedang dituju. Null = tanpa label.
  final String? valueLabel;

  const PlayerCard({
    super.key,
    required this.isPlaying,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
    required this.onPlayPause,
    required this.speed,
    required this.onSpeedChanged,
    required this.value,
    required this.max,
    required this.onChanged,
    this.onChangeEnd,
    this.onChangeStart,
    this.valueLabel,
  });

  /// Lebar kolom kiri dan kanan. Kanan berisi tombol kecepatan; kiri kosong
  /// selebar yang sama supaya tombol putar tetap tepat di tengah kartu.
  static const double _sideWidth = 64;

  double _safeMax() => max <= 0 ? 1.0 : max;

  double _clampDouble(double v) => v.clamp(0.0, _safeMax()).toDouble();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
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
            children: [
              const SizedBox(width: _sideWidth),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: t.previous,
                      onPressed: canPrev ? onPrev : null,
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        color: canPrev
                            ? AppStyles.blackColor
                            : AppStyles.textLightGrayColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: onPlayPause,
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppStyles.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: t.next,
                      onPressed: canNext ? onNext : null,
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: canNext
                            ? AppStyles.blackColor
                            : AppStyles.textLightGrayColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: _sideWidth,
                child: Center(
                  child: _SpeedButton(
                    speed: speed,
                    tooltip: t.speed,
                    onChanged: onSpeedChanged,
                  ),
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
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      // Slider ini kontinu (tanpa divisions). Bawaannya label
                      // hanya muncul untuk slider diskret.
                      showValueIndicator: ShowValueIndicator.onDrag,
                      // Persegi, bukan tetesan bawaan: teks tanggal + jam
                      // terlalu panjang untuk bentuk tetesan.
                      valueIndicatorShape:
                          const RectangularSliderValueIndicatorShape(),
                      valueIndicatorColor: AppStyles.blackColor.withValues(
                        alpha: 0.8,
                      ),
                      valueIndicatorTextStyle: AppStyles.textXs.copyWith(
                        color: AppStyles.whiteColor,
                      ),
                    ),
                    child: Slider(
                      label: valueLabel,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol berlabel kecepatan saat ini ("1x"); ditekan membuka pilihan.
class _SpeedButton extends StatelessWidget {
  const _SpeedButton({
    required this.speed,
    required this.tooltip,
    required this.onChanged,
  });

  final PlaybackSpeed speed;
  final String tooltip;
  final ValueChanged<PlaybackSpeed> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PlaybackSpeed>(
      tooltip: tooltip,
      initialValue: speed,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final s in PlaybackSpeed.values)
          PopupMenuItem<PlaybackSpeed>(
            value: s,
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: s == speed
                      ? const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: AppStyles.primaryColor,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(s.label),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppStyles.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          speed.label,
          style: AppStyles.textSmBold.copyWith(color: AppStyles.primaryColor),
        ),
      ),
    );
  }
}
