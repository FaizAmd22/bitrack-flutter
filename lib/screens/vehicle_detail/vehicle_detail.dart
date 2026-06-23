// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/back_button_circle.dart';
import 'package:ams/base/widgets/full_screen_loading.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/vehicle_detail/providers/vehicle_information_provider.dart';
import 'package:ams/screens/vehicle_detail/services/fetch_address.dart';
import 'package:ams/screens/vehicle_detail/services/fetch_monitoring_detail.dart';
import 'package:ams/screens/vehicle_detail/utils/flatten_monitoring_detail.dart';
import 'package:ams/screens/vehicle_detail/utils/vehicle_detail_safety.dart';
import 'package:ams/screens/vehicle_detail/widgets/vehicle_detail_content.dart';
import 'package:ams/screens/vehicle_detail/widgets/vehicle_realtime_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

const _detailInterval = Duration(seconds: 10);

class VehicleDetail extends ConsumerStatefulWidget {
  const VehicleDetail({super.key});

  @override
  ConsumerState<VehicleDetail> createState() => _VehicleDetailState();
}

class _VehicleDetailState extends ConsumerState<VehicleDetail> {
  final _api = const FetchMonitoringDetail();

  String _detailId = '';
  late Future<Map<String, dynamic>> _future;
  bool _initialized = false;

  LatLng? _coordinate;
  double _direction = 0;
  Map<String, dynamic> _detailData = {};

  Timer? _detailTimer;

  String _address = '-';
  bool _loadingAddress = false;
  double? _lastLat;
  double? _lastLng;

  @override
  void dispose() {
    _detailTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    final id = (args as String?)?.trim() ?? '';
    _detailId = id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(vehicleIdProvider.notifier).state = id.isEmpty ? null : id;
    });

    _future = _detailId.isNotEmpty
        ? _loadInitial()
        : Future.error('detailId kosong');

    _initialized = true;
  }

  Map<String, dynamic> _flattenDetail(Map<String, dynamic> data) =>
      flattenMonitoringDetail(data, detailId: _detailId);

  Future<Map<String, dynamic>> _loadInitial() async {
    final raw = await _api.getDetail(_detailId);
    final detail = _flattenDetail(raw);

    if (mounted) {
      final lat = _toDouble(detail['latitude']);
      final lng = _toDouble(detail['longitude']);
      setState(() {
        if (lat != null && lng != null) {
          _coordinate = LatLng(lat, lng);
          _direction = _toDouble(detail['direction']) ?? 0;
        }
        _detailData = detail;
      });

      if (lat != null && lng != null) {
        _onCoordinateReady(lat, lng);
      }
    }

    _startDetailPolling();
    return detail;
  }

  void _startDetailPolling() {
    _detailTimer?.cancel();
    if (_detailId.isEmpty) return;
    _detailTimer = Timer.periodic(_detailInterval, (_) => _fetchDetailData());
  }

  Future<void> _fetchDetailData() async {
    if (_detailId.isEmpty) return;
    try {
      final raw = await _api.getDetail(_detailId);
      if (!mounted) return;

      final detail = _flattenDetail(raw);
      final lat = _toDouble(detail['latitude']);
      final lng = _toDouble(detail['longitude']);

      setState(() {
        _detailData = detail;
        if (lat != null && lng != null) {
          _coordinate = LatLng(lat, lng);
          _direction = _toDouble(detail['direction']) ?? _direction;
        }
      });

      if (lat != null && lng != null) {
        _onCoordinateReady(lat, lng);
      }
    } catch (e) {
      debugPrint('FETCH DETAIL VEHICLE ERROR: $e');
    }
  }

  void _retry() {
    setState(() {
      _address = '-';
      _loadingAddress = false;
      _lastLat = null;
      _lastLng = null;
      _coordinate = null;
      _detailData = {};
      _future = _loadInitial();
    });
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  bool _shouldFetch(double lat, double lng) {
    if (_lastLat == null || _lastLng == null) return true;
    final dLat = (lat - _lastLat!).abs();
    final dLng = (lng - _lastLng!).abs();
    return dLat > 0.0001 || dLng > 0.0001;
  }

  void _onCoordinateReady(double lat, double lng) {
    if (_loadingAddress) return;
    if (!_shouldFetch(lat, lng)) return;
    _fetchAddress(lat, lng);
  }

  Future<void> _fetchAddress(double lat, double lng) async {
    setState(() => _loadingAddress = true);
    final addr = await getAddress(lat, lng);
    if (!mounted) return;
    setState(() {
      _address = addr;
      _loadingAddress = false;
      _lastLat = lat;
      _lastLng = lng;
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final translate = AppLocalizations.of(context);

    final speed = _toDouble(_detailData['speed']) ?? 0.0;
    final activity = _detailData['vehicle_activity']?.toString();
    final deviceTime = _detailData['device_time']?.toString() ?? '';
    final ignition = int.tryParse('${_detailData['ignition']}') ?? 0;

    final livecam = _detailData['livecam'];
    final hasDashcam = livecam is Map;
    final isChiller = safeBoolFrom(_detailData, 'chiller');

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: h * 0.45,
              width: double.infinity,
              child: VehicleRealtimeMap(
                coordinate: _coordinate,
                direction: _direction,
                speed: speed,
                vehicleActivity: activity,
                deviceTime: deviceTime,
                vehicleIgnition: ignition,
                initialZoom: 15,
                followMarker: true,
              ),
            ),
          ),

          const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topLeft,
                child: BackButtonCircle(),
              ),
            ),
          ),

          FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: FullScreenLoading());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          translate.vehicleDataCantLoaded,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          translate.pleaseTryAgain,
                          style: AppStyles.textSm,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _detailId.isEmpty ? null : _retry,
                          child: Text(translate.tryAgain),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final detailNull = snapshot.data!;
              final contentData = _detailData.isNotEmpty
                  ? _detailData
                  : detailNull;

              return VehicleDetailContent(
                detailData: contentData,
                address: _address,
                loadingAddress: _loadingAddress,
                hasDashcam: hasDashcam,
                dashcamOnline: hasDashcam,
                isChiller: isChiller,
                loadingDashcam: false,
                vehicleData: hasDashcam ? {'dashcam': livecam} : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
