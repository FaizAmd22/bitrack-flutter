import 'package:bitrack_core/base/bottom_nav_bar.dart';
import 'package:bitrack_core/base/config/app_branding.dart';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/network/api_client.dart';
import 'package:bitrack_core/base/routes/app_routes.dart';
import 'package:bitrack_core/base/routes/navigation_service.dart';
import 'package:bitrack_core/base/services/demo_mode.dart';
import 'package:bitrack_core/base/widgets/demo_banner.dart';
import 'package:bitrack_core/base/widgets/guest_guard.dart';
import 'package:bitrack_core/screens/add_vehicle/add_vehicle.dart';
import 'package:bitrack_core/screens/change_password/change_password.dart';
import 'package:bitrack_core/screens/language/language.dart';
import 'package:bitrack_core/screens/login/login_screen.dart';
import 'package:bitrack_core/screens/notification/pages/map_coordinate_screen.dart';
import 'package:bitrack_core/screens/notification/pages/notes_screen.dart';
import 'package:bitrack_core/screens/notification_settings/notification_settings.dart';
import 'package:bitrack_core/screens/periodic_track/periodic_track.dart';
import 'package:bitrack_core/screens/register/register_screen.dart';
import 'package:bitrack_core/screens/splash_screen/splash_screen.dart';
import 'package:bitrack_core/screens/vehicle_detail/vehicle_detail.dart';
import 'package:bitrack_core/screens/work_order/models/work_order_args.dart';
import 'package:bitrack_core/screens/work_order/pages/create_detail_wo/create_detail_wo.dart';
import 'package:bitrack_core/screens/work_order/pages/create_work_order/create_work_order.dart';
import 'package:bitrack_core/screens/work_order/pages/work_details/work_details.dart';
import 'package:bitrack_core/screens/work_order/pages/work_list/work_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:media_kit/media_kit.dart';
import 'package:bitrack_core/base/widgets/auth_guard.dart';
import 'package:bitrack_core/base/localization/locale_controller.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';

/// Env file dipilih lewat `--dart-define=ENV_FILE=.env.prod` saat run/build.
/// Tanpa flag ini (default), tetap pakai `.env` (dev).
const _envFile = String.fromEnvironment('ENV_FILE', defaultValue: '.env');

/// Warna brand FixTrack. Nilai ini TIDAK dipakai untuk mewarnai apa pun —
/// pewarnaan sesungguhnya lewat AppStyles.primaryColor di bitrack_core, yang
/// dibaca dari --dart-define=APP_PRIMARY_COLOR saat compile. Konstanta di sini
/// cuma nilai pembanding untuk assert di main(): tanpa itu, lupa memasang
/// --dart-define cuma menghasilkan app yang diam-diam salah warna (jatuh ke
/// default biru FixTrack) dan baru ketahuan setelah dilihat mata.
const _brandPrimaryColor = 0xFF386AD8;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  assert(
    AppStyles.primaryColor.toARGB32() == _brandPrimaryColor,
    'APP_PRIMARY_COLOR tidak ter-set ke 0xFF386AD8. Jalankan lewat '
    '`melos run fixtrack` atau tambahkan sendiri '
    '--dart-define=APP_PRIMARY_COLOR=0xFF386AD8 ke perintah flutter run/build.',
  );
  // Identitas brand FixTrack, dibaca kode shared di bitrack_core. Warna
  // primer TIDAK di sini - itu di-set lewat --dart-define=APP_PRIMARY_COLOR
  // saat run/build (lihat melos.yaml / .vscode/launch.json, dan
  // bitrack_core/base/res/styles/app_styles.dart untuk alasannya).
  // FixTrack memakai nilai default AppBranding, tapi tetap ditulis eksplisit
  // supaya sejajar dengan apps/bitrack dan apps/bitrack_internal.
  // splashLogoSize: logo FixTrack memanjang (279x54) - ini ukuran naturalnya, jadi tampilan
  // splash FixTrack tidak berubah sama sekali.
  AppBranding.configure(
    appName: 'FixTrack',
    mapUserAgentPackageName: 'fixtrack.treffix.id',
    splashLogoSize: const Size(279, 54),
  );
  MediaKit.ensureInitialized();
  await dotenv.load(fileName: _envFile);
  // Wrap in try-catch: on iOS, Keychain can throw when the device is locked
  // at launch time. Without this guard, any exception here prevents runApp()
  // from ever being called, leaving the native splash screen frozen.
  try {
    await ApiClient.loadTokenFromStorage();
    await DemoMode.loadFromStorage();
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
      title: AppBranding.appName,
      navigatorKey: NavigationService.navigatorKey,
      locale: locale,
      supportedLocales: LocaleNotifier.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      builder: (context, child) =>
          DemoBanner(child: child ?? const SizedBox.shrink()),
      initialRoute: AppRoutes.splashScreen,
      routes: {
        AppRoutes.splashScreen: (_) => const SplashScreen(),
        AppRoutes.loginScreen: (_) => const GuestGuard(child: LoginScreen()),
        AppRoutes.registerScreen: (_) =>
            const GuestGuard(child: RegisterScreen()),
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
      // Halaman work order butuh argumen, jadi dibuat lewat onGenerateRoute.
      onGenerateRoute: _workOrderRoute,
    );
  }

  Route<dynamic>? _workOrderRoute(RouteSettings settings) {
    Widget? page;

    switch (settings.name) {
      case AppRoutes.createWorkOrderScreen:
        page = const CreateWorkOrderScreen();
        break;

      case AppRoutes.workListScreen:
        final args = settings.arguments;
        if (args is WorkListArgs) page = WorkListScreen(args: args);
        break;

      case AppRoutes.workDetailsScreen:
        final args = settings.arguments;
        if (args is WorkDetailsArgs) page = WorkDetailsScreen(args: args);
        break;

      case AppRoutes.createDetailWoScreen:
        final args = settings.arguments;
        if (args is CreateDetailWoArgs) page = CreateDetailWoScreen(args: args);
        break;
    }

    if (page == null) return null;

    return MaterialPageRoute(
      settings: settings,
      builder: (_) => AuthGuard(child: page!),
    );
  }
}
