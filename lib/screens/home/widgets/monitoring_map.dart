// ignore_for_file: unused_field, deprecated_member_use

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:bitrack_mobile_flutter/base/res/media.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/base/routes/app_routes.dart';
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
  GoogleMapController? _controller;

  static const LatLng _indonesiaCenter = LatLng(-2.5, 115.0);

  final Map<String, BitmapDescriptor> _iconCache = {};
  Set<Marker> _markers = {};

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

  Future<void> _rebuildMarkersIfNeeded() async {
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

    final markers = <Marker>{};

    for (final v in vehicles) {
      final asset = _resolveTruckAsset(v, now);
      final icon = await _getOrCreateVehicleIcon(
        asset: asset,
        showPlate: widget.showPlate,
        plateText: v.licensePlate,
      );

      markers.add(
        Marker(
          markerId: MarkerId('vehicle_${v.id}'),
          position: LatLng(v.latitude, v.longitude),
          icon: icon,
          rotation: v.bearing,
          anchor: const Offset(0.5, 0.5),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.vehicleDetailScreen,
              arguments: v.id,
            );
          },
        ),
      );
    }

    if (!mounted) return;
    setState(() => _markers = markers);
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

  Future<BitmapDescriptor> _getOrCreateVehicleIcon({
    required String asset,
    required bool showPlate,
    required String plateText,
  }) async {
    final key = '$asset|$showPlate|$plateText';
    final cached = _iconCache[key];
    if (cached != null) return cached;

    final bytes = await _buildVehicleMarkerBytes(
      asset: asset,
      showPlate: showPlate,
      plateText: plateText,
    );

    final icon = BitmapDescriptor.fromBytes(bytes);
    _iconCache[key] = icon;
    return icon;
  }

  Future<Uint8List> _buildVehicleMarkerBytes({
    required String asset,
    required bool showPlate,
    required String plateText,
  }) async {
    final double truckSize = 90;
    final double padding = 14;
    final double bubbleHeight = showPlate ? 34 : 0;
    final double bubbleWidth = showPlate ? 160 : 0;

    final double width = math.max(truckSize, bubbleWidth) + padding * 2;
    final double height = truckSize + bubbleHeight + padding * 2;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final centerX = width / 2;

    if (showPlate) {
      final bubbleTop = padding;
      final bubbleRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (width - bubbleWidth) / 2,
          bubbleTop,
          bubbleWidth,
          bubbleHeight,
        ),
        const Radius.circular(10),
      );

      final bubblePaint = Paint()
        ..color = AppStyles.blackColor.withOpacity(0.55);

      canvas.drawRRect(bubbleRect, bubblePaint);

      final tp = TextPainter(
        text: TextSpan(
          text: plateText,
          style: TextStyle(
            color: AppStyles.whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: bubbleWidth - 16);

      tp.paint(
        canvas,
        Offset(
          (width - tp.width) / 2,
          bubbleTop + (bubbleHeight - tp.height) / 2,
        ),
      );
    }

    final truckTop = padding + (showPlate ? (bubbleHeight + 6) : 0);

    final byteData = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      byteData.buffer.asUint8List(),
      targetWidth: truckSize.toInt(),
      targetHeight: truckSize.toInt(),
    );
    final frame = await codec.getNextFrame();
    final img = frame.image;

    final dst = Rect.fromLTWH(
      centerX - truckSize / 2,
      truckTop,
      truckSize,
      truckSize,
    );

    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      dst,
      Paint(),
    );

    final picture = recorder.endRecording();
    final uiImage = await picture.toImage(width.toInt(), height.toInt());
    final pngBytes = await uiImage.toByteData(format: ui.ImageByteFormat.png);

    return pngBytes!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: _indonesiaCenter,
        zoom: 5,
      ),
      onMapCreated: (c) => _controller = c,
      markers: _markers,
      rotateGesturesEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      minMaxZoomPreference: const MinMaxZoomPreference(3, 18),
    );
  }
}
