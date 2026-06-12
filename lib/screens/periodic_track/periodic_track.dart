// ignore_for_file: deprecated_member_use

import 'package:ams/base/network/api_client.dart';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/back_button_circle.dart';
import 'package:ams/base/widgets/full_screen_loading.dart';
import 'package:ams/base/widgets/periodic_track_filter_sheet.dart';
import 'package:ams/base/widgets/tx_inputs.dart';
import 'package:ams/screens/periodic_track/services/fetch_periodic.dart';
import 'package:ams/screens/periodic_track/widgets/circle_button.dart';
import 'package:ams/screens/periodic_track/widgets/player_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'models/periodic_metric.dart';
import 'models/periodic_point.dart';
import 'widgets/periodic_chart.dart';
import 'widgets/periodic_map.dart';

class PeriodicTrackScreen extends StatefulWidget {
  const PeriodicTrackScreen({super.key});

  @override
  State<PeriodicTrackScreen> createState() => _PeriodicTrackScreenState();
}

class _PeriodicTrackScreenState extends State<PeriodicTrackScreen> {
  final MapController _mapController = MapController();

  bool _isLoading = false;
  List<PeriodicPoint> _data = [];

  int _currentIndex = 0;
  PeriodicMetric _metric = PeriodicMetric.speed;

  bool _isPlaying = true;

  final List<int> _speeds = const [200, 500, 1000, 1500, 2000];
  int _speedIndex = 2;

  final bool _autoCenter = true;

  bool _isSatellite = false;

  DateTime? _startDate;
  DateTime? _endDate;
  String? _licensePlate;

  late final PeriodicApi _periodicApi;
  bool _argLoaded = false;
  bool _isScrubbing = false;

