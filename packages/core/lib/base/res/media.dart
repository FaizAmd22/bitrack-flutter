/// Path semua asset gambar/icon yang dipakai kode.
///
/// File-nya ada di `apps/<app>/assets/` masing-masing app (isinya identik,
/// kecuali logo), jadi mengganti gambar satu app cukup mengganti file di
/// folder app itu tanpa mengubah path di sini.
class AppMedia {
  static const _baseImage = "assets/images";
  static const _baseLogo = "assets/logos";
  static const _baseIcon = "assets/icons";
  static const _baseTruck = "assets/images/trucks";

  /// Logo di splash dan halaman login. Launcher icon memakai `logo.png`
  /// (lihat `flutter_icons` di pubspec app), bukan file ini.
  static const logo = '$_baseLogo/logo_1.png';

  static const bgLogin = '$_baseImage/splashscreen.png';
  static const userImage = '$_baseImage/user.png';

  static const routeRegulerIcon = '$_baseIcon/route-regular.svg';
  static const routeFilledIcon = '$_baseIcon/route-filled.svg';
  static const truckRegulerIcon = '$_baseIcon/truck-regular.svg';
  static const truckFilledIcon = '$_baseIcon/truck-filled.svg';
  static const workOrderRegulerIcon = '$_baseIcon/work-order-regular.svg';
  static const workOrderFilledIcon = '$_baseIcon/work-order-filled.svg';
  static const filterIcon = '$_baseIcon/filter.svg';
  static const searchIcon = '$_baseIcon/search.svg';
  static const alertIcon = '$_baseIcon/alert.svg';

  // Marker kendaraan di peta, per status aktivitas (lihat resolveTruckAsset).
  static const truckMoving = '$_baseTruck/truck_moving.png';
  static const truckStop = '$_baseTruck/truck_stop.png';
  static const truckIdle = '$_baseTruck/truck_idle.png';
  static const truckSilence = '$_baseTruck/truck_silence.png';
  static const truckDefault = '$_baseTruck/truck_default.png';

  // static const truckSilence = '$_baseTruck/b_log_silence.png';
}
