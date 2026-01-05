// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:bitrack_mobile_flutter/base/widgets/back_button_circle.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/services/dashcam_service.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/services/fetch_address.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/services/fetch_vehicle_detail_null.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/widgets/vehicle_detail_content.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/widgets/vehicle_detail_map.dart';
import 'package:flutter/material.dart';

class VehicleDetail extends StatefulWidget {
  const VehicleDetail({super.key});

  @override
  State<VehicleDetail> createState() => _VehicleDetailState();
}

class _VehicleDetailState extends State<VehicleDetail> {
  final _api = const FetchVehicleDetailNull();

  String _vehicleId = '';
  late Future<Map<String, dynamic>> _future;

  bool _initialized = false;

  String _address = '-';
  bool _loadingAddress = false;

  double? _lastLat;
  double? _lastLng;
  Timer? _addrDebounce;

  final _dashcamService = DashcamService();

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

    _vehicleId = id;
    _future = _vehicleId.isNotEmpty
        ? _api.getVehicleByVehicleId(_vehicleId)
        : Future.error('vehicleId kosong');

    _initialized = true;
  }

  void _retry() {
    setState(() {
      _future = _api.getVehicleByVehicleId(_vehicleId);
      _address = '-';
      _loadingAddress = false;
      _lastLat = null;
      _lastLng = null;
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
    // threshold sederhana agar tidak spam (bisa adjust)
    return dLat > 0.0003 || dLng > 0.0003;
  }

  void _scheduleFetchAddress(double lat, double lng, {bool immediate = false}) {
    if (!_shouldFetch(lat, lng)) return;

    _addrDebounce?.cancel();
    _addrDebounce = Timer(
      immediate ? Duration.zero : const Duration(milliseconds: 500),
      () => _fetchAddress(lat, lng),
    );
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

  Future<void> _loadDashcamStatus(Map<String, dynamic> detail) async {
    final vehicleId = (detail['vehicle_id'] ?? '').toString().trim();
    if (vehicleId.isEmpty) return;

    setState(() => _loadingDashcam = true);
    final r = await _dashcamService.checkDashcamStream(vehicleId: vehicleId);

    if (!mounted) return;
    setState(() {
      _hasDashcam = r.hasDashcam;
      _dashcamOnline = r.isStreamAvailable;
      _isChiller = r.isChiller;
      _loadingDashcam = false;
      _dashcamLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: h * 0.45,
              width: double.infinity,
              child: const RepaintBoundary(child: VehicleDetailMap()),
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
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;

              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _vehicleId.isEmpty ? null : _retry,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final data = snapshot.data!;

              final lat = _toDouble(data['latitude']);
              final lng = _toDouble(data['longitude']);

              if (lat != null && lng != null && !_loadingAddress) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _scheduleFetchAddress(lat, lng, immediate: true);
                });
              }

              if (!_dashcamLoaded) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_dashcamLoaded && !_loadingDashcam) {
                    _loadDashcamStatus(data);
                  }
                });
              }

              return VehicleDetailContent(
                detailData: data,
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
