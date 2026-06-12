// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/back_button_circle.dart';
import 'package:ams/base/widgets/full_screen_loading.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/vehicle_detail/providers/vehicle_information_provider.dart';
import 'package:ams/screens/vehicle_detail/services/fetch_address.dart';
import 'package:ams/screens/vehicle_detail/services/fetch_realtime_vehicle.dart';
import 'package:ams/screens/vehicle_detail/services/fetch_vehicle.dart';
import 'package:ams/screens/vehicle_detail/services/fetch_vehicle_detail_null.dart';
import 'package:ams/screens/vehicle_detail/widgets/vehicle_detail_content.dart';
import 'package:ams/screens/vehicle_detail/widgets/vehicle_realtime_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:ams/screens/vehicle_detail/utils/dashcam_parser.dart';
import 'package:ams/screens/vehicle_detail/services/mettaxiot_stream_service.dart';

const _realtimeInterval = Duration(seconds: 3);
const _detailInterval = Duration(seconds: 10);

class VehicleDetail extends ConsumerStatefulWidget {
  const VehicleDetail({super.key});

  @override
  ConsumerState<VehicleDetail> createState() => _VehicleDetailState();
}

class _VehicleDetailState extends ConsumerState<VehicleDetail> {
  final _api = const FetchVehicleDetailNull();
  final _realtimeApi = const FetchRealtimeVehicle();

  String _detailId = '';
  late Future<Map<String, dynamic>> _future;
  bool _initialized = false;

  LatLng? _coordinate;
  double _direction = 0;
  Map<String, dynamic> _detailData = {};

  Timer? _realtimeTimer;
  Timer? _detailTimer;

  String _address = '-';
  bool _loadingAddress = false;
  double? _lastLat;
  double? _lastLng;

  bool _loadingDashcam = false;
  bool _dashcamOnline = false;
  bool _hasDashcam = false;
  bool _isChiller = false;
  bool _dashcamLoaded = false;

  // ── Tambahan: simpan vehicle map lengkap untuk DashcamBottomSheet ──────────
  Map<String, dynamic>? _vehicleData;

  @override
  void dispose() {
    _realtimeTimer?.cancel();
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

    _future = _detailId.isNotEmpty
        ? _loadInitial()
        : Future.error('detailId kosong');

    _initialized = true;
  }

  Future<Map<String, dynamic>> _loadInitial() async {
    final detail = await _api.getVehicleByVehicleId(_detailId);

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

    _startRealtimePolling();
    _startDetailPolling();
    return detail;
  }

  void _startRealtimePolling() {
    _realtimeTimer?.cancel();
    if (_detailId.isEmpty) return;
    _fetchRealtimeData();
    _realtimeTimer = Timer.periodic(
      _realtimeInterval,
      (_) => _fetchRealtimeData(),
    );
  }

  Future<void> _fetchRealtimeData() async {
    if (_detailId.isEmpty) return;
    try {
      final data = await _realtimeApi.getRealtimeVehicle(_detailId);
      if (!mounted) return;

      final lat = _toDouble(data['latitude']);
      final lng = _toDouble(data['longitude']);

      if (lat == null || lng == null) return;

      setState(() {
        _coordinate = LatLng(lat, lng);
        _direction = _toDouble(data['direction']) ?? _direction;
      });

      _onCoordinateReady(lat, lng);
    } catch (e) {
      debugPrint('FETCH REALTIME VEHICLE ERROR: $e');
    }
  }

  void _startDetailPolling() {
    _detailTimer?.cancel();
    if (_detailId.isEmpty) return;
    _detailTimer = Timer.periodic(_detailInterval, (_) => _fetchDetailData());
  }

  Future<void> _fetchDetailData() async {
    if (_detailId.isEmpty) return;
    try {
      final data = await _api.getVehicleByVehicleId(_detailId);
      if (!mounted) return;
      setState(() => _detailData = data);
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
      _dashcamLoaded = false;
      _coordinate = null;
      _detailData = {};
      _vehicleData = null; // reset vehicle data juga
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

  Future<void> _loadDashcamStatus(Map<String, dynamic> detailNull) async {
    final vehicleId = (detailNull['vehicle_id'] ?? '').toString().trim();
    if (vehicleId.isEmpty) return;

    setState(() => _loadingDashcam = true);

    try {
      final vehicle = await const FetchVehicle().getVehicle(vehicleId);
      final category = (vehicle['vehicle_category'] ?? '').toString().trim();
      final isChiller = category.toLowerCase() == 'chiller';
      final info = parseDashcamFromVehicle(vehicle);

      if (info == null) {
        if (!mounted) return;
        setState(() {
          _hasDashcam = false;
          _dashcamOnline = false;
          _isChiller = isChiller;
          _loadingDashcam = false;
          _dashcamLoaded = true;
          _vehicleData = vehicle; // simpan meski tidak ada dashcam
        });
        return;
      }

      bool online = false;
      if (info.type.toUpperCase().trim() == 'METTAX') {
        final mettax = MettaxiotStreamService.I;
        final stream = await mettax.getLiveStreamUrl(
          deviceId: info.deviceId,
          channelId: info.channels.first,
        );
        online = stream.trim().isNotEmpty;
      } else {
        online = info.deviceId.trim().isNotEmpty && info.channels.isNotEmpty;
      }

      if (!mounted) return;
      setState(() {
        _hasDashcam = true;
        _dashcamOnline = online;
        _isChiller = isChiller;
        _loadingDashcam = false;
        _dashcamLoaded = true;
        _vehicleData = vehicle; // ← simpan vehicle map lengkap
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasDashcam = true;
        _dashcamOnline = false;
        _loadingDashcam = false;
        _dashcamLoaded = true;
        // _vehicleData tetap null jika fetch gagal
      });
    }
  }

  void _storeVehicleIdToProvider(String vehicleId) {
    final current = ref.read(vehicleIdProvider);
    if (vehicleId.isNotEmpty && current != vehicleId) {
      ref.read(vehicleIdProvider.notifier).state = vehicleId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    final translate = AppLocalizations.of(context);

    final speed = _toDouble(_detailData['speed']) ?? 0.0;
    final activity = _detailData['vehicle_activity']?.toString();
    final deviceTime = _detailData['device_time']?.toString() ?? '';
    final ignition = int.tryParse('${_detailData['ignition']}') ?? 0;

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
              final vehicleId = (detailNull['vehicle_id'] ?? '')
                  .toString()
                  .trim();

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _storeVehicleIdToProvider(vehicleId);
              });

              if (!_dashcamLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_dashcamLoaded && !_loadingDashcam) {
                    _loadDashcamStatus(detailNull);
                  }
                });
              }

              final contentData = _detailData.isNotEmpty
                  ? _detailData
                  : detailNull;

              return VehicleDetailContent(
                detailData: contentData,
                address: _address,
                loadingAddress: _loadingAddress,
                hasDashcam: _hasDashcam,
                dashcamOnline: _dashcamOnline,
                isChiller: _isChiller,
                loadingDashcam: _loadingDashcam,
                vehicleData: _vehicleData, // ← pass ke content
              );
            },
          ),
        ],
      ),
    );
  }
}
