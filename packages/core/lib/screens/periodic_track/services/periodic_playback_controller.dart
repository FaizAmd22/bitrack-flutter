import 'dart:math' as math;
import 'package:flutter/scheduler.dart';
import 'package:latlong2/latlong.dart';

/// Dipanggil setiap frame animasi dengan posisi marker saat ini, indeks
/// segmen (antara titik [segmentIndex] dan berikutnya), dan seberapa jauh
/// marker di segmen itu (0..1).
typedef OnTick =
    void Function(LatLng position, int segmentIndex, double fraction);

/// Mesin animasi pemutaran ulang Periodic Track.
///
/// Menggerakkan marker sepanjang daftar titik dengan interpolasi posisi
/// antar-titik, memakai Ticker Flutter (sinkron dengan refresh layar) dan
/// dibatasi [targetFps]. Durasi tiap segmen diatur [setData] (mengikuti
/// kecepatan playback yang dipilih).
class PeriodicPlaybackController {
  PeriodicPlaybackController({
    required TickerProvider vsync,
    required this.onTick,
    this.targetFps = 30,
  }) {
    _ticker = vsync.createTicker(_tick);
  }

  final OnTick onTick;
  final int targetFps;

  late final Ticker _ticker;

  List<LatLng> _points = const [];
  List<int> _segmentDurationsMs = const [];

  int _startIndex = 0;
  bool _isPlaying = false;

  Duration? _startTs;
  Duration _lastFrameTs = Duration.zero;
  int _totalMs = 1;

  bool get isPlaying => _isPlaying;

  /// Pasang titik dan durasi tiap segmen (`segmentDurationsMs[i]` = lama
  /// animasi dari titik i ke i+1).
  void setData({
    required List<LatLng> points,
    required List<int> segmentDurationsMs,
  }) {
    _points = points;
    _segmentDurationsMs = segmentDurationsMs;
  }

  /// Mulai/lanjutkan pemutaran dari titik [startIndex].
  void play({required int startIndex}) {
    if (_points.length < 2) return;

    _startIndex = startIndex.clamp(0, _points.length - 2);
    _recalcTotal();

    _isPlaying = true;
    _startTs = null;
    _lastFrameTs = Duration.zero;

    if (!_ticker.isActive) _ticker.start();
  }

  void pause() {
    _isPlaying = false;
    if (_ticker.isActive) _ticker.stop();
  }

  void dispose() {
    _ticker.dispose();
  }

  /// Total durasi dari titik awal sampai akhir.
  void _recalcTotal() {
    int total = 0;
    for (int i = _startIndex; i < _points.length - 1; i++) {
      total += _segmentDurationsMs[i];
    }
    _totalMs = math.max(1, total);
  }

  void _tick(Duration ts) {
    if (!_isPlaying) return;

    // Batasi jumlah frame per detik (sama seperti targetFPS di app lama).
    final frameIntervalMs = (1000 / targetFps).floor();
    if (_lastFrameTs != Duration.zero) {
      final deltaMs = (ts - _lastFrameTs).inMilliseconds;
      if (deltaMs < frameIntervalMs) return;
    }
    _lastFrameTs = ts;

    _startTs ??= ts;

    final elapsedMs = (ts - _startTs!).inMilliseconds;
    final progress = elapsedMs / _totalMs;

    // Selesai sampai titik akhir
    if (progress >= 1) {
      final last = _points.last;
      onTick(last, _points.length - 2, 1.0);
      pause();
      return;
    }

    // Cari segmen aktif
    double remaining = elapsedMs.toDouble();
    int seg = _startIndex;

    while (seg < _points.length - 1) {
      final d = _segmentDurationsMs[seg].toDouble();
      if (remaining <= d) break;
      remaining -= d;
      seg++;
    }

    if (seg >= _points.length - 1) {
      final last = _points.last;
      onTick(last, _points.length - 2, 1.0);
      pause();
      return;
    }

    final segDur = math.max(1.0, _segmentDurationsMs[seg].toDouble());
    final t = (remaining / segDur).clamp(0.0, 1.0);

    final a = _points[seg];
    final b = _points[seg + 1];

    // Interpolasi linear posisi antara dua titik; inilah yang membuat
    // gerakan marker halus.
    final lat = a.latitude + (b.latitude - a.latitude) * t;
    final lng = a.longitude + (b.longitude - a.longitude) * t;

    onTick(LatLng(lat, lng), seg, t);
  }
}
