import 'dart:async';

enum ChannelStatus { idle, loading, active, error }

class ChannelState {
  ChannelStatus status;
  int timer; // seconds remaining
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
