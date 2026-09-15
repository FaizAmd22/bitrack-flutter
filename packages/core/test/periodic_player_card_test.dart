// Kontrol pemutar Periodic Track: tombol ⏮/⏭ pindah ke titik sebelum/
// sesudah (dulu ⏪/⏩ mengubah kecepatan), plus pilihan kecepatan tersendiri.
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/periodic_track/models/playback_speed.dart';
import 'package:bitrack_core/screens/periodic_track/widgets/player_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Center(child: SizedBox(width: 360, child: child)),
  ),
);

PlayerCard _card({
  bool canPrev = true,
  bool canNext = true,
  VoidCallback? onPrev,
  VoidCallback? onNext,
  PlaybackSpeed speed = PlaybackSpeed.x1,
  ValueChanged<PlaybackSpeed>? onSpeedChanged,
  String? valueLabel,
}) => PlayerCard(
  isPlaying: false,
  canPrev: canPrev,
  canNext: canNext,
  onPrev: onPrev ?? () {},
  onNext: onNext ?? () {},
  onPlayPause: () {},
  speed: speed,
  onSpeedChanged: onSpeedChanged ?? (_) {},
  value: 3,
  max: 10,
  onChanged: (_) {},
  valueLabel: valueLabel,
);

IconButton _buttonWith(WidgetTester tester, IconData icon) =>
    tester.widget<IconButton>(
      find.ancestor(of: find.byIcon(icon), matching: find.byType(IconButton)),
    );

void main() {
  group('PlaybackSpeed', () {
    test('1x sama dengan default lama: 1000 ms per segmen', () {
      expect(PlaybackSpeed.x1.segmentDurationMs, 1000);
    });

    test('makin cepat, makin pendek durasi tiap segmen', () {
      expect(PlaybackSpeed.x05.segmentDurationMs, 2000);
      expect(PlaybackSpeed.x2.segmentDurationMs, 500);
      expect(PlaybackSpeed.x4.segmentDurationMs, 250);
      expect(PlaybackSpeed.x075.segmentDurationMs, 1333);
      expect(PlaybackSpeed.x8.segmentDurationMs, 125);
      // 1000 / 16 = 62,5 ms, dibulatkan ke atas.
      expect(PlaybackSpeed.x16.segmentDurationMs, 63);
    });

    test('label', () {
      expect(PlaybackSpeed.values.map((s) => s.label), [
        '0.5x',
        '0.75x',
        '1x',
        '2x',
        '4x',
        '8x',
        '16x',
      ]);
    });
  });

  testWidgets('⏭ memanggil onNext dan ⏮ memanggil onPrev', (tester) async {
    var next = 0;
    var prev = 0;
    await tester.pumpWidget(
      _host(_card(onNext: () => next++, onPrev: () => prev++)),
    );

    await tester.tap(find.byIcon(Icons.skip_next_rounded));
    await tester.tap(find.byIcon(Icons.skip_previous_rounded));

    expect(next, 1);
    expect(prev, 1);

    // Tombol lama yang mengubah kecepatan sudah tidak ada.
    expect(find.byIcon(Icons.fast_forward_rounded), findsNothing);
    expect(find.byIcon(Icons.fast_rewind_rounded), findsNothing);
  });

  testWidgets('di titik pertama/terakhir tombolnya nonaktif', (tester) async {
    var next = 0;
    var prev = 0;
    await tester.pumpWidget(
      _host(
        _card(
          canPrev: false,
          canNext: false,
          onNext: () => next++,
          onPrev: () => prev++,
        ),
      ),
    );

    expect(_buttonWith(tester, Icons.skip_previous_rounded).onPressed, isNull);
    expect(_buttonWith(tester, Icons.skip_next_rounded).onPressed, isNull);

    await tester.tap(find.byIcon(Icons.skip_next_rounded));
    await tester.tap(find.byIcon(Icons.skip_previous_rounded));
    expect(next, 0);
    expect(prev, 0);
  });

  testWidgets(
    'pilihan kecepatan: menampilkan yang aktif dan mengirim pilihan',
    (tester) async {
      PlaybackSpeed? picked;
      await tester.pumpWidget(_host(_card(onSpeedChanged: (s) => picked = s)));

      expect(find.text('1x'), findsOneWidget);

      await tester.tap(find.text('1x'));
      await tester.pumpAndSettle();

      // Semua pilihan tampil di menu.
      for (final s in PlaybackSpeed.values) {
        expect(find.text(s.label), findsWidgets);
      }

      await tester.tap(find.text('2x').last);
      await tester.pumpAndSettle();

      expect(picked, PlaybackSpeed.x2);
    },
  );

  testWidgets(
    'label slider memakai teks yang diberikan dan tampil saat digeser',
    (tester) async {
      await tester.pumpWidget(
        _host(_card(valueLabel: '2026-09-07 10:19:51 WIB')),
      );

      final slider = tester.widget<Slider>(find.byType(Slider));
      expect(slider.label, '2026-09-07 10:19:51 WIB');

      // Slider kontinu: tanpa ini Flutter tidak pernah menampilkan labelnya.
      final theme = SliderTheme.of(tester.element(find.byType(Slider)));
      expect(theme.showValueIndicator, ShowValueIndicator.onDrag);
    },
  );

  testWidgets('label ikut berubah mengikuti posisi yang dituju', (
    tester,
  ) async {
    // Meniru layar: onChanged memperbarui indeks, dan label dihitung ulang dari
    // indeks itu.
    const times = ['06:00:00', '06:00:30', '06:01:00', '06:01:30', '06:02:00'];
    var index = 0;

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => PlayerCard(
            isPlaying: false,
            canPrev: true,
            canNext: true,
            onPrev: () {},
            onNext: () {},
            onPlayPause: () {},
            speed: PlaybackSpeed.x1,
            onSpeedChanged: (_) {},
            value: index.toDouble(),
            max: (times.length - 1).toDouble(),
            onChanged: (v) => setState(() => index = v.round()),
            valueLabel: '2026-09-07 ${times[index]} WIB',
          ),
        ),
      ),
    );

    // Tekan dan geser ke ujung kanan.
    final slider = find.byType(Slider);
    final gesture = await tester.startGesture(tester.getCenter(slider));
    await tester.pump();
    await gesture.moveTo(tester.getTopRight(slider) + const Offset(-4, 12));
    await tester.pump();

    expect(index, times.length - 1);
    expect(tester.widget<Slider>(slider).label, '2026-09-07 ${times.last} WIB');

    await gesture.up();
    await tester.pumpAndSettle();
  });
}
