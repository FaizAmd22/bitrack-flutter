// Dialog izin notifikasi di layar login muncul SETELAH user memilih
// menyimpan biometric atau tidak, tidak bertumpuk dengan dialog biometric.
import 'package:bitrack_core/base/network/api_client.dart';
import 'package:bitrack_core/base/routes/app_routes.dart';
import 'package:bitrack_core/base/services/push_notification_service.dart';
import 'package:bitrack_core/features/app_config/providers/app_config_providers.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/login/widgets/form_login.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePushClient implements PushClient {
  final calls = <String>[];

  @override
  Future<void> initialize(String appId) async => calls.add('initialize');

  @override
  Future<void> login(String externalId) async => calls.add('login:$externalId');

  @override
  Future<void> logout() async => calls.add('logout');

  @override
  Future<bool> requestPermission() async {
    calls.add('requestPermission');
    return true;
  }
}

/// Server palsu untuk `POST /mobile/auth/login`.
final _fakeServer = InterceptorsWrapper(
  onRequest: (options, handler) {
    if (!options.path.endsWith('/mobile/auth/login')) {
      return handler.next(options);
    }
    handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'data': {
            'token': 'token-abc',
            'user': {'id': 42, 'name': 'Budi', 'email': 'budi@x.id'},
          },
        },
      ),
    );
  },
);

Widget _loginPage() => ProviderScope(
  overrides: [showRegisterLinkProvider.overrideWith((ref) async => false)],
  child: MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    routes: {AppRoutes.homeScreen: (_) => const Scaffold(body: Text('HOME'))},
    home: const Scaffold(body: SingleChildScrollView(child: FormLogin())),
  ),
);

void main() {
  late _FakePushClient fake;

  setUp(() {
    PushNotificationService.resetForTest();
    fake = _FakePushClient();
    PushNotificationService.client = fake;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    dotenv.testLoad(
      fileInput: 'ONESIGNAL_APP_ID=app-123\nBASE_URL=http://test.local',
    );
    ApiClient.dio.interceptors.insert(0, _fakeServer);
    addTearDown(() => ApiClient.dio.interceptors.remove(_fakeServer));
  });

  Future<void> loginUntilBiometricDialog(WidgetTester tester) async {
    await PushNotificationService.start();
    await tester.pumpWidget(_loginPage());
    await tester.pump();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'budi@x.id');
    await tester.enterText(fields.at(1), 'rahasia');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Dialog biometric terbuka, dialog izin belum boleh muncul.
    expect(find.text('Cancel'), findsOneWidget);
    expect(fake.calls, contains('login:budi@x.id'));
    expect(fake.calls, isNot(contains('requestPermission')));
  }

  for (final choice in ['Cancel', 'Save']) {
    testWidgets('memilih "$choice" di dialog biometric, baru izin notifikasi '
        'ditanyakan', (tester) async {
      await loginUntilBiometricDialog(tester);

      await tester.tap(find.text(choice));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('HOME'), findsOneWidget);
      expect(fake.calls.where((c) => c == 'requestPermission'), hasLength(1));
    });
  }
}
