import 'package:bitrack_mobile_flutter/base/res/media.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/base/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _storage = FlutterSecureStorage();
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
    final results = await Future.wait([
      Future.delayed(_minSplash),
      _storage.read(key: 'auth_token'),
    ]);

    final token = (results[1] as String?)?.trim() ?? '';
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
          color: AppStyles.darkRedColor,
          image: const DecorationImage(
            image: AssetImage(AppMedia.bgLogin),
            fit: BoxFit.cover,
          ),
        ),
        child: const Center(child: Image(image: AssetImage(AppMedia.logo))),
      ),
    );
  }
}
