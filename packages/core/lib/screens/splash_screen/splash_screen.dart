import 'package:bitrack_core/base/config/app_branding.dart';
import 'package:bitrack_core/base/res/media.dart';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  static const _minSplash = Duration(milliseconds: 900);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppMedia.bgLogin), context);
    precacheImage(const AssetImage(AppMedia.logo), context);
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final minDelay = Future.delayed(_minSplash);
    String token = '';
    try {
      final results = await Future.wait([
        minDelay,
        _storage.read(key: 'auth_token'),
      ]);
      token = (results[1] as String?)?.trim() ?? '';
    } catch (_) {
      await minDelay;
    }
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      token.isNotEmpty ? AppRoutes.homeScreen : AppRoutes.loginScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          color: AppStyles.primaryColor,
          image: const DecorationImage(
            image: AssetImage(AppMedia.bgLogin),
            fit: BoxFit.cover,
          ),
        ),
        // Logo digambar di dalam kotak berukuran tetap per app, bukan
        // seukuran natural PNG-nya: bentuk logo tiap app beda jauh (FixTrack
        // memanjang, Bitrack lebih kotak), jadi ukuran natural yang pas untuk
        // satu app bikin app lain kebesaran/kekecilan. BoxFit.contain
        // men-scale logo sampai muat tanpa mengubah rasio, dan karena
        // kotaknya tight, mengganti file logo dengan resolusi berbeda tidak
        // ikut mengubah besar logo yang tampil.
        child: Center(
          child: SizedBox.fromSize(
            size: AppBranding.splashLogoSize,
            child: const Image(
              image: AssetImage(AppMedia.logo),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
