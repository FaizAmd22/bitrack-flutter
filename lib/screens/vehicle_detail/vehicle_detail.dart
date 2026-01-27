// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/base/widgets/back_button_circle.dart';
import 'package:bitrack_mobile_flutter/base/widgets/full_screen_loading.dart';
import 'package:bitrack_mobile_flutter/l10n/app_localizations.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/providers/vehicle_information_provider.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/services/fetch_address.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/services/fetch_vehicle.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/services/fetch_vehicle_detail_null.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/widgets/vehicle_detail_content.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/widgets/vehicle_realtime_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/utils/dashcam_parser.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/services/mettaxiot_stream_service.dart';

class VehicleDetail extends ConsumerStatefulWidget {
  const VehicleDetail({super.key});

  @override
  ConsumerState<VehicleDetail> createState() => _VehicleDetailState();
}

class _VehicleDetailState extends ConsumerState<VehicleDetail> {
  final _api = const FetchVehicleDetailNull();

  String _detailId = '';
  late Future<Map<String, dynamic>> _future;
  bool _initialized = false;

  String _address = '-';
  bool _loadingAddress = false;

  double? _lastLat;
  double? _lastLng;
  Timer? _addrDebounce;

  bool _loadingDashcam = false;
  bool _dashcamOnline = false;
  bool _hasDashcam = false;
  bool _isChiller = false;
  bool _dashcamLoaded = false;

  @override
  void dispose() {
    _addrDebounce?.cancel();
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
        ? _api.getVehicleByVehicleId(_detailId)
        : Future.error('detailId kosong');

    _initialized = true;
  }

  void _retry() {
    setState(() {
      _future = _api.getVehicleByVehicleId(_detailId);
      _address = '-';
      _loadingAddress = false;
      _lastLat = null;
      _lastLng = null;
      _dashcamLoaded = false;
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
    return dLat > 0.0003 || dLng > 0.0003;
  }

  void _onCoordinateReady(double lat, double lng) {
    if (_loadingAddress) return;
    if (!_shouldFetch(lat, lng)) return;

    _fetchAddress(lat, lng);
  }

  Future<void> _fetchAddress(double lat, double lng) async {
    debugPrint('FETCH ADDRESS CALLED: $lat, $lng');

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
        });
        return;
      }

      bool online = false;

      if (info.type.toUpperCase().trim() == 'METTAX') {
        // Cek channel pertama saja untuk status
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
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasDashcam = true;
        _dashcamOnline = false;
        _loadingDashcam = false;
        _dashcamLoaded = true;
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

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: h * 0.45,
              width: double.infinity,
              child: FutureBuilder<Map<String, dynamic>>(
                future: _future,
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  final lat = data == null ? null : _toDouble(data['latitude']);
                  final lng = data == null
                      ? null
                      : _toDouble(data['longitude']);

                  final coordinate = (lat != null && lng != null)
                      ? LatLng(lat, lng)
                      : null;

                  final direction = (data == null)
                      ? 0.0
                      : (_toDouble(data['direction']) ?? 0.0);
                  final speed = (data == null)
                      ? 0.0
                      : (_toDouble(data['speed']) ?? 0.0);
                  final activity = (data == null)
                      ? null
                      : (data['vehicle_activity']?.toString());
                  final deviceTime = (data == null)
                      ? ''
                      : (data['device_time']?.toString() ?? '');
                  final ignition = (data == null)
                      ? 0
                      : int.tryParse('${data['ignition']}') ?? 0;

                  return VehicleRealtimeMap(
                    coordinate: coordinate,
                    direction: direction,
                    speed: speed,
                    vehicleActivity: activity,
                    deviceTime: deviceTime,
                    vehicleIgnition: ignition,
                    initialZoom: 15,
                    followMarker: true,
                  );
                },
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

              final lat = _toDouble(detailNull['latitude']);
              final lng = _toDouble(detailNull['longitude']);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                if (lat != null && lng != null) {
                  _onCoordinateReady(lat, lng);
                }
              });

              if (!_dashcamLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_dashcamLoaded && !_loadingDashcam) {
                    _loadDashcamStatus(detailNull);
                  }
                });
              }

              return VehicleDetailContent(
                detailData: detailNull,
                address: _address,
                loadingAddress: _loadingAddress,
                hasDashcam: _hasDashcam,
                dashcamOnline: _dashcamOnline,
                isChiller: _isChiller,
                loadingDashcam: _loadingDashcam,
              );
            },
          ),
        ],
      ),
    );
  }
}
