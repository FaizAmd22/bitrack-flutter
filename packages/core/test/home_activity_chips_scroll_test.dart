// Posisi scroll chip activity di home tidak boleh tereset saat chip ditekan.
//
// Penyebabnya: overlay loading muncul DI TENGAH daftar anak Stack di
// home_screen. Tanpa key, Flutter mencocokkan anak menurut urutan, jadi begitu
// overlay muncul, search bar + ActivityChips dianggap widget lain dan dibangun
// ulang dari nol — daftar chip kembali ke posisi paling kiri.

import 'package:bitrack_core/features/monitoring/providers/monitoring_providers.dart';
import 'package:bitrack_core/features/monitoring/providers/plate_suggestion_provider.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/home/home_screen.dart';
import 'package:bitrack_core/screens/home/models/vehicle.dart';
import 'package:bitrack_core/screens/home/widgets/activity_chips.dart';
import 'package:bitrack_core/screens/vehicle/providers/fleet_group_provider.dart';
import 'package:bitrack_core/base/widgets/full_screen_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/stub_asset_bundle.dart';

Vehicle _v(String id) => Vehicle(
  id: id,
  vehicleId: id,
  latitude: -6.2,
  longitude: 106.8,
  bearing: 0,
  activity: 'MOVING',
  deviceTime: '2026-01-01 00:00:00',
  ignition: 1,
  licensePlate: 'B $id XX',
  fleetGroupName: 'grup',
  vehicleCategoryIcon: '',
);

/// Tile peta benar-benar ditarik lewat HTTP, dan di lingkungan tes semuanya
/// dijawab 400. Error itu tidak ada hubungannya dengan yang diuji di sini.
void _muteTileImageErrors() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.library == 'image resource service') return;
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}

Widget _harness() => ProviderScope(
  overrides: [
    // Ditunda supaya overlay loading benar-benar sempat tampil, seperti saat
    // menunggu server. Tanpa penundaan, overlay muncul dan hilang dalam satu
    // microtask dan kasusnya tidak pernah terjadi.
    monitoringProvider.overrideWith((ref, query) async {
      await Future<void>.delayed(_serverDelay);
      return MonitoringData(vehicles: [_v('a')], total: 1);
    }),
    plateSuggestionProvider.overrideWith((ref, filter) => const <String>[]),
    fleetGroupProvider.overrideWith(
      (ref) async => const <Map<String, dynamic>>[],
    ),
  ],
  child: withStubAssets(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(isActive: true),
    ),
  ),
);

const _serverDelay = Duration(milliseconds: 300);

Finder get _chipList => find.descendant(
  of: find.byType(ActivityChips),
  matching: find.byType(Scrollable),
);

double _offset(WidgetTester tester) =>
    tester.state<ScrollableState>(_chipList).position.pixels;

void main() {
  setUpAll(() => dotenv.testLoad(fileInput: 'GOOGLE_MAP_KEY=test-key'));

  testWidgets('menekan chip tidak mengembalikan daftar ke posisi awal', (
    tester,
  ) async {
    _muteTileImageErrors();
    await tester.pumpWidget(_harness());
    await tester.pump(_serverDelay);
    await tester.pump();

    // Geser ke chip-chip di sebelah kanan, seperti user yang mencari
    // "In Repair".
    await tester.drag(_chipList, const Offset(-250, 0));
    await tester.pump();
    final before = _offset(tester);
    expect(before, greaterThan(0), reason: 'daftar memang sudah tergeser');

    // Chip yang terlihat setelah digeser, lalu ditekan.
    final label = tester.widget<Text>(
      find
          .descendant(
            of: find.byType(ActivityChips),
            matching: find.byType(Text),
          )
          .last,
    );
    await tester.tap(find.text(label.data!));
    await tester.pump();

    expect(
      find.byType(FullScreenLoading),
      findsOneWidget,
      reason: 'overlay loading inilah yang dulu membangun ulang daftar chip',
    );
    expect(_offset(tester), closeTo(before, 1));

    // Data masuk, overlay hilang: posisinya tetap.
    await tester.pump(_serverDelay);
    await tester.pump();
    expect(_offset(tester), closeTo(before, 1));
  });
}
