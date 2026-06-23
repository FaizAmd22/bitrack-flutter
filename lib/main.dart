import 'package:ams/base/bottom_nav_bar.dart';
import 'package:ams/base/network/api_client.dart';
import 'package:ams/base/routes/app_routes.dart';
import 'package:ams/base/routes/navigation_service.dart';
import 'package:ams/base/widgets/guest_guard.dart';
import 'package:ams/screens/add_vehicle/add_vehicle.dart';
import 'package:ams/screens/change_password/change_password.dart';
import 'package:ams/screens/language/language.dart';
import 'package:ams/screens/login/login_screen.dart';
import 'package:ams/screens/notification/pages/map_coordinate_screen.dart';
import 'package:ams/screens/notification/pages/notes_screen.dart';
import 'package:ams/screens/notification_settings/notification_settings.dart';
import 'package:ams/screens/periodic_track/periodic_track.dart';
import 'package:ams/screens/splash_screen/splash_screen.dart';
import 'package:ams/screens/vehicle_detail/vehicle_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:media_kit/media_kit.dart';
import 'base/widgets/auth_guard.dart';
import 'base/localization/locale_controller.dart';
import 'package:ams/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Wrap in try-catch: on iOS, Keychain can throw when the device is locked
  // at launch time. Without this guard, any exception here prevents runApp()
  // from ever being called, leaving the native splash screen frozen.
  try {
    await ApiClient.loadTokenFromStorage();
  } catch (e) {
    debugPrint('Token load skipped: $e');
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FixTrack',
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
        AppRoutes.notesScreen: (_) => const AuthGuard(child: NotesScreen()),
        AppRoutes.mapCoordinateScreen: (_) =>
            const AuthGuard(child: MapCoordinateScreen()),
      },
    );
  }
}
