// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:bitrack_core/base/res/media.dart';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/periodic_metric.dart';
import '../models/periodic_point.dart';
import '../utils/chart_series.dart';
import 'periodic_point_label.dart';

/// Batas jumlah titik yang digambar. Di atas ini seri dirangkum dengan
/// [downsampleM4], yang tetap mempertahankan puncak dan lembahnya.
const _maxRenderedPoints = 2000;

/// Lama label detail tampil sebelum hilang sendiri.
const _labelVisibleFor = Duration(seconds: 4);

/// Pin alert di grafik: ikon yang sama dengan pin di peta, sedikit lebih kecil
/// (di peta 36).
const _alertPinSize = 26.0;

/// Urutan seri: garis (0), alert (1), lalu penanda titik aktif.
const _alertSeriesIndex = 1;

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

  /// Semua titik, terurut waktu. Sumber nilai penanda — titik yang sama
  /// dengan yang dipakai peta.
  List<SeriesPoint> _normalized = const [];

  /// Seri yang digambar: sudah diberi jeda dan, kalau terlalu banyak,
  /// dirangkum.
  List<SeriesPoint> _series = const [];

  /// Seri yang benar-benar tampil pada build terakhir (termasuk titik aktif
  /// yang disisipkan). `pointIndex` dari trackball menunjuk ke list ini.
  List<SeriesPoint> _rendered = const [];

  /// Titik alert, digambar sebagai penanda merah seperti pin di peta.
  List<SeriesPoint> _alerts = const [];

  /// Alert per waktu, untuk memilih alert ketika ia berbagi detik yang sama
  /// dengan data rutin.
  Map<DateTime, SeriesPoint> _alertByTime = const {};

  /// Label yang dimunculkan lewat kode ([TrackballBehavior.show]) tidak
  /// disembunyikan Syncfusion; timer ini yang menyembunyikannya.
  Timer? _labelHideTimer;

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
      // Dengan nilai bawaan 0, Syncfusion memasang timer 0 ms saat jari
      // diangkat (doubleTapHideDelay juga 0), sehingga label langsung hilang
      // sebelum sempat terbaca. Nilai eksplisit menahannya beberapa detik.
      hideDelay: _labelVisibleFor.inMilliseconds.toDouble(),
      builder: _buildPointLabel,
      markerSettings: const TrackballMarkerSettings(
        markerVisibility: TrackballVisibilityMode.visible,
        width: 8,
        height: 8,
      ),
    );

    _rebuildSeries();
  }

  @override
  void didUpdateWidget(covariant PeriodicChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Hanya dihitung ulang saat datanya berubah. Selama pemutaran, grafik
    // di-build ulang setiap kali titik aktif berpindah; dulu setiap build itu
    // mengurutkan dan merangkum ulang seluruh data.
    if (oldWidget.points != widget.points ||
        oldWidget.metric != widget.metric) {
      _rebuildSeries();
    }
  }

  @override
  void dispose() {
    _labelHideTimer?.cancel();
    super.dispose();
  }

  void _rebuildSeries() {
    _normalized = normalizeSeries(widget.points, widget.metric);
    _series = downsampleM4(
      insertGaps(_normalized),
      maxPoints: _maxRenderedPoints,
      keep: isAlertPoint,
    );
    _alerts = _normalized.where(isAlertPoint).toList(growable: false);
    _alertByTime = {for (final a in _alerts) a.dt: a};
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();

    final activeTime = widget.activeTime;
    final activePoint = activeTime == null
        ? null
        : nearestByTime(_normalized, activeTime);
    final data = withActivePoint(_series, activePoint);
    _rendered = data;

    return SizedBox(
      height: 260,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        zoomPanBehavior: _zoomPan,
        trackballBehavior: _trackball,
        onDataLabelTapped: _onDataLabelTapped,
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

        series: <CartesianSeries<SeriesPoint, DateTime>>[
          AreaSeries<SeriesPoint, DateTime>(
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

          if (_alerts.isNotEmpty)
            ScatterSeries<SeriesPoint, DateTime>(
              // Pin ini ditekan lewat `onDataLabelTapped` di chart, bukan
              // GestureDetector: Syncfusion tidak pernah meneruskan hit test
              // ke widget buatan `builder` (hitTestChildren selalu false).
              enableTrackball: false,
              dataSource: _alerts,
              xValueMapper: (p, _) => p.dt,
              yValueMapper: (p, _) => p.value,
              // Titik merah kecil menandai posisi persisnya; pin di atasnya
              // yang dilihat dan ditekan user.
              markerSettings: const MarkerSettings(
                isVisible: true,
                width: 6,
                height: 6,
                borderWidth: 0,
                color: AppStyles.redColor,
              ),
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                // Ujung pin menunjuk titiknya dari atas. Di tengah, pin untuk
                // alert bernilai 0 akan terpotong sumbu.
                labelAlignment: ChartDataLabelAlignment.top,
                margin: EdgeInsets.zero,
                // Bawaannya `shift`: pin yang berdekatan digeser menjauh dari
                // waktu kejadiannya. `none` membiarkannya di tempat.
                labelIntersectAction: LabelIntersectAction.none,
                builder: (data, point, series, pointIndex, seriesIndex) =>
                    const _AlertPin(),
              ),
              animationDuration: 0,
            ),

          if (activePoint != null && activePoint.value != null)
            ScatterSeries<SeriesPoint, DateTime>(
              // Penanda titik aktif bukan data yang perlu diperiksa dan sudah
              // punya label nilainya sendiri; dikecualikan supaya label detail
              // hanya pernah berasal dari seri data.
              enableTrackball: false,
              dataSource: <SeriesPoint>[activePoint],
              xValueMapper: (p, _) => p.dt,
              yValueMapper: (p, _) => p.value,
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.top,
                // Label penggaris sama dengan label saat titik ditekan:
                // waktu, nilai, dan event titik yang sedang diputar.
                builder: (data, point, series, pointIndex, seriesIndex) {
                  final source = (data as SeriesPoint).source;
                  if (source == null) return const SizedBox.shrink();
                  return PeriodicPointLabel(
                    point: source,
                    metric: widget.metric,
                  );
                },
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

  Widget _buildPointLabel(BuildContext context, TrackballDetails details) {
    final source = _pointFor(details)?.source;
    if (source == null) return const SizedBox.shrink();
    return PeriodicPointLabel(point: source, metric: widget.metric);
  }

  /// Pin alert ditekan: tampilkan label detail tepat di alert itu.
  ///
  /// Trackball biasa memilih titik dengan x terdekat. Pada data padat, titik
  /// terdekat dari jari sering data rutin di sebelah alert, jadi alert nyaris
  /// mustahil dipilih dengan menekan garisnya.
  void _onDataLabelTapped(DataLabelTapDetails details) {
    if (details.seriesIndex != _alertSeriesIndex) return;
    final i = details.pointIndex;
    if (i < 0 || i >= _alerts.length) return;

    final alert = _alerts[i];
    _trackball.show(alert.dt, alert.value ?? 0);
    _labelHideTimer?.cancel();
    _labelHideTimer = Timer(_labelVisibleFor, _trackball.hide);
  }

  SeriesPoint? _pointFor(TrackballDetails details) {
    final p = _trackedPoint(details);
    // Alert dan data rutin bisa berbagi detik yang sama. Alert yang dipilih,
    // karena itulah yang ingin dilihat user.
    return p == null ? null : (_alertByTime[p.dt] ?? p);
  }

  /// Titik yang sedang ditunjuk trackball. Utamanya lewat `pointIndex`, dengan
  /// cadangan berdasarkan waktu (sumbu-x) kalau indeksnya tidak cocok dengan
  /// seri yang tampil.
  SeriesPoint? _trackedPoint(TrackballDetails details) {
    final i = details.pointIndex;
    final x = details.point?.x;
    if (i != null && i >= 0 && i < _rendered.length) {
      final p = _rendered[i];
      if (p.source != null && (x is! DateTime || p.dt == x)) return p;
    }
    return x is DateTime ? nearestByTime(_normalized, x) : null;
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
}

/// Pin alert di grafik.
class _AlertPin extends StatelessWidget {
  const _AlertPin();

  @override
  Widget build(BuildContext context) {
    // Padding memperluas area tekan — `onDataLabelTapped` mencocokkan tap
    // dengan batas widget ini — tanpa membesarkan ikonnya. Tanpa padding
    // bawah supaya ujung pin tetap menempel ke titiknya.
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
      child: SvgPicture.asset(
        AppMedia.alertIcon,
        width: _alertPinSize,
        height: _alertPinSize,
      ),
    );
  }
}
