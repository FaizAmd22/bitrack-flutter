// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:ams/base/res/media.dart';

class VehicleRealtimeMap extends StatefulWidget {
  const VehicleRealtimeMap({
    super.key,
    required this.coordinate,
    required this.direction,
    required this.speed,
    required this.vehicleActivity,
    required this.deviceTime,
    required this.vehicleIgnition,
    this.initialZoom = 15,
    this.followMarker = true,
  });

  final LatLng? coordinate;
  final double direction;
  final double speed;
  final String? vehicleActivity;
  final String deviceTime;
  final int vehicleIgnition;
  final double initialZoom;
  final bool followMarker;

  @override
  State<VehicleRealtimeMap> createState() => _VehicleRealtimeMapState();
}

class _VehicleRealtimeMapState extends State<VehicleRealtimeMap>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();

  LatLng? _renderPos;
  LatLng? _fromPos;
  LatLng? _toPos;

  // Rotasi marker yang dirender (di-interpolasi halus).
  double _currentRot = 0;
  double _fromRot = 0;
  double _toRot = 0;

  late final AnimationController _animCtrl;
  late final Animation<double> _t;

  double _zoom = 15;
  bool _mapReady = false;

  static const InteractionOptions _interaction = InteractionOptions(
    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
  );

  @override
  void initState() {
    super.initState();
    _zoom = widget.initialZoom;

    // Seed posisi & rotasi awal — fix marker tidak tampil saat coordinate
    // sudah valid di build pertama (didUpdateWidget belum terpanggil).
    _renderPos = widget.coordinate;
    _currentRot = widget.direction;
    _fromRot = widget.direction;
    _toRot = widget.direction;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _t = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut)
      ..addListener(() {
        if (_fromPos == null || _toPos == null) return;
        final v = _t.value;
        final lat =
            _fromPos!.latitude + (_toPos!.latitude - _fromPos!.latitude) * v;
        final lng =
            _fromPos!.longitude + (_toPos!.longitude - _fromPos!.longitude) * v;
        final rot = _lerpAngle(_fromRot, _toRot, v);

        setState(() {
          _renderPos = LatLng(lat, lng);
          _currentRot = rot;
        });

        if (widget.followMarker) _safeMove(LatLng(lat, lng));
      });
  }

  @override
  void didUpdateWidget(covariant VehicleRealtimeMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newPos = widget.coordinate;
    if (newPos == null) return;

    // Posisi valid pertama kali.
    if (_renderPos == null) {
      setState(() {
        _renderPos = newPos;
        _currentRot = widget.direction;
        _fromRot = widget.direction;
        _toRot = widget.direction;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _safeMove(newPos);
      });
      return;
    }

    final changed =
        oldWidget.coordinate == null ||
        oldWidget.coordinate!.latitude != newPos.latitude ||
        oldWidget.coordinate!.longitude != newPos.longitude;

    if (changed) {
      _fromPos = _renderPos;
      _toPos = newPos;

      // Rotasi target: arah gerak (bearing) bila benar-benar berpindah,
      // selain itu pakai direction dari API. Hindari spin saat diam.
      final movedFar =
          _fromPos != null &&
          ((_fromPos!.latitude - newPos.latitude).abs() > 1e-6 ||
              (_fromPos!.longitude - newPos.longitude).abs() > 1e-6);

      _fromRot = _currentRot;
      _toRot = movedFar ? _computeBearing(_fromPos!, newPos) : widget.direction;

      _animCtrl.stop();
      _animCtrl.reset();
      _animCtrl.forward();
    } else if (widget.direction != oldWidget.direction) {
      // Posisi sama, heading berubah (mis. berputar di tempat).
      _fromPos = _renderPos;
      _toPos = _renderPos;
      _fromRot = _currentRot;
      _toRot = widget.direction;
      _animCtrl.stop();
      _animCtrl.reset();
      _animCtrl.forward();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _safeMove(LatLng pos) {
    if (!_mapReady) return;
    try {
      _mapController.move(pos, _zoom);
    } catch (_) {}
  }

  // Bearing 0–360° (sama dengan computeBearing Cordova).
  double _computeBearing(LatLng from, LatLng to) {
    double toRad(double d) => d * math.pi / 180.0;
    double toDeg(double r) => r * 180.0 / math.pi;
    final dLng = toRad(to.longitude - from.longitude);
    final lat1 = toRad(from.latitude);
    final lat2 = toRad(to.latitude);
    final y = math.sin(dLng) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
    return (toDeg(math.atan2(y, x)) + 360) % 360;
  }

  // Interpolasi sudut jalur terpendek (handle 350°→10°).
  double _lerpAngle(double from, double to, double t) {
    final diff = ((to - from + 540) % 360) - 180;
    return (from + diff * t + 360) % 360;
  }

  String _registeredEvent() {
    final base = (widget.vehicleActivity ?? '').toUpperCase();

    DateTime? device;
    try {
      device = DateTime.parse(widget.deviceTime);
    } catch (_) {
      device = null;
    }

    if (device != null && widget.vehicleIgnition == 0) {
      final now = DateTime.now();
      final diffHours = now.difference(device).inMinutes / 60.0;
      if (diffHours >= 4) return 'SILENCE';
    }

    if (base.isEmpty) return 'STOP';
    return base;
  }

  String _truckAsset() {
    final ev = _registeredEvent();
    if (ev == 'IDLE') return AppMedia.truckIdle;
    if (ev == 'MOVING') return AppMedia.truckMoving;
    if (ev == 'STOP') return AppMedia.truckStop;
    return AppMedia.truckSilence;
  }

  @override
  Widget build(BuildContext context) {
    final pos = _renderPos;
    const indonesiaCenter = LatLng(-2.5, 115.0);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: pos ?? indonesiaCenter,
        initialZoom: pos != null ? widget.initialZoom : 5,
        minZoom: 3,
        maxZoom: 18,
        interactionOptions: _interaction,
        onMapReady: () {
          _mapReady = true;
          if (_renderPos != null) _safeMove(_renderPos!);
        },
        onPositionChanged: (p, hasGesture) {
          if (p.zoom != null) _zoom = p.zoom!;
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.treffix.fixtrack',
        ),
        if (pos != null)
          MarkerLayer(
            markers: [
              Marker(
                point: pos,
                width: 120,
                height: 120,
                alignment: Alignment.center,
                child: _TruckMarkerWithTooltip(
                  asset: _truckAsset(),
                  directionDeg: _currentRot,
                  speed: widget.speed,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _TruckMarkerWithTooltip extends StatelessWidget {
  const _TruckMarkerWithTooltip({
    required this.asset,
    required this.directionDeg,
    required this.speed,
  });

  final String asset;
  final double directionDeg;
  final double speed;

  @override
  Widget build(BuildContext context) {
    final radians = directionDeg * math.pi / 180.0;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(top: -15, child: _SpeedTooltip(speed: speed)),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppStyles.primaryColor.withOpacity(0.15),
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppStyles.primaryColor.withOpacity(0.25),
              ),
            ),
          ],
        ),
        Transform.rotate(
          angle: radians,
          child: Image.asset(asset, width: 55, height: 55, fit: BoxFit.contain),
        ),
      ],
    );
  }
}

class _SpeedTooltip extends StatelessWidget {
  const _SpeedTooltip({required this.speed});

  final double speed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppStyles.blackColor.withOpacity(0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${speed.toStringAsFixed(0)} KM/H',
        style: AppStyles.textSm.copyWith(color: AppStyles.whiteColor),
      ),
    );
  }
}
