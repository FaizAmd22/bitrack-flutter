// Regression test untuk "grafik tidak sesuai dengan penggarisnya".
//
// Garis digambar dari data yang dipangkas (setiap titik ke-n), sedangkan
// penggaris dan penanda memakai data lengkap — titik yang sama dengan peta.
// Titik aktif sering termasuk yang terbuang, jadi penanda (mis. 30 km/j)
// melayang jauh dari garis (45–55) padahal nilainya benar.
import 'package:bitrack_core/screens/periodic_track/utils/chart_series.dart';
import 'package:flutter_test/flutter_test.dart';

final _t0 = DateTime(2026, 9, 14, 6);

/// Kecepatan yang naik-turun tajam, satu titik tiap 5 detik — mirip data di
/// laporan (0 → 60 → 0 dalam beberapa menit).
List<SeriesPoint> _spiky(int n) => [
  for (var i = 0; i < n; i++)
    SeriesPoint(
      _t0.add(Duration(seconds: 5 * i)),
      i % 7 == 0 ? 64.0 : ((i * 13) % 50).toDouble(),
    ),
];

/// Algoritma lama, disalin apa adanya untuk pembanding.
List<SeriesPoint> _everyNth(List<SeriesPoint> src, int maxPoints) {
  if (src.length <= maxPoints) return src;
  final step = (src.length / maxPoints).ceil();
  final out = <SeriesPoint>[for (var i = 0; i < src.length; i += step) src[i]];
  if (out.last.dt != src.last.dt) out.add(src.last);
  return out;
}

/// Garis selalu melewati titik datanya sendiri, jadi penanda tepat di atas
/// garis kalau titik aktif termasuk salah satu titik yang digambar.
bool _markerOnLine(List<SeriesPoint> rendered, SeriesPoint active) =>
    rendered.contains(active);

void main() {
  test('SEBELUM: pemangkasan lama membuat penanda melayang dari garis', () {
    final full = _spiky(1500);
    final rendered = _everyNth(full, 600);

    final off = full.where((p) => !_markerOnLine(rendered, p)).length;
    expect(off, greaterThan(0), reason: 'mereproduksi bug di screenshot');
  });

  test('SESUDAH: penanda tepat di atas garis untuk SETIAP titik aktif', () {
    final full = _spiky(1500);
    final series = downsampleM4(insertGaps(full), maxPoints: 600);

    for (final p in full) {
      final active = nearestByTime(full, p.dt)!;
      expect(active.value, p.value, reason: 'nilai penanda = nilai di peta');
      expect(
        _markerOnLine(withActivePoint(series, active), active),
        isTrue,
        reason: 'penanda di ${p.dt} harus berada di atas garis',
      );
    }
  });

  test('M4 mempertahankan puncak dan lembah', () {
    final full = _spiky(1500);
    final rendered = downsampleM4(full, maxPoints: 600);

    final values = full.map((p) => p.value!).toList();
    final drawn = rendered.map((p) => p.value!).toList();
    expect(drawn, contains(values.reduce((a, b) => a > b ? a : b)));
    expect(drawn, contains(values.reduce((a, b) => a < b ? a : b)));
    // Jumlah puncak 64 per kolom tidak boleh hilang seperti pada cara lama.
    expect(
      rendered.where((p) => p.value == 64).length,
      greaterThan(_everyNth(full, 600).where((p) => p.value == 64).length),
    );

    expect(rendered.length, lessThanOrEqualTo(600));
    for (var i = 1; i < rendered.length; i++) {
      expect(
        rendered[i].dt.isBefore(rendered[i - 1].dt),
        isFalse,
        reason: 'urutan waktu harus terjaga supaya garis tidak bolak-balik',
      );
    }
  });

  test('di bawah batas, data digambar apa adanya', () {
    final full = _spiky(300);
    expect(identical(downsampleM4(full, maxPoints: 600), full), isTrue);

    final active = full[123];
    expect(identical(withActivePoint(full, active), full), isTrue);
  });

  test('jeda tanpa data tetap terputus setelah dirangkum', () {
    final before = _spiky(800);
    final after = [
      for (final p in _spiky(800))
        SeriesPoint(p.dt.add(const Duration(hours: 2)), p.value),
    ];
    final withGap = insertGaps([...before, ...after]);
    final rendered = downsampleM4(withGap, maxPoints: 600);

    final gapIndex = rendered.indexWhere((p) => p.value == null);
    expect(gapIndex, greaterThan(0), reason: 'titik jeda tidak boleh hilang');
    expect(rendered[gapIndex - 1].dt.isBefore(after.first.dt), isTrue);
    expect(rendered[gapIndex + 1].dt, after.first.dt);
  });

  test('M4 selalu mempertahankan titik yang diminta (alert)', () {
    final full = _spiky(1500);
    // Sengaja titik yang BUKAN ekstrem, supaya tidak ikut terpilih sebagai
    // min/max kelompoknya.
    final alertTimes = {
      for (var i = 5; i < full.length; i += 97)
        if (full[i].value != 64.0 && full[i].value != 0.0) full[i].dt,
    };

    final rendered = downsampleM4(
      full,
      maxPoints: 600,
      keep: (p) => alertTimes.contains(p.dt),
    );

    final drawnTimes = rendered.map((p) => p.dt).toSet();
    expect(drawnTimes.containsAll(alertTimes), isTrue);

    // Tanpa `keep`, sebagian besar titik itu memang terbuang.
    final withoutKeep = downsampleM4(full, maxPoints: 600).map((p) => p.dt);
    expect(alertTimes.difference(withoutKeep.toSet()), isNotEmpty);
  });
}
