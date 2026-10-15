import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Data yang bisa dipilih untuk ditampilkan di grafik dan tooltip Periodic
/// Track: kecepatan, status mesin, tegangan aki, bahan bakar, suhu chiller.
enum PeriodicMetric { speed, ignition, accu, fuel, temperature }

/// Label terjemahan tiap metrik.
extension PeriodicMetricX on PeriodicMetric {
  String label(BuildContext context) {
    final t = AppLocalizations.of(context);
    switch (this) {
      case PeriodicMetric.speed:
        return t.vehicleStatusSpeed;
      case PeriodicMetric.ignition:
        return t.periodicMetricIgnition;
      case PeriodicMetric.accu:
        return t.periodicMetricAccuVoltage;
      case PeriodicMetric.fuel:
        return t.vehicleSensorFuel;
      case PeriodicMetric.temperature:
        return t.periodicMetricTemperature;
    }
  }
}
