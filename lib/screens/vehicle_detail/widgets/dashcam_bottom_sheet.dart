// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:typed_data';

import 'package:ams/screens/vehicle_detail/models/dashcam_models.dart';
import 'package:ams/screens/vehicle_detail/services/g711_decoder.dart';
import 'package:ams/screens/vehicle_detail/services/mettaxiot_api.dart';
import 'package:ams/screens/vehicle_detail/state/channel_state.dart';
import 'package:ams/screens/vehicle_detail/widgets/bottom_actions.dart';
import 'package:ams/screens/vehicle_detail/widgets/channel_card.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:ams/base/res/styles/app_styles.dart';

class DashcamBottomSheet extends StatefulWidget {
  final DashcamConfig dashcamConfig;

  const DashcamBottomSheet({super.key, required this.dashcamConfig});

  static Future<void> open(
    BuildContext context, {
    required DashcamConfig dashcamConfig,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DashcamBottomSheet(dashcamConfig: dashcamConfig),
    );
  }

  @override
  State<DashcamBottomSheet> createState() => _DashcamBottomSheetState();
}

class _DashcamBottomSheetState extends State<DashcamBottomSheet> {
  final Map<int, ChannelState> _channels = {};

  // Speaker / Intercom
  bool _isSpeaker = false;
  bool _isSpeakerLoading = false;
  bool _isMicrophone = false;
  String? _audioError;

  WebSocketChannel? _wsChannel;
  StreamSubscription? _wsSub;

  final AudioPlayer _audioPlayer = AudioPlayer();

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    for (final ch in widget.dashcamConfig.channels) {
      _channels[ch] = ChannelState();
    }
  }

  @override
  void dispose() {
    _cancelAllTimers();
    _stopAudioStream();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ── Timer helpers ──────────────────────────────────────────────────────────

  void _cancelAllTimers() {
    for (final s in _channels.values) {
      s.countdown?.cancel();
    }
  }

  void _startTimer(int channelId) {
    final s = _channels[channelId]!;
    s.countdown?.cancel();
    s.timer = 30;

    s.countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (s.timer > 1) {
          s.timer--;
        } else {
          t.cancel();
          s.status = ChannelStatus.idle;
          s.timer = 30;
          s.errorMessage = null;
          s.streamUrl = null;
        }
      });
    });
  }

  void _stopTimer(int channelId) {
    final s = _channels[channelId]!;
    s.countdown?.cancel();
    s.timer = 30;
  }

  String _formatTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── Channel toggle ─────────────────────────────────────────────────────────

  Future<void> _handleToggle(int channelId) async {
    final s = _channels[channelId]!;

    if (s.status == ChannelStatus.active || s.status == ChannelStatus.loading) {
      setState(() {
        s.status = ChannelStatus.idle;
        s.errorMessage = null;
        s.streamUrl = null;
      });
      _stopTimer(channelId);
      return;
    }

    setState(() => s.status = ChannelStatus.loading);

    try {
      final url = await MettaxiotApi.getLiveStreamUrl(
        deviceId: widget.dashcamConfig.deviceId,
        channelId: channelId,
        camType: widget.dashcamConfig.type,
      );
      if (!mounted) return;
      setState(() {
        s.status = ChannelStatus.active;
        s.streamUrl = url;
        s.errorMessage = null;
      });
      _startTimer(channelId);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        s.status = ChannelStatus.error;
        s.errorMessage = 'Camera is offline right now.';
      });
    }
  }

  // ── Speaker ────────────────────────────────────────────────────────────────

  Future<void> _handleSpeaker() async {
    if (_isSpeaker) {
      _stopAudioStream();
      setState(() {
        _isSpeaker = false;
        _audioError = null;
      });
      return;
    }

    setState(() {
      _isSpeakerLoading = true;
      _audioError = null;
    });

    try {
      final talkUrl = await MettaxiotApi.getTalkUrl(
        deviceId: widget.dashcamConfig.deviceId,
      );
      _startAudioStream(talkUrl);
      if (!mounted) return;
      setState(() => _isSpeaker = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _audioError = e.toString());
    } finally {
      if (mounted) setState(() => _isSpeakerLoading = false);
    }
  }

  void _startAudioStream(String talkUrl) {
    _wsChannel = WebSocketChannel.connect(Uri.parse(talkUrl));
    _wsSub = _wsChannel!.stream.listen(
      (data) {
        if (data is List<int>) {
          final pcm = G711Decoder.decode(Uint8List.fromList(data));
          unawaited(_playWavBytes(G711Decoder.toWav(pcm)));
        } else if (data is String) {
          final errorMsg = switch (data) {
            'repeat' => 'Device is busy',
            'error' => 'Device error occurred',
            _ => null,
          };
          if (errorMsg != null) {
            setState(() => _audioError = errorMsg);
            _stopAudioStream();
          }
        }
      },
      onError: (_) =>
          setState(() => _audioError = 'WebSocket connection failed'),
      onDone: () => debugPrint('WebSocket closed'),
    );
  }

  void _stopAudioStream() {
    _wsSub?.cancel();
    _wsSub = null;
    _wsChannel?.sink.close();
    _wsChannel = null;
    _audioPlayer.stop();
    if (_isMicrophone) setState(() => _isMicrophone = false);
  }

  // ── Audio playback ────────────────────────────────────────────────────────

  Future<void> _playWavBytes(Uint8List wav) async {
    try {
      await _audioPlayer.play(BytesSource(wav));
    } catch (e) {
      debugPrint('Audio playback error: $e');
    }
  }

  // ── Microphone ─────────────────────────────────────────────────────────────

  void _handleMicrophone() {
    if (!_isSpeaker) {
      setState(
        () => _audioError =
            'Please turn on speaker first before using microphone',
      );
      return;
    }
    setState(() => _isMicrophone = !_isMicrophone);
    // TODO: integrasikan microphone recording + G.711 encode + WS send
    // Pattern dari Cordova: initRecord() → RealTimeSendTry() → TransferUpload()
    // Di Flutter: gunakan package `record`, encode PCM ke G.711A, kirim via _wsChannel.
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          height: mq.size.height * 0.65,
          decoration: const BoxDecoration(
            color: AppStyles.whiteColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              _buildDragHandle(),
              _buildTitle(),
              Expanded(child: _buildChannelList()),
              if (_audioError != null) _buildAudioErrorBanner(),
              BottomActions(
                isSpeaker: _isSpeaker,
                isSpeakerLoading: _isSpeakerLoading,
                isMicrophone: _isMicrophone,
                onSpeakerTap: _handleSpeaker,
                onMicrophoneTap: _handleMicrophone,
                bottomInset: mq.viewInsets.bottom,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 48,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('Dashcam', style: AppStyles.textLBold),
      ),
    );
  }

  Widget _buildChannelList() {
    if (widget.dashcamConfig.channels.isEmpty) {
      return const Center(child: Text('No dashcam channels available.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: widget.dashcamConfig.channels.length,
      itemBuilder: (_, i) {
        final ch = widget.dashcamConfig.channels[i];
        return ChannelCard(
          index: i,
          channelId: ch,
          state: _channels[ch]!,
          onToggle: () => _handleToggle(ch),
          formatTimer: _formatTimer,
        );
      },
    );
  }

  Widget _buildAudioErrorBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppStyles.redColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _audioError!,
              style: AppStyles.textSm.copyWith(color: Colors.white),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _audioError = null),
            child: const Icon(Icons.close, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
