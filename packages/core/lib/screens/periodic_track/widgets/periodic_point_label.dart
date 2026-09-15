import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

import '../models/periodic_metric.dart';
import '../models/periodic_point.dart';
import '../utils/periodic_value.dart';

/// Label detail yang muncul saat titik pada grafik Periodic Track ditekan:
/// waktu, nilai metrik yang sedang dipilih, dan event titik tersebut.
///
/// Formatnya mengikuti sheet detail di peta (PeriodicAlertSheet): waktu
/// ditampilkan apa adanya dari `device_time` dengan akhiran WIB, nilainya
/// lewat [getDisplayValue] yang juga dipakai tooltip peta, dan titik dianggap
/// alert bila `eventType`-nya bukan SAMPLING.
class PeriodicPointLabel extends StatelessWidget {
  const PeriodicPointLabel({
    super.key,
    required this.point,
    required this.metric,
  });

  final PeriodicPoint point;
  final PeriodicMetric metric;

  bool get isAlert => point.isAlert;

  String get eventText =>
      point.eventName.trim().isNotEmpty ? point.eventName : point.eventType;

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xB3FFFFFF);

    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppStyles.blackColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${point.deviceTime} WIB',
            style: AppStyles.textXs.copyWith(color: muted),
          ),
          const SizedBox(height: 2),
          Text(
            getDisplayValue(point, metric),
            style: AppStyles.textSmBold.copyWith(color: AppStyles.whiteColor),
          ),
          const SizedBox(height: 4),
          if (isAlert)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppStyles.redColor,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    eventText,
                    style: AppStyles.textXsBold.copyWith(
                      color: AppStyles.whiteColor,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(eventText, style: AppStyles.textXs.copyWith(color: muted)),
        ],
      ),
    );
  }
}
