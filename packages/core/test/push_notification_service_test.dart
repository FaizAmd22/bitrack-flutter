// Push notification (OneSignal): perangkat ditautkan ke user (external ID =
// email) saat login dan saat app dibuka dengan sesi lama, dilepas saat logout,
// dan tidak pernah merusak alur app kalau OneSignal belum dikonfigurasi atau
// gagal. Dialog izin hanya muncul lewat requestPermission(), sekali saja.
import 'dart:async';

import 'package:bitrack_core/base/network/api_client.dart';
import 'package:bitrack_core/base/services/demo_mode.dart';
import 'package:bitrack_core/base/services/push_notification_service.dart';
import 'package:bitrack_core/features/auth/providers/auth_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pengganti plugin OneSignal: mencatat panggilan, bisa diperlambat atau
/// dibuat gagal.
class FakePushClient implements PushClient {
  final calls = <String>[];
  Object? loginError;
  Completer<void>? initGate;

  @override
  Future<void> initialize(String appId) async {
    await initGate?.future;
    calls.add('initialize:$appId');
  }

  @override
  Future<void> login(String externalId) async {
    if (loginError != null) throw loginError!;
    calls.add('login:$externalId');
  }

  @override
  Future<void> logout() async => calls.add('logout');

  @override
  Future<bool> requestPermission() async {
    calls.add('requestPermission');
    return true;
  }
}

const _env = 'ONESIGNAL_APP_ID=app-123\nBASE_URL=http://test.local';

/// Beri kesempatan pekerjaan yang tidak ditunggu berjalan.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakePushClient fake;

  setUp(() {
    PushNotificationService.resetForTest();
    fake = FakePushClient();
    PushNotificationService.client = fake;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    dotenv.testLoad(fileInput: _env);
  });

  test(
    'tanpa ONESIGNAL_APP_ID: OneSignal tidak disentuh sama sekali',
    () async {
      dotenv.testLoad(fileInput: 'BASE_URL=http://test.local');

      await PushNotificationService.start();
      await PushNotificationService.onLogin('budi@x.id');
      await PushNotificationService.requestPermission();
      await PushNotificationService.onLogout();
      await _settle();

      expect(fake.calls, isEmpty);
      expect(PushNotificationService.isEnabled, isFalse);
    },
  );

  test('app dibuka dengan sesi lama: ditautkan lewat email, tanpa dialog '
      'izin', () async {
    FlutterSecureStorage.setMockInitialValues({
      'user_id': '42',
      'user_email': 'budi@x.id',
    });

    await PushNotificationService.start();
    await _settle();

    expect(fake.calls, ['initialize:app-123', 'login:budi@x.id']);
  });

  test('app dibuka tanpa sesi: tidak ada yang ditautkan', () async {
    await PushNotificationService.start();
    await _settle();

    expect(fake.calls, ['initialize:app-123']);
  });

  test('login saja tidak memunculkan dialog izin', () async {
    await PushNotificationService.start();
    await PushNotificationService.onLogin('budi@x.id');
    await _settle();

    expect(fake.calls, ['initialize:app-123', 'login:budi@x.id']);
  });

  test('izin notifikasi diminta sekali saja per instalasi', () async {
    await PushNotificationService.start();
    await PushNotificationService.requestPermission();
    await PushNotificationService.requestPermission();

    expect(fake.calls.where((c) => c == 'requestPermission'), hasLength(1));
  });

  test('login sebelum inisialisasi selesai tetap tertaut', () async {
    fake.initGate = Completer<void>();
    unawaited(PushNotificationService.start());

    final login = PushNotificationService.onLogin('cepat@x.id');
    fake.initGate!.complete();
    await login;

    expect(
      fake.calls,
      containsAllInOrder(['initialize:app-123', 'login:cepat@x.id']),
    );
  });

  test('akun demo: tidak ditautkan dan tidak ditanya izin', () async {
    await DemoMode.activate();
    addTearDown(DemoMode.clearOnLogout);

    await PushNotificationService.start();
    await PushNotificationService.onLogin('demo@treffix.id');
    await PushNotificationService.requestPermission();
    await _settle();

    expect(fake.calls, ['initialize:app-123']);
  });

  test('OneSignal gagal: login app tetap jalan, tanpa exception', () async {
    fake.loginError = Exception('jaringan putus');
    await PushNotificationService.start();

    await expectLater(PushNotificationService.onLogin('budi@x.id'), completes);
    await _settle();
    expect(fake.calls, ['initialize:app-123']);
  });

  group('tersambung ke alur app', () {
    test('login berhasil menautkan email dari response', () async {
      await PushNotificationService.start();

      final fakeServer = InterceptorsWrapper(
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
                  'user': {'id': 42, 'name': 'Budi', 'email': 'b@x.id'},
                },
              },
            ),
          );
        },
      );
      ApiClient.dio.interceptors.insert(0, fakeServer);
      addTearDown(() => ApiClient.dio.interceptors.remove(fakeServer));

      final auth = AuthController(const FlutterSecureStorage());
      addTearDown(auth.dispose);
      await auth.loginAndPersist(email: 'b@x.id', password: 'rahasia');
      await _settle();

      expect(fake.calls, contains('login:b@x.id'));
      expect(fake.calls, isNot(contains('login:42')));
    });

    test('logout melepas perangkat dari user', () async {
      await PushNotificationService.start();
      // setToken juga membuka kembali jalur logout yang dijaga _isLoggingOut.
      await ApiClient.setToken('token-abc');

      await ApiClient.logout();
      await _settle();

      expect(fake.calls, contains('logout'));
    });
  });
}
