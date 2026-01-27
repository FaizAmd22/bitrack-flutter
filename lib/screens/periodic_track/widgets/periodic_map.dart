// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;

import 'package:bitrack_mobile_flutter/base/res/media.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/screens/periodic_track/services/periodic_playback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

import '../models/periodic_metric.dart';
import '../models/periodic_point.dart';
import '../utils/periodic_value.dart';
import 'periodic_truck_marker.dart';

class PeriodicMap extends StatefulWidget {
  final MapController mapController;
  final List<PeriodicPoint> points;
  final int currentIndex;
  final PeriodicMetric metric;
  final bool autoCenter;
  final ValueChanged<int> onPointSelected;
  final bool isPlaying;
  final int speedIndex;
  final bool isSatellite;
  final ValueChanged<int>? onPlaybackIndexChanged;

  const PeriodicMap({
    super.key,
    required this.mapController,
    required this.points,
    required this.currentIndex,
    required this.metric,
    required this.autoCenter,
    required this.onPointSelected,
    required this.isPlaying,
    required this.speedIndex,
    required this.isSatellite,
    this.onPlaybackIndexChanged,
  });

  @override
  State<PeriodicMap> createState() => _PeriodicMapState();
}

class _PeriodicMapState extends State<PeriodicMap>
    with TickerProviderStateMixin {
  late final PeriodicPlaybackController _playback;

  LatLng? _truckPos;
  int _playbackIndex = 0;

  final List<int> _speeds = const [200, 500, 1000, 1500, 2000];

  bool _userIsInteracting = false;
  Timer? _resumeAutoCenterTimer;

  @override
  void initState() {
    super.initState();

    _playback = PeriodicPlaybackController(
      vsync: this,
      onTick: (pos, segIndex, frac) {
        setState(() {
          _truckPos = pos;
          _playbackIndex = segIndex.clamp(
            0,
            math.max(0, widget.points.length - 1),
          );
        });

        if (widget.isPlaying) {
          widget.onPlaybackIndexChanged?.call(_playbackIndex);
        }

        if (widget.autoCenter && !_userIsInteracting) {
          final zoom = widget.mapController.camera.zoom;
          widget.mapController.move(pos, zoom);
        }
      },
    );

    _setupPlaybackData(resetPos: true);

    _playbackIndex = widget.currentIndex.clamp(
      0,
      math.max(0, widget.points.length - 1),
    );

    if (widget.isPlaying) {
      _playback.play(startIndex: _playbackIndex);
    }
  }

  void _updatePlaybackSpeedOnly() {
    if (widget.points.length < 2) return;

    final pts =
        widget.points.map((e) => LatLng(e.latitude, e.longitude)).toList();

    final si = widget.speedIndex.clamp(0, _speeds.length - 1);
    final segDur = List<int>.filled(math.max(0, pts.length - 1), _speeds[si]);

    _playback.setData(points: pts, segmentDurationsMs: segDur);
  }

  @override
  void didUpdateWidget(covariant PeriodicMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    final pointsChanged = oldWidget.points != widget.points;
    final speedChanged = oldWidget.speedIndex != widget.speedIndex;
    final playingChanged = oldWidget.isPlaying != widget.isPlaying;
    final metricChanged = oldWidget.metric != widget.metric;
    final indexChanged = oldWidget.currentIndex != widget.currentIndex;

    if (pointsChanged) {
      _setupPlaybackData(resetPos: true);
    }

    if (!pointsChanged && speedChanged) {
      _updatePlaybackSpeedOnly();

      if (widget.isPlaying) {
        _playback.play(startIndex: _playbackIndex);
      }
    }

    if (indexChanged && widget.points.isNotEmpty) {
      final idx = widget.currentIndex.clamp(0, widget.points.length - 1);
      _playbackIndex = idx;

      final p = widget.points[idx];
      final target = LatLng(p.latitude, p.longitude);

      if (widget.isPlaying) {
        _playback.play(startIndex: _playbackIndex);
      } else {
        setState(() => _truckPos = target);
      }

      if (widget.autoCenter && !_userIsInteracting) {
        widget.mapController.move(target, widget.mapController.camera.zoom);
      }
    }

    if (metricChanged) {
      setState(() {});
    }

    if (playingChanged) {
      if (widget.isPlaying) {
        _playback.play(startIndex: _playbackIndex);
      } else {
        _playback.pause();
      }
    }
  }

  @override
  void dispose() {
    _resumeAutoCenterTimer?.cancel();
    _playback.dispose();
    super.dispose();
  }

  List<Marker> _buildStartEndMarkers() {
    if (widget.points.isEmpty) return [];

    final lastIndex = widget.points.length - 1;

    Marker buildCircle(int index) {
      final p = widget.points[index];
      return Marker(
        point: LatLng(p.latitude, p.longitude),
        width: 18,
        height: 18,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () => widget.onPointSelected(index),
          child: Container(
            decoration: BoxDecoration(
              color: AppStyles.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppStyles.whiteColor, width: 2),
            ),
          ),
        ),
      );
    }

    if (lastIndex == 0) return [buildCircle(0)];
    return [buildCircle(0), buildCircle(lastIndex)];
  }

  void _setupPlaybackData({required bool resetPos}) {
    if (widget.points.length < 2) return;

    final pts =
        widget.points.map((e) => LatLng(e.latitude, e.longitude)).toList();

    final si = widget.speedIndex.clamp(0, _speeds.length - 1);
    final segDur = List<int>.filled(math.max(0, pts.length - 1), _speeds[si]);

    _playback.setData(points: pts, segmentDurationsMs: segDur);

    final safeIndex = widget.currentIndex.clamp(0, pts.length - 1);
    _playbackIndex = safeIndex;

    if (resetPos) {
      setState(() => _truckPos = pts[safeIndex]);
    }
  }

  double _bearingLatLng(LatLng a, LatLng b) {
    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;
    final dLon = (b.longitude - a.longitude) * math.pi / 180;

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final brng = math.atan2(y, x) * 180 / math.pi;
    return (brng + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();

    final safeSelectedIndex = widget.currentIndex.clamp(
      0,
      widget.points.length - 1,
    );

    final fallbackPoint = widget.points[safeSelectedIndex];
    final truckPoint =
        _truckPos ?? LatLng(fallbackPoint.latitude, fallbackPoint.longitude);

    final coords =
        widget.points.map((p) => LatLng(p.latitude, p.longitude)).toList();

    final idxForInfo = widget.isPlaying
        ? _playbackIndex.clamp(0, widget.points.length - 1)
        : safeSelectedIndex;

    final curr = widget.points[idxForInfo];
    final nextPoint = idxForInfo < widget.points.length - 1
        ? widget.points[idxForInfo + 1]
        : curr;

    final LatLng targetLatLng = LatLng(nextPoint.latitude, nextPoint.longitude);
    final LatLng currentLatLng = truckPoint;

    final bearing = _bearingLatLng(currentLatLng, targetLatLng);
    final tooltip = getDisplayValue(curr, widget.metric);

    final initialCenter = LatLng(
      widget.points[safeSelectedIndex].latitude,
      widget.points[safeSelectedIndex].longitude,
    );

    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 16,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        initialRotation: 0,
        onPositionChanged: (pos, hasGesture) {
          if (!hasGesture) return;

          _userIsInteracting = true;
          _resumeAutoCenterTimer?.cancel();
          _resumeAutoCenterTimer = Timer(
            const Duration(milliseconds: 900),
            () {
              if (!mounted) return;
              setState(() => _userIsInteracting = false);
            },
          );
        },
      ),
      children: [
        TileLayer(
          urlTemplate: widget.isSatellite
              ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
              : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.bitrack.mobile',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: coords,
              strokeWidth: 4,
              color: AppStyles.primaryColor.withOpacity(0.85),
            ),
          ],
        ),
        MarkerLayer(
          markers: widget.points
              .asMap()
              .entries
              .where((e) => (e.value.eventType) != 'SAMPLING')
              .map((e) {
            final p = e.value;
            return Marker(
              point: LatLng(p.latitude, p.longitude),
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () => widget.onPointSelected(e.key),
                child: SvgPicture.asset(
                  AppMedia.alertIcon,
                  width: 36,
                  height: 36,
                ),
              ),
            );
          }).toList(),
        ),
        MarkerLayer(markers: _buildStartEndMarkers()),
        MarkerLayer(
          markers: [
            Marker(
              point: truckPoint,
              width: 90,
              height: 90,
              alignment: Alignment.center,
              child: PeriodicTruckMarker(
                tooltipText: tooltip,
                bearingDeg: bearing,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _bearingDeg(PeriodicPoint a, PeriodicPoint b) {
    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;
    final dLon = (b.longitude - a.longitude) * math.pi / 180;

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final brng = math.atan2(y, x) * 180 / math.pi;
    return (brng + 360) % 360;
  }
}
