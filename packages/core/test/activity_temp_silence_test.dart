// Aktivitas kendaraan baru "Temporary Silence": tampil di chip filter, di label
// status (oranye), dikirim ke server dengan kosakata yang benar, dan ada
// wakilnya di data demo.
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/services/demo_data.dart';
import 'package:bitrack_core/features/monitoring/data/monitoring_api.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/home/widgets/activity_chips.dart';
import 'package:bitrack_core/screens/vehicle_detail/widgets/status_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpLabel(
  WidgetTester tester,
  String activity, {
  String locale = 'en',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(locale),
      home: Scaffold(
        body: Center(child: StatusLabel(activity: activity)),
      ),
    ),
  );
}

(Color, Color) labelColors(WidgetTester tester) {
  final text = tester.widget<Text>(
    find.descendant(of: find.byType(StatusLabel), matching: find.byType(Text)),
  );
  final box = tester.widget<Container>(
    find.descendant(
      of: find.byType(StatusLabel),
      matching: find.byType(Container),
    ),
  );
  return (text.style!.color!, (box.decoration! as BoxDecoration).color!);
}

void main() {
  group('label status', () {
    testWidgets('TEMP_SILENCE oranye', (tester) async {
      await pumpLabel(tester, 'TEMP_SILENCE');

      expect(find.text('Temporary Silence'), findsOneWidget);
      final (fg, bg) = labelColors(tester);
      expect(fg, AppStyles.orangeColor);
      expect(bg, AppStyles.bgOrangeColor);
    });

    testWidgets('huruf kecil dan ejaan panjang dari server juga dikenali', (
      tester,
    ) async {
      await pumpLabel(tester, 'temporary_silence');

      expect(find.text('Temporary Silence'), findsOneWidget);
      expect(labelColors(tester).$1, AppStyles.orangeColor);
    });

    testWidgets('SILENCE tetap abu-abu', (tester) async {
      await pumpLabel(tester, 'SILENCE');

      expect(find.text('Silence'), findsOneWidget);
      final (fg, bg) = labelColors(tester);
      expect(fg, AppStyles.darkGrayColor);
      expect(bg, AppStyles.bgGrayColor);
    });

    final perLocale = {
      'id': 'Silence Sementara',
      'ja': '一時無通信',
      'ko': '일시적 신호 없음',
      'zh': '临时静默',
    };
    perLocale.forEach((code, expected) {
      testWidgets('diterjemahkan ke $code', (tester) async {
        await pumpLabel(tester, 'TEMP_SILENCE', locale: code);
        expect(find.text(expected), findsOneWidget);
      });
    });
  });

  group('chip filter', () {
    test('ada di daftar, sebelum Silence', () {
      final options = activityOptions(
        lookupAppLocalizations(const Locale('en')),
      );
      final values = options.map((o) => o.value).toList();

      expect(values, contains('tempSilence'));
      expect(
        values.indexOf('tempSilence'),
        lessThan(values.indexOf('silence')),
      );
    });

    test('labelnya ikut bahasa, bukan teks Inggris tetap', () {
      final ko = activityOptions(lookupAppLocalizations(const Locale('ko')));
      expect(ko.firstWhere((o) => o.value == 'tempSilence').label, '일시적 신호 없음');
    });
  });

  group('kosakata server', () {
    test('parameter query huruf kecil, kunci summary huruf besar', () {
      expect(MonitoringApi.activityParam('tempSilence'), 'temp_silence');
      expect(MonitoringApi.summaryKey('tempSilence'), 'TEMP_SILENCE');
    });
  });

  group('data demo', () {
    test('chip Temporary Silence punya kendaraannya sendiri', () {
      final all = DemoData.monitoringStatusList();
      expect(all['metadata']['summary']['TEMP_SILENCE'], 1);

      final filtered = DemoData.monitoringStatusList(activity: 'temp_silence');
      final data = filtered['data'] as List;
      expect(data, hasLength(1));
      expect(data.single['vehicle_activity'], 'TEMP_SILENCE');
    });
  });
}
