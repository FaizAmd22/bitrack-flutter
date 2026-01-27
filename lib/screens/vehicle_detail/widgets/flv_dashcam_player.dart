// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';

// class FlvDashcamPlayer extends StatefulWidget {
//   const FlvDashcamPlayer({
//     super.key,
//     required this.streamUrl,
//     this.aspectRatio = 16 / 9,
//     this.onPlaying,
//   });

//   final String streamUrl;
//   final double aspectRatio;
//   final VoidCallback? onPlaying;

//   @override
//   State<FlvDashcamPlayer> createState() => _FlvDashcamPlayerState();
// }

// class _FlvDashcamPlayerState extends State<FlvDashcamPlayer> {
//   late final Player _player;
//   late final VideoController _controller;

//   bool _loading = true;
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();

//     _player = Player(
//       configuration: const PlayerConfiguration(bufferSize: 32 * 1024 * 1024),
//     );

//     _controller = VideoController(_player);

//     _player.stream.playing.listen((playing) {
//       if (_isPlaying != playing) {
//         setState(() => _isPlaying = playing);
//       }
//     });

//     _player.stream.position.listen((pos) {
//       if (_loading && pos > Duration.zero) {
//         setState(() => _loading = false);
//         widget.onPlaying?.call();
//       }
//     });

//     _player.open(
//       Media(
//         widget.streamUrl,
//         httpHeaders: {
//           'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36',
//         },
//       ),
//       play: true,
//     );
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }

//   void _togglePlay() {
//     _isPlaying ? _player.pause() : _player.play();
//   }

//   Future<void> _openFullscreen() async {
//     await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => _FullscreenVideoPage(streamUrl: widget.streamUrl),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(14),
//       child: Stack(
//         children: [
//           AspectRatio(
//             aspectRatio: widget.aspectRatio,
//             child: Video(controller: _controller, fit: BoxFit.cover),
//           ),

//           if (_loading)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black.withOpacity(0.25),
//                 alignment: Alignment.center,
//                 child: const CircularProgressIndicator(),
//               ),
//             ),

//           Positioned(
//             right: 8,
//             bottom: 8,
//             child: Row(
//               children: [
//                 _CtrlBtn(
//                   icon: _isPlaying ? Icons.pause : Icons.play_arrow,
//                   onTap: _togglePlay,
//                 ),
//                 const SizedBox(width: 8),
//                 _CtrlBtn(icon: Icons.fullscreen, onTap: _openFullscreen),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _CtrlBtn extends StatelessWidget {
//   const _CtrlBtn({required this.icon, required this.onTap});

//   final IconData icon;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.black54,
//       borderRadius: BorderRadius.circular(10),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         child: Padding(
//           padding: const EdgeInsets.all(8),
//           child: Icon(icon, color: Colors.white, size: 20),
//         ),
//       ),
//     );
//   }
// }

// class _FullscreenVideoPage extends StatefulWidget {
//   const _FullscreenVideoPage({required this.streamUrl});
//   final String streamUrl;

//   @override
//   State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
// }

// class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
//   late final Player _player;
//   late final VideoController _controller;

//   @override
//   void initState() {
//     super.initState();

//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);

//     _player = Player();
//     _controller = VideoController(_player);

//     _player.open(Media(widget.streamUrl), play: true);
//   }

//   @override
//   void dispose() {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

//     _player.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           Center(
//             child: AspectRatio(
//               aspectRatio: 16 / 9,
//               child: Video(controller: _controller, fit: BoxFit.contain),
//             ),
//           ),
//           Positioned(
//             top: 12,
//             left: 12,
//             child: _CtrlBtn(
//               icon: Icons.arrow_back,
//               onTap: () => Navigator.of(context).pop(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