  @override
  void initState() {
    super.initState();
    _periodicApi = PeriodicApi(ApiClient.dio);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_argLoaded) return;
    _argLoaded = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _startDate = args['startDate'] as DateTime?;
      _endDate = args['endDate'] as DateTime?;
      _licensePlate = args['licensePlate'] as String?;
    }

    _fetchData();
  }

  Future<void> _fetchData() async {
    if (_startDate == null || _endDate == null || _licensePlate == null) return;

    setState(() => _isLoading = true);

    try {
      final parsed = await _periodicApi.fetchPeriodic(
        startDate: _startDate!,
        endDate: _endDate!,
        licensePlate: _licensePlate!,
      );

      setState(() {
        _data = parsed;
        _currentIndex = 0;
        _isPlaying = true;
      });

      if (_data.isNotEmpty) {
        final p = _data.first;
        _mapController.move(LatLng(p.latitude, p.longitude), 16);
      }
    } catch (e) {
      debugPrint('fetch periodic error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onPickIndex(int idx) {
    if (_data.isEmpty) return;

    final safe = idx.clamp(0, _data.length - 1);
    setState(() {
      _currentIndex = safe;
      _isPlaying = false;
    });

    final p = _data[safe];
    _mapController.move(
      LatLng(p.latitude, p.longitude),
      _mapController.camera.zoom,
    );
  }

  void _onMetricChanged(PeriodicMetric? m) {
    if (m == null) return;
    setState(() => _metric = m);
  }

  void _togglePlay() {
    if (_data.length < 2) return;
    setState(() => _isPlaying = !_isPlaying);
  }

  void _increaseSpeed() {
    if (_speedIndex <= 0) return;
    setState(() => _speedIndex--);
  }

  void _decreaseSpeed() {
    if (_speedIndex >= _speeds.length - 1) return;
    setState(() => _speedIndex++);
  }

  void _onSliderChanged(double v) {
    if (_data.isEmpty) return;
    final idx = v.round().clamp(0, _data.length - 1);
    _onPickIndex(idx);
  }

  void _openFilter() {
    final plate = _licensePlate;
    if (plate == null || plate.trim().isEmpty) return;

    PeriodicTrackFilterSheet.open(
      context,
      licensePlate: plate,
      navMode: PeriodicFilterNavMode.replaceCurrent,
    );
  }

  void _toggleSatellite() {
    setState(() => _isSatellite = !_isSatellite);
  }

  void _resetToStart() {
    if (_data.isEmpty) return;

    setState(() {
      _currentIndex = 0;
      _isPlaying = false;
    });

    final p = _data.first;
    _mapController.move(
      LatLng(p.latitude, p.longitude),
      _mapController.camera.zoom,
    );
  }

  DateTime? _activeChartTime() {
    if (_data.isEmpty) return null;
    final idx = _currentIndex.clamp(0, _data.length - 1);
    final s = _data[idx].deviceTime;
    final fixed = s.replaceFirst(' ', 'T');
    return DateTime.tryParse(fixed);
  }

  void _onPlaybackIndexChanged(int idx) {
    if (!mounted) return;
    if (_data.isEmpty) return;

    if (_isScrubbing) return;

    final safe = idx.clamp(0, _data.length - 1);
    if (_currentIndex == safe) return;

    setState(() => _currentIndex = safe);
  }

  void _onSliderStart(double v) {
    setState(() => _isScrubbing = true);
  }

  void _onSliderDrag(double v) {
    if (_data.isEmpty) return;
    final idx = v.round().clamp(0, _data.length - 1);
    if (_currentIndex == idx) return;
    setState(() => _currentIndex = idx);
  }

  void _onSliderEnd(double v) {
    setState(() => _isScrubbing = false);
    _onSliderChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;
    final topPlayer = topPad + size.height * 0.35;

    final canSpeedUp = _speedIndex > 0;
    final canSpeedDown = _speedIndex < _speeds.length - 1;

    return Scaffold(
      body: Container(
        color: AppStyles.bgColor,
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            if (_data.isNotEmpty)
              SizedBox(
                width: size.width,
                height: size.height * 0.55,
                child: PeriodicMap(
                  mapController: _mapController,
                  points: _data,
                  currentIndex: _currentIndex,
                  metric: _metric,
                  autoCenter: _autoCenter,
                  onPointSelected: _onPickIndex,
                  isPlaying: _isPlaying,
                  speedIndex: _speedIndex,
                  isSatellite: _isSatellite,
                  onPlaybackIndexChanged: _onPlaybackIndexChanged,
                ),
              ),

            Positioned(left: 12, top: topPad + 10, child: BackButtonCircle()),

            Positioned(
              right: 12,
              top: topPad + size.height * 0.14,
              child: Column(
                children: [
                  CircleBtn(
                    icon: Icons.calendar_today_rounded,
                    onTap: _openFilter,
                  ),
                  const SizedBox(height: 10),
                  CircleBtn(
                    icon: _isSatellite
                        ? Icons.layers_rounded
                        : Icons.layers_outlined,
                    onTap: _toggleSatellite,
                  ),
                  const SizedBox(height: 10),
                  CircleBtn(icon: Icons.refresh_rounded, onTap: _resetToStart),
                ],
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              top: topPlayer,
              child: PlayerCard(
                isPlaying: _isPlaying,
                canSpeedUp: canSpeedUp,
                canSpeedDown: canSpeedDown,
                onSpeedUp: _increaseSpeed,
                onSpeedDown: _decreaseSpeed,
                onPlayPause: _togglePlay,
                value: _data.isEmpty ? 0.0 : _currentIndex.toDouble(),
                max: _data.isEmpty ? 0.0 : (_data.length - 1).toDouble(),

                onChangeStart: _onSliderStart,
                onChanged: _onSliderDrag,
                onChangeEnd: _onSliderEnd,
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: AppStyles.whiteColor,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Periodic Track',
                      style: AppStyles.textLBold.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 10),

                    TxInputDropdown<PeriodicMetric>(
                      label: '',
                      value: _metric,
                      items: PeriodicMetric.values
                          .map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text(m.label()),
                            ),
                          )
                          .toList(),
                      onChanged: _onMetricChanged,
                    ),

                    PeriodicChart(
                      points: _data,
                      metric: _metric,
                      activeTime: _activeChartTime(),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: FullScreenLoading(),
                ),
              ),

            if (!_isLoading && _data.isEmpty)
              const Center(child: Text('No Data')),
          ],
        ),
      ),
    );
  }
}
