// Teks "mesin terakhir menyala" di halaman detail kendaraan: jam DAN menit,
// dengan susunan kalimat yang wajar di tiap bahasa.
//
// Sebelumnya hanya jam ("16 jam yang lalu"), dan beberapa bahasa memakai
// tanda kurung yang tidak dipakai di bahasa aslinya.
import 'package:bitrack_core/base/localization/locale_controller.dart';
import 'package:bitrack_core/screens/vehicle_detail/utils/format_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Waktu lampau sebagai string seperti yang dikirim API: "2026-09-16 06:40:05".
String _ago({int hours = 0, int minutes = 0}) {
  // 5 detik lebih lampau supaya menitnya tidak ikut berkurang saat tes jalan.
  final t = DateTime.now().subtract(
    Duration(hours: hours, minutes: minutes, seconds: 5),
  );
  String two(int v) => v.toString().padLeft(2, '0');
  return '${t.year}-${two(t.month)}-${two(t.day)} '
      '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
}

void setLocale(String code) {
  LocaleNotifier.current = Locale(code);
  addTearDown(() => LocaleNotifier.current = const Locale('en'));
}

void main() {
  test('jam disertai menitnya', () {
    setLocale('en');
    expect(
      getRelativeTime(_ago(hours: 16, minutes: 24)),
      '16 hours 24 minutes ago',
    );
  });

  test('tepat satu jam: menit nol tidak ikut ditulis', () {
    setLocale('en');
    expect(getRelativeTime(_ago(hours: 2)), '2 hours ago');
  });

  test('bentuk tunggal tetap benar di bahasa Inggris', () {
    setLocale('en');
    expect(getRelativeTime(_ago(hours: 1, minutes: 1)), '1 hour 1 minute ago');
  });

  test('di bawah satu jam tetap seperti semula', () {
    setLocale('en');
    expect(getRelativeTime(_ago(minutes: 24)), '24 minutes ago');
  });

  group('kalimat lengkap per bahasa', () {
    final cases = {
      'en': 'Last Engine On 16 hours 24 minutes ago',
      'id': 'Mesin terakhir menyala 16 jam 24 menit yang lalu',
      'ja': '最後のエンジン始動 16時間24分前',
      // Di Korea keterangan waktu mendahului peristiwanya.
      'ko': '16시간 24분 전 엔진 마지막 가동',
      'zh': '最后一次引擎启动 16小时24分钟前',
    };

    cases.forEach((code, expected) {
      test(code, () {
        setLocale(code);
        final t = currentL10n();
        expect(
          t.engineLastOn(getRelativeTime(_ago(hours: 16, minutes: 24))),
          expected,
        );
      });
    });
  });
}
