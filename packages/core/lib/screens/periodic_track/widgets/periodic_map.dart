// ignore_for_file: deprecated_member_use

import 'package:bitrack_core/base/config/app_branding.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:bitrack_core/base/constants/map_urls.dart';
import 'package:bitrack_core/base/res/media.dart';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/screens/periodic_track/services/periodic_playback_controller.dart';
import 'package:bitrack_core/screens/periodic_track/widgets/periodic_alert_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';

import '../models/periodic_metric.dart';
import '../models/periodic_point.dart';
import '../utils/periodic_value.dart';
import 'periodic_truck_marker.dart';
import 'package:bitrack_core/screens/periodic_track/models/playback_speed.dart';

class PeriodicMap extends StatefulWidget {
  final MapController mapController;
  final List<PeriodicPoint> points;
  final int currentIndex;
  final PeriodicMetric metric;
  final bool autoCenter;
  final ValueChanged<int> onPointSelected;
  final bool isPlaying;
  final PlaybackSpeed speed;
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
    required this.speed,
    required this.isSatellite,
    this.onPlaybackIndexChanged,
  });

  @override
  State<PeriodicMap> createState() => _PeriodicMapState();
}

/// Posisi truk dan indeks titik yang sedang diputar.
class _TruckState {
  const _TruckState(this.pos, this.index);

  final LatLng pos;
  final int index;
}

