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
}
