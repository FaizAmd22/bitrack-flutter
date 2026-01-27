enum PeriodicMetric { speed, ignition, accu, fuel, temperature }

extension PeriodicMetricX on PeriodicMetric {
  String label() {
    switch (this) {
      case PeriodicMetric.speed:
        return 'Speed';
      case PeriodicMetric.ignition:
        return 'Ignition';
      case PeriodicMetric.accu:
        return 'Accu Voltage';
      case PeriodicMetric.fuel:
        return 'Fuel';
      case PeriodicMetric.temperature:
        return 'Temperature';
    }
  }
}
