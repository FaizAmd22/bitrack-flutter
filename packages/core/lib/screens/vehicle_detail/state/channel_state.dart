import 'dart:async';

/// Status satu channel kamera dashcam di sheet Dashcam.
enum ChannelStatus { idle, loading, active, error }

/// State mutable satu channel kamera: status, hitung mundur sisa waktu
/// tayang, URL stream, dan pesan error. Diubah langsung oleh sheet Dashcam
/// (lalu `setState`).
class ChannelState {
  ChannelStatus status;

  /// Sisa waktu tayang dalam detik (stream dihentikan saat habis).
  int timer;
  String? errorMessage;
  String? streamUrl;
  Timer? countdown;

  ChannelState({
    this.status = ChannelStatus.idle,
    this.timer = 30,
    this.errorMessage,
    this.streamUrl,
    this.countdown,
  });
}
