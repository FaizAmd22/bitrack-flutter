import '../models/periodic_metric.dart';
import '../models/periodic_point.dart';

/// Satu titik pada grafik Periodic Track. [value] null = jeda, supaya garis
/// terputus di rentang yang tidak punya data.
class SeriesPoint {
  const SeriesPoint(this.dt, this.value, [this.source]);

  final DateTime dt;
  final double? value;

  /// Titik data aslinya, dipakai untuk menampilkan detail (waktu, event) saat
  /// titik di grafik ditekan. Null untuk titik jeda. Sengaja tidak ikut dalam
  /// perbandingan kesamaan: dua titik dianggap sama bila posisinya di grafik
  /// sama.
  final PeriodicPoint? source;

  @override
  bool operator ==(Object other) =>
      other is SeriesPoint && other.dt == dt && other.value == value;

  @override
  int get hashCode => Object.hash(dt, value);

  @override
  String toString() => 'SeriesPoint($dt, $value)';
}

/// Titik alert pada seri grafik. Lihat [PeriodicPoint.isAlert].
bool isAlertPoint(SeriesPoint p) => p.source?.isAlert ?? false;

DateTime parseDeviceTime(String s) =>
    DateTime.tryParse(s.replaceFirst(' ', 'T')) ?? DateTime.now();

double valueForMetric(PeriodicPoint p, PeriodicMetric metric) {
  switch (metric) {
    case PeriodicMetric.speed:
      return p.speed;
    case PeriodicMetric.ignition:
      return p.ignition ? 1.0 : 0.0;
    case PeriodicMetric.accu:
      return p.externalPowerVoltage;
    case PeriodicMetric.fuel:
      return p.fuelLevel;
    case PeriodicMetric.temperature:
      return p.dallasTemp1;
  }
}

/// Semua titik, diurutkan menurut waktu.
List<SeriesPoint> normalizeSeries(
  List<PeriodicPoint> raw,
  PeriodicMetric metric,
) {
  final list = [
    for (final p in raw)
      SeriesPoint(parseDeviceTime(p.deviceTime), valueForMetric(p, metric), p),
  ];
  list.sort((a, b) => a.dt.compareTo(b.dt));
  return list;
}

/// Sisipkan titik null di antara dua titik yang berjarak lebih dari [gap],
/// supaya garis tidak menyambung melintasi rentang tanpa data.
List<SeriesPoint> insertGaps(
  List<SeriesPoint> src, {
  Duration gap = const Duration(minutes: 10),
}) {
  if (src.length < 2) return src;

  final out = <SeriesPoint>[src.first];
  for (var i = 1; i < src.length; i++) {
    final prev = src[i - 1];
    final cur = src[i];
    if (cur.dt.difference(prev.dt) > gap) {
      out.add(SeriesPoint(prev.dt.add(const Duration(seconds: 1)), null));
    }
    out.add(cur);
  }
  return out;
}

/// Rangkum seri menjadi paling banyak ±[maxPoints] titik tanpa membuang
/// puncak maupun lembah.
///
/// Versi lama mengambil setiap titik ke-n. Pada data yang naik-turun tajam
/// (kecepatan bisa 0 → 60 → 0 dalam beberapa menit) cara itu membuang titik
/// ekstrem, sehingga bentuk garis menyimpang dari data aslinya dan tidak
/// cocok dengan nilai yang tampil di peta.
///
/// Di sini tiap kelompok titik menyumbang titik pertama, terakhir, minimum,
/// dan maksimumnya (algoritma M4). Selama jumlah kelompok melebihi lebar
/// grafik dalam piksel, hasil gambarnya sama dengan menggambar semua titik.
/// Titik null (jeda) selalu dipertahankan dan tidak pernah dilewati kelompok.
///
/// Titik yang memenuhi [keep] (dipakai untuk alert) selalu ikut digambar,
/// walaupun bukan titik ekstrem di kelompoknya. Tanpa itu alert bisa terbuang,
/// sehingga menekan penandanya di grafik tidak memunculkan nama event-nya.
List<SeriesPoint> downsampleM4(
  List<SeriesPoint> src, {
  required int maxPoints,
  bool Function(SeriesPoint p)? keep,
}) {
  if (src.length <= maxPoints) return src;

  final realCount = src.where((p) => p.value != null).length;
  final buckets = (maxPoints ~/ 4).clamp(1, realCount);
  final bucketSize = (realCount / buckets).ceil();
  if (bucketSize <= 1) return src;

  final out = <SeriesPoint>[];
  var bucket = <SeriesPoint>[];

  void flush() {
    if (bucket.isEmpty) return;
    var lo = bucket.first;
    var hi = bucket.first;
    for (final p in bucket) {
      if (p.value! < lo.value!) lo = p;
      if (p.value! > hi.value!) hi = p;
    }
    final picked = <SeriesPoint>{
      bucket.first,
      lo,
      hi,
      bucket.last,
      if (keep != null) ...bucket.where(keep),
    }.toList()..sort((a, b) => a.dt.compareTo(b.dt));
    out.addAll(picked);
    bucket = <SeriesPoint>[];
  }

  for (final p in src) {
    if (p.value == null) {
      flush();
      out.add(p);
      continue;
    }
    bucket.add(p);
    if (bucket.length >= bucketSize) flush();
  }
  flush();
  return out;
}

/// Titik bernilai yang waktunya paling dekat dengan [t]. [data] harus terurut
/// menurut waktu.
SeriesPoint? nearestByTime(List<SeriesPoint> data, DateTime t) {
  if (data.isEmpty) return null;

  var lo = 0;
  var hi = data.length - 1;
  while (lo < hi) {
    final mid = (lo + hi) >> 1;
    if (data[mid].dt.isBefore(t)) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }

  var best = data[lo];
  if (lo - 1 >= 0 &&
      data[lo - 1].dt.difference(t).abs() < best.dt.difference(t).abs()) {
    best = data[lo - 1];
  }
  if (best.value != null) return best;

  for (var l = lo - 1, r = lo + 1; l >= 0 || r < data.length; l--, r++) {
    if (l >= 0 && data[l].value != null) return data[l];
    if (r < data.length && data[r].value != null) return data[r];
  }
  return best;
}

/// Pastikan [active] menjadi salah satu titik pada seri yang digambar.
///
/// Garis selalu melewati titik-titik datanya sendiri. Kalau titik aktif
/// terbuang oleh [downsampleM4], penanda di grafik akan melayang di atas atau
/// di bawah garis, walaupun nilainya benar dan sama dengan yang tampil di
/// peta. Menyisipkannya kembali menjamin penanda selalu tepat di atas garis,
/// termasuk saat grafik di-zoom.
///
/// Seri yang tidak dirangkum sudah memuat titik aktif, jadi dikembalikan apa
/// adanya tanpa disalin.
List<SeriesPoint> withActivePoint(
  List<SeriesPoint> rendered,
  SeriesPoint? active,
) {
  if (active == null || active.value == null) return rendered;

  var lo = 0;
  var hi = rendered.length;
  while (lo < hi) {
    final mid = (lo + hi) >> 1;
    if (rendered[mid].dt.isBefore(active.dt)) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }

  for (var i = lo; i < rendered.length && rendered[i].dt == active.dt; i++) {
    if (rendered[i].value == active.value) return rendered;
  }

  return [...rendered.sublist(0, lo), active, ...rendered.sublist(lo)];
}
