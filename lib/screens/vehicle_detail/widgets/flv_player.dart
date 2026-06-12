// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:ams/base/res/styles/app_styles.dart';

import 'fullscreen_player.dart';

/// Live FLV player via media_kit (support FLV / RTMP / HLS).
///
/// pubspec.yaml dependencies:
///   media_kit: ^1.1.11
///   media_kit_video: ^1.2.4
///   media_kit_libs_video: ^1.0.5
class FlvPlayer extends StatefulWidget {
  final String streamUrl;

  const FlvPlayer({super.key, required this.streamUrl});

  @override
  State<FlvPlayer> createState() => _FlvPlayerState();
}

class _FlvPlayerState extends State<FlvPlayer> {
  late final Player _player;
  late final VideoController _controller;

  bool _error = false;
  bool _loading = true;

  // Timeout fallback jika player tidak kunjung playing
  static const _timeoutDuration = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _listenToPlayerState();
    _initPlayer();
  }

  /// Listen ke stream state player — lebih reliable daripada await open().
  /// Untuk live stream, open() bisa hang tanpa resolve/reject.
  void _listenToPlayerState() {
    // Selesai loading saat player mulai playing
    _player.stream.playing.listen((isPlaying) {
      if (isPlaying && mounted && _loading) {
        setState(() => _loading = false);
      }
    });

    // Tangkap error dari player
    _player.stream.error.listen((e) {
      debugPrint('FLV player error: $e');
      if (mounted) {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    });
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setVolume(0); // suara hanya dari WebSocket speaker

      // Tidak di-await agar tidak hang untuk live stream
      unawaited(_player.open(Media(widget.streamUrl), play: true));

      // Fallback: jika 15 detik belum playing, anggap error
      Future.delayed(_timeoutDuration, () {
        if (mounted && _loading) {
          setState(() {
            _error = true;
            _loading = false;
          });
        }
      });
    } catch (e) {
      debugPrint('FLV player init error: $e');
      if (mounted) {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(FlvPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamUrl != widget.streamUrl) {
      setState(() {
        _loading = true;
        _error = false;
      });
      _player.setVolume(0).then((_) {
        unawaited(_player.open(Media(widget.streamUrl), play: true));
        Future.delayed(_timeoutDuration, () {
          if (mounted && _loading) {
            setState(() {
              _error = true;
              _loading = false;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) =>
            FullscreenPlayer(controller: _controller, player: _player),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error) return _buildError();
    if (_loading) return _buildLoading();

    return Stack(
      children: [
        Video(controller: _controller, controls: NoVideoControls),
        Positioned(
          right: 8,
          bottom: 8,
          child: GestureDetector(
            onTap: _openFullscreen,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.fullscreen,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() => const Center(
    child: CircularProgressIndicator(color: AppStyles.primaryColor),
  );

  Widget _buildError() => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.videocam_off_outlined, color: AppStyles.redColor, size: 28),
        SizedBox(height: 6),
        Text(
          'Camera is offline right now.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppStyles.redColor, fontSize: 12),
        ),
      ],
    ),
  );
}
