import 'dart:ui' show Size;

/// Identitas brand yang dibaca kode shared di package ini (judul MaterialApp,
/// user agent tile map, ukuran logo splash, dst). Di-set sekali di `main.dart`
/// tiap app sebelum `runApp()`.
///
/// Beda dengan warna primer (lihat [AppStyles.primaryColor]) yang WAJIB
/// compile-time constant karena dipakai di ratusan `const` constructor —
/// nilai-nilai di sini tidak pernah dipakai dalam konteks `const`, jadi cukup
/// static mutable yang di-override saat runtime. Lebih sederhana daripada
/// menambah --dart-define baru untuk tiap string.
class AppBranding {
  AppBranding._();

  /// Judul MaterialApp; juga yang muncul di app switcher Android.
  static String appName = 'FixTrack';

  /// Dikirim sebagai User-Agent saat menarik tile peta. Penyedia tile
  /// (OSM dsb.) memakainya untuk identifikasi, jadi nilainya mengikuti
  /// applicationId/bundle ID tiap app.
  static String mapUserAgentPackageName = 'fixtrack.treffix.id';

  /// Kotak tempat logo digambar di splash screen (lihat screens/splash_screen).
  /// Logo di-scale proporsional sampai muat di dalam kotak ini — diperbesar
  /// maupun diperkecil — jadi ukuran tampilnya TIDAK bergantung pada resolusi
  /// file PNG-nya. Itu yang dimau di sini: assets tiap app diganti manual, dan
  /// mengganti logo dengan PNG beresolusi lain tidak boleh diam-diam mengubah
  /// besar logo di splash.
  ///
  /// Perlu di-set per app karena bentuk logonya beda jauh: logo FixTrack
  /// memanjang (279x54, rasio ~5.2) sedangkan logo Bitrack lebih kotak. Angka
  /// yang pas untuk logo memanjang bikin logo kotak jadi raksasa, dan
  /// sebaliknya.
  ///
  /// Default di bawah = ukuran natural logo FixTrack, jadi tampilan splash
  /// FixTrack persis sama seperti sebelum logo dibatasi kotak ini.
  static Size splashLogoSize = const Size(279, 54);

  static void configure({
    String? appName,
    String? mapUserAgentPackageName,
    Size? splashLogoSize,
  }) {
    if (appName != null) AppBranding.appName = appName;
    if (mapUserAgentPackageName != null) {
      AppBranding.mapUserAgentPackageName = mapUserAgentPackageName;
    }
    if (splashLogoSize != null) {
      AppBranding.splashLogoSize = splashLogoSize;
    }
  }
}
