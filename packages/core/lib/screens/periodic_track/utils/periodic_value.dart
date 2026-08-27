import '../models/periodic_metric.dart';
import '../models/periodic_point.dart';

String getDisplayValue(PeriodicPoint p, PeriodicMetric metric) {
  switch (metric) {
    case PeriodicMetric.speed:
      return '${p.speed.toStringAsFixed(0)} KM/H';
    case PeriodicMetric.ignition:
      return p.ignition ? 'ON' : 'OFF';
    case PeriodicMetric.accu:
      return '${p.externalPowerVoltage.toStringAsFixed(1)} V';
    case PeriodicMetric.fuel:
      return '${p.fuelLevel.toStringAsFixed(0)} %';
    case PeriodicMetric.temperature:
      return 'Chiller 1: ${p.dallasTemp1.toStringAsFixed(1)}°C | Chiller 2: ${p.dallasTemp2.toStringAsFixed(1)}°C';
  }
}
