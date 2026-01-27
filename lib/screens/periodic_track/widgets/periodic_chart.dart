// ignore_for_file: deprecated_member_use, unused_element

import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/periodic_metric.dart';
import '../models/periodic_point.dart';

class _ChartPoint {
  final DateTime dt;
  final double? value;
  const _ChartPoint({required this.dt, required this.value});
}

class PeriodicChart extends StatefulWidget {
  final List<PeriodicPoint> points;
  final PeriodicMetric metric;
  final DateTime? activeTime;

  const PeriodicChart({
    super.key,
    required this.points,
    required this.metric,
    required this.activeTime,
  });

  @override
  State<PeriodicChart> createState() => _PeriodicChartState();
}

class _PeriodicChartState extends State<PeriodicChart> {
  late final ZoomPanBehavior _zoomPan;
  late final TrackballBehavior _trackball;

  @override
  void initState() {
    super.initState();

    _zoomPan = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      zoomMode: ZoomMode.x,
      maximumZoomLevel: 0.02,
    );

    _trackball = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipSettings: const InteractiveTooltip(enable: true),
      lineType: TrackballLineType.vertical,
      markerSettings: const TrackballMarkerSettings(
        markerVisibility: TrackballVisibilityMode.visible,
        width: 8,
        height: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();

    final normalized = _normalize(widget.points);
    final withGaps = _insertGaps(normalized, gap: const Duration(minutes: 10));
    final data = _downsample(withGaps, maxPoints: 600);
    final DateTime? activeTime = widget.activeTime;
    final _ChartPoint? activePoint = (activeTime == null)
        ? null
        : _nearestPointByTime(data, activeTime);

    return SizedBox(
      height: 260,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        zoomPanBehavior: _zoomPan,
        trackballBehavior: _trackball,
        tooltipBehavior: TooltipBehavior(enable: true),
        enableAxisAnimation: false,

        primaryXAxis: DateTimeAxis(
          majorGridLines: const MajorGridLines(width: 0),
          maximumLabels: 6,
          intervalType: DateTimeIntervalType.hours,
          labelStyle: AppStyles.textXs,
          axisLabelFormatter: (AxisLabelRenderDetails d) {
            final dt = DateTime.fromMillisecondsSinceEpoch(d.value.toInt());
            final label =
                '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            return ChartAxisLabel(label, AppStyles.textXs);
          },

          plotBands: (activePoint == null)
              ? const <PlotBand>[]
              : <PlotBand>[
                  PlotBand(
                    isVisible: true,
                    start: activePoint.dt,
                    end: activePoint.dt,
                    borderWidth: 2,
                    borderColor: AppStyles.primaryColor,
                  ),
                ],
        ),

        primaryYAxis: NumericAxis(
          minimum: _minY(widget.metric),
          maximum: _maxY(widget.metric),
          interval: _intervalY(widget.metric),
          labelStyle: AppStyles.textXs,
          majorGridLines: MajorGridLines(
            width: 1,
            color: AppStyles.borderLightGray.withOpacity(0.7),
          ),
        ),

        series: <CartesianSeries<_ChartPoint, DateTime>>[
          AreaSeries<_ChartPoint, DateTime>(
            dataSource: data,
            xValueMapper: (p, _) => p.dt,
            yValueMapper: (p, _) => p.value,
            emptyPointSettings: const EmptyPointSettings(
              mode: EmptyPointMode.gap,
            ),
            borderColor: AppStyles.primaryColor,
            borderWidth: 2,
            color: AppStyles.primaryColor.withOpacity(0.18),
            markerSettings: const MarkerSettings(isVisible: false),
            animationDuration: 0,
          ),

          if (activePoint != null && activePoint.value != null)
            ScatterSeries<_ChartPoint, DateTime>(
              dataSource: <_ChartPoint>[activePoint],
              xValueMapper: (p, _) => p.dt,
              yValueMapper: (p, _) => p.value,
              dataLabelMapper: (p, _) => _formatValueLabel(p.value!),
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.top,
                color: AppStyles.blackColor.withOpacity(0.1),
                borderRadius: 8,
                textStyle: AppStyles.textXs.copyWith(color: Colors.white),
              ),
              markerSettings: MarkerSettings(
                isVisible: true,
                width: 12,
                height: 12,
                borderWidth: 3,
                color: Colors.white,
                borderColor: AppStyles.primaryColor,
              ),
              animationDuration: 0,
            ),
        ],
      ),
    );
  }

  _ChartPoint? _nearestPointByTime(List<_ChartPoint> data, DateTime t) {
    if (data.isEmpty) return null;

    int lo = 0;
    int hi = data.length - 1;

    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      if (data[mid].dt.isBefore(t)) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }

    _ChartPoint best = data[lo];
    Duration bestDiff = best.dt.difference(t).abs();

    if (lo - 1 >= 0) {
      final c = data[lo - 1];
      final d = c.dt.difference(t).abs();
      if (d < bestDiff) {
        best = c;
        bestDiff = d;
      }
    }

    if (best.value != null) return best;

    int l = lo - 1;
    int r = lo + 1;
    while (l >= 0 || r < data.length) {
      if (l >= 0 && data[l].value != null) return data[l];
      if (r < data.length && data[r].value != null) return data[r];
      l--;
      r++;
    }
    return best;
  }

  List<_ChartPoint> _normalize(List<PeriodicPoint> raw) {
    final list = raw
        .map(
          (p) => _ChartPoint(
            dt: _parseDeviceTime(p.deviceTime),
            value: _valueByMetric(p),
          ),
        )
        .toList();

    list.sort((a, b) => a.dt.compareTo(b.dt));
    return list;
  }

  List<_ChartPoint> _insertGaps(
    List<_ChartPoint> src, {
    required Duration gap,
  }) {
    if (src.length < 2) return src;

    final out = <_ChartPoint>[src.first];
    for (int i = 1; i < src.length; i++) {
      final prev = src[i - 1];
      final cur = src[i];

      if (cur.dt.difference(prev.dt) > gap) {
        out.add(
          _ChartPoint(dt: prev.dt.add(const Duration(seconds: 1)), value: null),
        );
      }
      out.add(cur);
    }
    return out;
  }

  List<_ChartPoint> _downsample(
    List<_ChartPoint> src, {
    required int maxPoints,
  }) {
    if (src.length <= maxPoints) return src;

    final step = (src.length / maxPoints).ceil();
    final out = <_ChartPoint>[];

    for (int i = 0; i < src.length; i += step) {
      out.add(src[i]);
    }
    if (out.last.dt != src.last.dt) out.add(src.last);
    return out;
  }

  DateTime _parseDeviceTime(String s) {
    final fixed = s.replaceFirst(' ', 'T');
    return DateTime.tryParse(fixed) ?? DateTime.now();
  }

  double _valueByMetric(PeriodicPoint p) {
    switch (widget.metric) {
      case PeriodicMetric.speed:
        return p.speed;
      case PeriodicMetric.ignition:
        return p.ignition ? 1.0 : 0.0;
      case PeriodicMetric.accu:
        return p.externalPowerVoltage;
      case PeriodicMetric.fuel:
        return p.fuelLevel;
      case PeriodicMetric.temperature:
        return p.dallasTemp1;
    }
  }

  double _minY(PeriodicMetric m) {
    switch (m) {
      case PeriodicMetric.speed:
      case PeriodicMetric.ignition:
      case PeriodicMetric.accu:
      case PeriodicMetric.fuel:
        return 0;
      case PeriodicMetric.temperature:
        return -10;
    }
  }

  double _maxY(PeriodicMetric m) {
    switch (m) {
      case PeriodicMetric.speed:
        return 80;
      case PeriodicMetric.ignition:
        return 1;
      case PeriodicMetric.accu:
        return 30;
      case PeriodicMetric.fuel:
        return 100;
      case PeriodicMetric.temperature:
        return 50;
    }
  }

  double _intervalY(PeriodicMetric m) {
    switch (m) {
      case PeriodicMetric.speed:
        return 20;
      case PeriodicMetric.ignition:
        return 1;
      case PeriodicMetric.accu:
        return 5;
      case PeriodicMetric.fuel:
        return 20;
      case PeriodicMetric.temperature:
        return 10;
    }
  }

  String _formatValueLabel(double v) {
    switch (widget.metric) {
      case PeriodicMetric.ignition:
        return v >= 0.5 ? 'ON' : 'OFF';
      case PeriodicMetric.speed:
        return '${v.toStringAsFixed(0)} KM/H';
      case PeriodicMetric.accu:
        return '${v.toStringAsFixed(1)} V';
      case PeriodicMetric.fuel:
        return '${v.toStringAsFixed(0)} %';
      case PeriodicMetric.temperature:
        return '${v.toStringAsFixed(1)} °C';
    }
  }
}

extension on Duration {
  Duration abs() => isNegative ? -this : this;
}
