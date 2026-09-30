import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Dipasang di `navigatorObservers` tiap app supaya layar yang tertimbun
  /// route lain tahu kapan dirinya tidak lagi terlihat.
  ///
  /// Sebuah layar yang di-push TIDAK men-dispose layar di bawahnya: State-nya
  /// tetap hidup dan timer-nya tetap menembak. Tanpa observer ini, polling
  /// HomeScreen terus jalan di belakang Vehicle Detail dan ikut membebani
  /// server yang sedang melayani request detail.
  static final RouteObserver<ModalRoute<void>> routeObserver =
      RouteObserver<ModalRoute<void>>();

  /// Nama route yang sedang tampil, diisi [routeTracker]. Dipakai popup
  /// "pembaruan siap" untuk menunggu splash lewat: dialog yang dibuka saat
  /// splash ikut tertutup bersama halamannya (splash pindah dengan
  /// pushNamedAndRemoveUntil), jadi user tidak pernah sempat melihatnya.
  static String? currentRouteName;

  /// Dipasang di `navigatorObservers` tiap app, berdampingan dengan
  /// [routeObserver].
  static final RouteTracker routeTracker = RouteTracker();
}

/// Mencatat nama route teratas ke [NavigationService.currentRouteName].
class RouteTracker extends NavigatorObserver {
  // Hanya route BERNAMA. Dialog, bottom sheet, dan popup lain di-push tanpa
  // nama; tanpa syarat ini, membuka dialog apa pun akan menghapus catatan
  // halaman yang sedang tampil.
  void _set(Route<dynamic>? route) {
    final name = route is ModalRoute ? route.settings.name : null;
    if (name != null) NavigationService.currentRouteName = name;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _set(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _set(previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _set(newRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _set(previousRoute);
}
