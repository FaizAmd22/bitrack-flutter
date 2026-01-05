// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:bitrack_mobile_flutter/base/res/media.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/base/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:bitrack_mobile_flutter/screens/home/models/vehicle.dart';

class MonitoringMap extends StatefulWidget {
  final List<Vehicle> vehicles;
  final bool showPlate;

  const MonitoringMap({
    super.key,
    required this.vehicles,
    required this.showPlate,
  });

  @override
  State<MonitoringMap> createState() => _MonitoringMapState();
}

class _MonitoringMapState extends State<MonitoringMap> {
  late final MapController _mapController = MapController();

  static const LatLng _indonesiaCenter = LatLng(-2.5, 115.0);
  static const InteractionOptions _interaction = InteractionOptions(
    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
  );

  List<Marker> _cachedMarkers = const [];
  int _cacheKey = 0;

  @override
  void didUpdateWidget(covariant MonitoringMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rebuildMarkersIfNeeded();
  }

  @override
  void initState() {
    super.initState();
    _rebuildMarkersIfNeeded();
  }

  void _rebuildMarkersIfNeeded() {
    final vehicles = widget.vehicles;
    final key = Object.hash(
      widget.showPlate,
      vehicles.length,
      Object.hashAll(
        vehicles.map(
          (v) => Object.hash(
            v.id,
            v.latitude,
            v.longitude,
            v.bearing,
            v.activity,
            v.deviceTime,
            v.ignition,
            v.licensePlate,
          ),
        ),
      ),
    );

    if (key == _cacheKey) return;
    _cacheKey = key;

    final now = DateTime.now();

    _cachedMarkers = vehicles
        .map((v) {
          final asset = _resolveTruckAsset(v, now);
          final angleRad = v.bearing * math.pi / 180;

          return Marker(
            point: LatLng(v.latitude, v.longitude),
            width: 110,
            height: widget.showPlate ? 85 : 65,
            rotate: false,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.vehicleDetailScreen,
                  arguments: v.id,
                );
              },
              child: Transform.translate(
                offset: widget.showPlate ? const Offset(0, -17) : Offset.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showPlate) _PlateBubble(text: v.licensePlate),
                    const SizedBox(height: 2),
                    Transform.rotate(
                      angle: angleRad,
                      child: Image.asset(asset, width: 45, height: 45),
                    ),
                  ],
                ),
              ),
            ),
          );
        })
        .toList(growable: false);
  }

  String _resolveTruckAsset(Vehicle v, DateTime now) {
    final isSilence = _isSilence(v, now);

    if (isSilence) return AppMedia.truckSilence;

    switch (v.activity) {
      case 'IDLE':
        return AppMedia.truckIdle;
      case 'MOVING':
        return AppMedia.truckMoving;
      case 'STOP':
        return AppMedia.truckStop;
      default:
        return AppMedia.truckSilence;
    }
  }

  bool _isSilence(Vehicle v, DateTime now) {
    if (v.ignition != 0) return false;
    final dt = v.deviceTime;
    if (dt.isEmpty) return false;

    final parsed = DateTime.tryParse(dt.replaceFirst(' ', 'T'));
    if (parsed == null) return false;

    final diffHours = now.difference(parsed).inMinutes / 60;
    return diffHours >= 4;
  }

  @override
  Widget build(BuildContext context) {
    _rebuildMarkersIfNeeded();

    return FlutterMap(
      mapController: _mapController,
      options: const MapOptions(
        initialCenter: _indonesiaCenter,
        initialZoom: 5,
        maxZoom: 18,
        minZoom: 3,
        interactionOptions: _interaction,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 100,
            size: const Size(40, 40),
            rotate: false,
            polygonOptions: const PolygonOptions(
              borderColor: Colors.transparent,
              color: Colors.transparent,
              borderStrokeWidth: 0,
            ),
            builder: (context, markers) {
              return Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppStyles.blueColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  markers.length.toString(),
                  style: AppStyles.textMd.copyWith(color: AppStyles.whiteColor),
                ),
              );
            },
            markers: _cachedMarkers,
          ),
        ),
      ],
    );
  }
}

class _PlateBubble extends StatelessWidget {
  final String text;
  const _PlateBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: AppStyles.blackColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppStyles.textXsBold.copyWith(color: AppStyles.whiteColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}
