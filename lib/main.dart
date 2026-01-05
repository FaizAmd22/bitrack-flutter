import 'package:bitrack_mobile_flutter/base/bottom_nav_bar.dart';
import 'package:bitrack_mobile_flutter/base/routes/app_routes.dart';
import 'package:bitrack_mobile_flutter/base/routes/navigation_service.dart';
import 'package:bitrack_mobile_flutter/screens/login/login_screen.dart';
import 'package:bitrack_mobile_flutter/screens/splash_screen/splash_screen.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/vehicle_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base/widgets/auth_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bitrack',
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: AppRoutes.splashScreen,
      routes: {
        AppRoutes.splashScreen: (_) => const SplashScreen(),
        AppRoutes.loginScreen: (_) => const LoginScreen(),
        AppRoutes.homeScreen: (_) => const AuthGuard(child: BottomNavBar()),
        AppRoutes.vehicleDetailScreen: (_) =>
            const AuthGuard(child: VehicleDetail()),
      },
    );
  }
}
