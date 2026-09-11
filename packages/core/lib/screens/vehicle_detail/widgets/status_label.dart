import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Label status kendaraan (MOVING/IDLE/STOP/SILENCE/...).
///
/// Warnanya mengikuti aturan yang sama dengan aset marker truk: MOVING hijau,
/// IDLE kuning, STOP merah, selebihnya abu-abu.
class StatusLabel extends StatelessWidget {
  const StatusLabel({super.key, required this.activity});

  /// Kode status dari server. Huruf besar-kecil tidak berpengaruh.
  final String activity;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final code = activity.trim().toUpperCase();

    final (String label, Color fg, Color bg) = switch (code) {
      'MOVING' => (
        t.activityMoving,
        AppStyles.greenColor,
        AppStyles.bgGreenColor,
      ),
      'IDLE' => (
        t.activityIdle,
        AppStyles.yellowColor,
        AppStyles.bgYellowColor,
      ),
      'STOP' => (t.activityStop, AppStyles.redColor, AppStyles.bgRedColor),
      'SILENCE' => (
        t.activitySilence,
        AppStyles.darkGrayColor,
        AppStyles.bgGrayColor,
      ),
      'IN_OPERATION' => (
        t.activityInOperation,
        AppStyles.darkGrayColor,
        AppStyles.bgGrayColor,
      ),
      'REPAIR' || 'IN_REPAIR' => (
        t.activityInRepair,
        AppStyles.darkGrayColor,
        AppStyles.bgGrayColor,
      ),
      // Kode yang belum dikenal tetap ditampilkan apa adanya, jangan hilang.
      _ => (code, AppStyles.darkGrayColor, AppStyles.bgGrayColor),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: AppStyles.textSmBold.copyWith(color: fg)),
    );
  }
}