class _PeriodicMapState extends State<PeriodicMap>
    with TickerProviderStateMixin {
  late final PeriodicPlaybackController _playback;

  /// Diperbarui di SETIAP frame animasi pemutaran, dan hanya lapisan truk yang
  /// mendengarkannya.
  ///
  /// Dulu setiap frame memanggil setState pada seluruh peta, dan tiap build
  /// menyusun ulang daftar marker semua titik, koordinat garis, dan himpunan
  /// alert — O(n) alokasi 60x per detik padahal yang bergerak hanya truk.
  final ValueNotifier<_TruckState?> _truck = ValueNotifier(null);
  int _playbackIndex = 0;

  bool _userIsInteracting = false;
  Timer? _resumeAutoCenterTimer;

  // Disusun ulang hanya saat `points` (atau jenis peta) berubah, lalu dipakai
  // ulang apa adanya. Instance widget yang sama membuat Flutter melewati
  // subtree-nya saat peta di-build ulang.
  List<LatLng> _coords = const [];
  Set<int> _alertIdx = const {};
  Widget _tileLayer = const SizedBox.shrink();
  Widget _polylineLayer = const SizedBox.shrink();
  Widget _dotsLayer = const SizedBox.shrink();
  Widget _alertsLayer = const SizedBox.shrink();

  int _clampIndex(int i) {
    final last = widget.points.length - 1;
    if (last < 0 || i < 0) return 0;
    return i > last ? last : i;
  }

  @override
  void initState() {
    super.initState();

    _playback = PeriodicPlaybackController(
      vsync: this,
      onTick: (pos, segIndex, frac) {
        final idx = _clampIndex(segIndex);
        _playbackIndex = idx;
        _truck.value = _TruckState(pos, idx);

        if (widget.isPlaying) {
          widget.onPlaybackIndexChanged?.call(idx);
        }

        if (widget.autoCenter && !_userIsInteracting) {
          final zoom = widget.mapController.camera.zoom;
          widget.mapController.move(pos, zoom);
        }
      },
    );

    _buildTileLayer();
    _rebuildPointCaches();
    _setupPlaybackData(resetPos: true);

    _playbackIndex = _clampIndex(widget.currentIndex);

    if (widget.isPlaying) {
      _playback.play(startIndex: _playbackIndex);
    }
  }

  void _updatePlaybackSpeedOnly() {
    if (_coords.length < 2) return;

    final segDur = List<int>.filled(
      _coords.length - 1,
      widget.speed.segmentDurationMs,
    );

    _playback.setData(points: _coords, segmentDurationsMs: segDur);
  }

  @override
  void didUpdateWidget(covariant PeriodicMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    final pointsChanged = oldWidget.points != widget.points;
    final speedChanged = oldWidget.speed != widget.speed;
    final playingChanged = oldWidget.isPlaying != widget.isPlaying;
    final indexChanged = oldWidget.currentIndex != widget.currentIndex;

    if (oldWidget.isSatellite != widget.isSatellite) _buildTileLayer();

    if (pointsChanged) {
      _rebuildPointCaches();
      _setupPlaybackData(resetPos: true);
    }

    if (!pointsChanged && speedChanged) {
      _updatePlaybackSpeedOnly();

      if (widget.isPlaying) {
        _playback.play(startIndex: _playbackIndex);
      }
    }

    if (indexChanged && widget.points.isNotEmpty) {
      final idx = _clampIndex(widget.currentIndex);
      _playbackIndex = idx;

      final target = _coords[idx];

      if (widget.isPlaying) {
        _playback.play(startIndex: _playbackIndex);
      } else {
        _truck.value = _TruckState(target, idx);
      }

      if (widget.autoCenter && !_userIsInteracting) {
        widget.mapController.move(target, widget.mapController.camera.zoom);
      }
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
    _truck.dispose();
    super.dispose();
  }

  void _buildTileLayer() {
    _tileLayer = TileLayer(
      urlTemplate: widget.isSatellite ? googleSatelliteMapUrl : googleMapUrl,
      subdomains: googleMapSubdomains,
      userAgentPackageName: AppBranding.mapUserAgentPackageName,
    );
  }

  /// Susun ulang semua yang bergantung pada `points`: koordinat, alert, dan
  /// ketiga lapisan statis (garis, titik biru, pin alert).
  void _rebuildPointCaches() {
    final points = widget.points;
    _coords = [for (final p in points) LatLng(p.latitude, p.longitude)];
    _alertIdx = {
      for (var i = 0; i < points.length; i++)
        if (points[i].isAlert) i,
    };

    _polylineLayer = PolylineLayer(
      polylines: [
        Polyline(
          points: _coords,
          strokeWidth: 4,
          color: AppStyles.primaryColor.withOpacity(0.85),
        ),
      ],
    );

    // Titik biru tetap widget (tap langsung). CircleLayer sempat dicoba:
    // sama ringannya (terukur 9,6 vs 8,2 ms per frame), tapi di flutter_map 6
    // tap-nya harus lewat MapOptions.onTap, yang menunggu kemungkinan
    // double-tap sehingga tertunda ~250 ms.
    _dotsLayer = MarkerLayer(
      markers: [
        for (var i = 0; i < points.length; i++)
          // Titik alert sudah punya pin sendiri.
          if (!_alertIdx.contains(i))
            Marker(
              point: _coords[i],
              width: 16,
              height: 16,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () => _handlePointTap(i),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppStyles.blueColor, // #007BFF di Cordova
                    shape: BoxShape.circle,
                    border: Border.all(color: AppStyles.whiteColor, width: 2),
                  ),
                ),
              ),
            ),
      ],
    );

    _alertsLayer = MarkerLayer(
      markers: [
        for (final i in _alertIdx)
          Marker(
            point: _coords[i],
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => _handlePointTap(i), // ← pindah + popup
              child: SvgPicture.asset(
                AppMedia.alertIcon,
                width: 36,
                height: 36,
              ),
            ),
          ),
      ],
    );
  }

  void _setupPlaybackData({required bool resetPos}) {
    if (_coords.length < 2) return;

    final segDur = List<int>.filled(
      _coords.length - 1,
      widget.speed.segmentDurationMs,
    );

    _playback.setData(points: _coords, segmentDurationsMs: segDur);

    final safeIndex = _clampIndex(widget.currentIndex);
    _playbackIndex = safeIndex;

    if (resetPos) {
      _truck.value = _TruckState(_coords[safeIndex], safeIndex);
    }
  }

  double _bearingLatLng(LatLng a, LatLng b) {
    final lat1 = a.latitude * math.pi / 180;
    final lat2 = b.latitude * math.pi / 180;
    final dLon = (b.longitude - a.longitude) * math.pi / 180;

    final y = math.sin(dLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final brng = math.atan2(y, x) * 180 / math.pi;
    return (brng + 360) % 360;
  }

  void _handlePointTap(int index) {
    if (index < 0 || index >= widget.points.length) return;

    widget.onPointSelected(index);

    final point = widget.points[index];
    PeriodicAlertSheet.open(context, point);
  }

  /// Lapisan truk: satu-satunya bagian peta yang berubah tiap frame.
  Widget _buildTruckLayer(BuildContext context, _TruckState? truck, Widget? _) {
    final points = widget.points;
    final safeSelectedIndex = _clampIndex(widget.currentIndex);

    final idxForInfo = widget.isPlaying
        ? _clampIndex(truck?.index ?? _playbackIndex)
        : safeSelectedIndex;

    final truckPoint = truck?.pos ?? _coords[safeSelectedIndex];
    final curr = points[idxForInfo];
    final next = idxForInfo < points.length - 1
        ? _coords[idxForInfo + 1]
        : _coords[idxForInfo];

    return MarkerLayer(
      markers: [
        Marker(
          point: truckPoint,
          width: 90,
          height: 90,
          alignment: Alignment.center,
          // Truk tetap digambar paling atas supaya posisi pemutaran selalu
          // terlihat. Ia tidak punya aksi tap, jadi dikecualikan dari hit
          // test supaya tap selalu diteruskan ke pin di bawahnya.
          child: IgnorePointer(
            child: PeriodicTruckMarker(
              tooltipText: getDisplayValue(curr, widget.metric),
              bearingDeg: _bearingLatLng(truckPoint, next),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();

    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        initialCenter: _coords[_clampIndex(widget.currentIndex)],
        initialZoom: 16,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
        initialRotation: 0,
        onPositionChanged: (pos, hasGesture) {
          if (!hasGesture) return;

          _userIsInteracting = true;
          _resumeAutoCenterTimer?.cancel();
          // Cukup mengubah field: tidak ada yang digambar dari nilai ini, jadi
          // tidak perlu setState (yang dulu mem-build ulang seluruh peta
          // setiap kali user selesai menggeser).
          _resumeAutoCenterTimer = Timer(
            const Duration(milliseconds: 900),
            () => _userIsInteracting = false,
          );
        },
      ),
      children: [
        _tileLayer,
        _polylineLayer,
        _dotsLayer,
        // Alert SETELAH titik biru: di FlutterMap layer yang ditulis
        // belakangan digambar di atas sekaligus menerima tap lebih dulu.
        // Dulu urutannya terbalik, jadi pin alert tertutup titik biru dan tap
        // di atasnya ditangkap titik biru.
        _alertsLayer,
        ValueListenableBuilder<_TruckState?>(
          valueListenable: _truck,
          builder: _buildTruckLayer,
        ),
      ],
    );
  }
}
