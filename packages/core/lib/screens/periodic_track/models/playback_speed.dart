/// Kecepatan putar ulang Periodic Track.
///
/// Sebelumnya daftar durasinya (200–2000 ms per segmen) ditulis dua kali — di
/// layar dan di PeriodicMap — dan hanya dirujuk lewat indeks, sehingga
/// mengubah salah satunya diam-diam membuat keduanya tidak sinkron. Satu
/// sumber di sini mencegah itu.
enum PlaybackSpeed {
  x05(0.5),
  x075(0.75),
  x1(1),
  x2(2),
  x4(4),
  x8(8),
  x16(16);

  const PlaybackSpeed(this.multiplier);

  final double multiplier;

  /// Durasi animasi per segmen (antar dua titik) pada 1x. Sama dengan default
  /// sebelumnya, jadi pemutaran awal terasa persis seperti dulu.
  static const int baseSegmentMs = 1000;

  int get segmentDurationMs => (baseSegmentMs / multiplier).round();

  /// "0.5x", "1x", "2x", "4x".
  String get label {
    final whole = multiplier == multiplier.truncateToDouble();
    return whole ? '${multiplier.toInt()}x' : '${multiplier}x';
  }
}
