import 'package:bitrack_mobile_flutter/base/bottom_nav_bar.dart';
import 'package:bitrack_mobile_flutter/base/routes/app_routes.dart';
import 'package:bitrack_mobile_flutter/base/routes/navigation_service.dart';
import 'package:bitrack_mobile_flutter/base/widgets/guest_guard.dart';
import 'package:bitrack_mobile_flutter/screens/add_vehicle/add_vehicle.dart';
import 'package:bitrack_mobile_flutter/screens/change_password/change_password.dart';
import 'package:bitrack_mobile_flutter/screens/language/language.dart';
import 'package:bitrack_mobile_flutter/screens/login/login_screen.dart';
import 'package:bitrack_mobile_flutter/screens/notification_settings/notification_settings.dart';
import 'package:bitrack_mobile_flutter/screens/periodic_track/periodic_track.dart';
import 'package:bitrack_mobile_flutter/screens/splash_screen/splash_screen.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/vehicle_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'base/widgets/auth_guard.dart';
import 'base/localization/locale_controller.dart';
import 'package:bitrack_mobile_flutter/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bitrack',
      navigatorKey: NavigationService.navigatorKey,
      locale: locale,
      supportedLocales: LocaleNotifier.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      initialRoute: AppRoutes.splashScreen,
      routes: {
        AppRoutes.splashScreen: (_) => const SplashScreen(),
        AppRoutes.loginScreen: (_) => const GuestGuard(child: LoginScreen()),
        AppRoutes.homeScreen: (_) => const AuthGuard(child: BottomNavBar()),
        AppRoutes.vehicleDetailScreen: (_) =>
            const AuthGuard(child: VehicleDetail()),
        AppRoutes.languageScreen: (_) =>
            const AuthGuard(child: LanguageScreen()),
        AppRoutes.notificationSettingScreen: (_) =>
            const AuthGuard(child: NotificationSettingsScreen()),
        AppRoutes.changePasswordScreen: (_) =>
            const AuthGuard(child: ChangePasswordScreen()),
        AppRoutes.addVehicleScreen: (_) =>
            const AuthGuard(child: AddVehicleScreen()),
        AppRoutes.periodicTrackScreen: (_) =>
            const AuthGuard(child: PeriodicTrackScreen()),
      },
    );
  }
}
