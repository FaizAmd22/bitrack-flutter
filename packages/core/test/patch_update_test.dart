// Patch Shorebird (code push): banner "Mengunduh pembaruan…" di akar app, dan
// popup "pembaruan siap" sesudah patch terunduh.
//
// Unduhan otomatis Shorebird dimatikan (auto_update: false), jadi app sendiri
// yang mengunduh dan memberi tahu user — lihat base/services/code_push_service.dart.
import 'dart:io';

import 'package:bitrack_core/base/services/code_push_service.dart';
import 'package:bitrack_core/base/widgets/patch_download_banner.dart';
import 'package:bitrack_core/base/widgets/patch_ready_popup.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const _downloading = 'Mengunduh pembaruan…';
const _readyTitle = 'Pembaruan siap';
const _restart = 'Mulai ulang';
const _later = 'Nanti';
const _close = 'Tutup';
const _manual = 'Tutup lalu buka lagi aplikasi untuk memakai pembaruan ini.';
const _restartFailed =
    'Gagal memulai ulang. Tutup lalu buka aplikasi secara manual.';

Widget _app({Widget? home, TransitionBuilder? builder}) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('id'),
  builder: builder,
  home: home ?? const Scaffold(body: Text('halaman')),
);

void main() {
  group('banner unduhan', () {
    var tapped = 0;

    Widget bannerApp() => _app(
      builder: (context, child) =>
          PatchDownloadBanner(onPatchReady: () async {}, child: child!),
      home: Scaffold(
        body: SizedBox.expand(
          child: TextButton(
            onPressed: () => tapped++,
            child: const Text('halaman'),
          ),
        ),
      ),
    );

    setUp(() {
      tapped = 0;
      patchDownloadInProgress.value = false;
    });

    testWidgets('tersembunyi selama tidak ada unduhan', (tester) async {
      await tester.pumpWidget(bannerApp());
      await tester.pumpAndSettle();

      expect(find.text(_downloading), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('muncul saat unduhan berjalan, hilang saat selesai', (
      tester,
    ) async {
      await tester.pumpWidget(bannerApp());
      await tester.pumpAndSettle();

      patchDownloadInProgress.value = true;
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(_downloading), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      patchDownloadInProgress.value = false;
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(_downloading), findsNothing);
    });

    testWidgets('tidak menghalangi sentuhan ke halaman di baliknya', (
      tester,
    ) async {
      await tester.pumpWidget(bannerApp());
      await tester.pumpAndSettle();
      patchDownloadInProgress.value = true;
      await tester.pump(const Duration(milliseconds: 300));

      // Ketuk tepat di posisi banner: yang menerima tetap tombol halaman.
      await tester.tapAt(tester.getCenter(find.text(_downloading)));
      expect(tapped, 1);

      patchDownloadInProgress.value = false;
      await tester.pump(const Duration(milliseconds: 300));
    });
  });

  group('popup pembaruan siap', () {
    testWidgets('Android: menawarkan mulai ulang, dan bisa ditunda', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(home: const Scaffold(body: PatchReadyDialog(canRestart: true))),
      );
      await tester.pumpAndSettle();

      expect(find.text(_readyTitle), findsOneWidget);
      expect(find.text(_restart), findsOneWidget);
      expect(find.text(_later), findsOneWidget);
      expect(find.text(_manual), findsNothing);
    });

    testWidgets('iOS: tanpa tombol mulai ulang, user diminta menutup sendiri', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(home: const Scaffold(body: PatchReadyDialog(canRestart: false))),
      );
      await tester.pumpAndSettle();

      expect(find.text(_manual), findsOneWidget);
      expect(find.text(_close), findsOneWidget);
      expect(find.text(_restart), findsNothing);
    });

    testWidgets('restart gagal: dialog tetap hidup dan memberi tahu user', (
      tester,
    ) async {
      // Plugin restart tidak ada di lingkungan tes, jadi panggilannya gagal —
      // persis kasus yang harus ditangani tanpa menjatuhkan dialog.
      await tester.pumpWidget(
        _app(home: const Scaffold(body: PatchReadyDialog(canRestart: true))),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(_restart));
      await tester.pump();
      // Panggilan restart menggantung di lingkungan tes; yang diuji justru
      // batas waktunya.
      await tester.pump(const Duration(seconds: 6));
      await tester.pump();

      expect(find.text(_restartFailed), findsOneWidget);
      expect(find.text(_readyTitle), findsOneWidget);
      // Tombol restart diganti tombol tutup: mencoba lagi tidak ada gunanya.
      expect(find.text(_restart), findsNothing);
      expect(find.text(_close), findsOneWidget);
    });

    testWidgets('hanya tampil sekali per sesi', (tester) async {
      resetPatchReadyPopupForTest();
      addTearDown(resetPatchReadyPopupForTest);

      await tester.pumpWidget(
        _app(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => maybeShowPatchReadyPopup(context: context),
                child: const Text('cek'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('cek'));
      await tester.pumpAndSettle();
      expect(find.text(_readyTitle), findsOneWidget);

      // Tutup, lalu picu lagi seperti saat app kembali dari background.
      await tester.tap(find.text(_close).hitTestable());
      await tester.pumpAndSettle();
      await tester.tap(find.text('cek'));
      await tester.pumpAndSettle();

      expect(find.text(_readyTitle), findsNothing);
    });
  });

  // Konfigurasi ini yang membuat patch sampai ke user, dan tidak ada tes UI
  // yang menyentuhnya: app_id salah = patch tidak pernah ditemukan,
  // auto_update menyala = unduhan diam-diam tanpa banner, dan tanpa
  // shorebird.yaml di assets, updater tidak menemukan app_id sama sekali.
  group('konfigurasi shorebird tiap app', () {
    for (final app in ['bitrack', 'bitrack_internal', 'fixtrack']) {
      test(app, () {
        final yaml = File('../../apps/$app/shorebird.yaml').readAsStringSync();
        final appId = RegExp(
          r'^app_id:\s*(\S+)',
          multiLine: true,
        ).firstMatch(yaml)?.group(1);
        expect(appId, isNotNull, reason: 'app_id wajib ada');
        expect(appId, hasLength(36), reason: 'app_id berbentuk UUID');

        expect(
          RegExp(r'^auto_update:\s*false', multiLine: true).hasMatch(yaml),
          isTrue,
          reason: 'app sendiri yang mengunduh patch (lihat code_push_service)',
        );

        final pubspec = File('../../apps/$app/pubspec.yaml').readAsStringSync();
        expect(
          // Baris aset yang AKTIF, bukan yang dikomentari.
          RegExp(
            r'^\s*- shorebird\.yaml\s*$',
            multiLine: true,
          ).hasMatch(pubspec),
          isTrue,
          reason: 'shorebird.yaml harus ikut jadi aset app',
        );
      });
    }

    test('app_id tiap app berbeda', () {
      final ids = [
        for (final app in ['bitrack', 'bitrack_internal', 'fixtrack'])
          RegExp(r'^app_id:\s*(\S+)', multiLine: true)
              .firstMatch(
                File('../../apps/$app/shorebird.yaml').readAsStringSync(),
              )!
              .group(1),
      ];
      expect(ids.toSet(), hasLength(3));
    });
  });
}
