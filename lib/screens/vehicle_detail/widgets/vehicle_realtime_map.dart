// ignore_for_file: deprecated_member_use

import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:bitrack_mobile_flutter/base/res/media.dart';

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

  late final AnimationController _animCtrl;
  late Animation<double> _t;

  double _zoom = 15;

  static const InteractionOptions _interaction = InteractionOptions(
    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
  );

  @override
  void initState() {
    super.initState();
    _zoom = widget.initialZoom;

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _t = CurvedAnimation(parent: _animCtrl, curve: Curves.linear)
      ..addListener(() {
        if (_fromPos == null || _toPos == null) return;
        final v = _t.value;

        setState(() {
          _renderPos = LatLng(
            _fromPos!.latitude + (_toPos!.latitude - _fromPos!.latitude) * v,
            _fromPos!.longitude + (_toPos!.longitude - _fromPos!.longitude) * v,
          );
        });

        if (widget.followMarker && _renderPos != null) {
          _mapController.move(_renderPos!, _zoom);
        }
      });
  }

  @override
  void didUpdateWidget(covariant VehicleRealtimeMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newPos = widget.coordinate;
    if (newPos == null) return;

    if (_renderPos == null) {
      _renderPos = newPos;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mapController.move(newPos, _zoom);
      });
      setState(() {});
      return;
    }

    final changed =
        oldWidget.coordinate == null ||
        oldWidget.coordinate!.latitude != newPos.latitude ||
        oldWidget.coordinate!.longitude != newPos.longitude;

    if (changed) {
      _fromPos = _renderPos;
      _toPos = newPos;

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
        onPositionChanged: (p, hasGesture) {
          if (p.zoom != null) _zoom = p.zoom!;
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.treffix.bitrack',
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
                  directionDeg: widget.direction,
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
    final radians = directionDeg * 3.141592653589793 / 180.0;

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
