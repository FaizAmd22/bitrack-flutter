// ignore_for_file: unused_element, deprecated_member_use

import 'package:ams/base/res/media.dart';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/home/home_screen.dart';
import 'package:ams/screens/notification/notification_screen.dart';
import 'package:ams/screens/notification/providers/notification_provider.dart';
import 'package:ams/screens/profile/profile.dart';
import 'package:ams/screens/vehicle/vehicle.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBar extends ConsumerStatefulWidget {
  const BottomNavBar({super.key});

  @override
  ConsumerState<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> {
  int _selectedIndex = 0;

  final GlobalKey<NotificationScreenState> _notifKey =
      GlobalKey<NotificationScreenState>();

  String _badgeLabel(int count) => count > 99 ? '99+' : '$count';

  Widget _notifBadge(int count, Widget child) {
    return Badge(
      backgroundColor: Colors.transparent, // matikan stadium bawaan
      padding: EdgeInsets.zero,
      isLabelVisible: count > 0,
      label: Container(
        width: 18,
        height: 18, // width == height => lingkaran
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppStyles.primaryColor,
          shape: BoxShape.circle,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown, // "99+" otomatis mengecil biar nggak overflow
          child: Text(
            _badgeLabel(count),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context);
    final notifCount = ref.watch(
      notificationProvider.select((s) => s.list.total),
    );

    final screens = [
      HomeScreen(isActive: _selectedIndex == 0),
      NotificationScreen(key: _notifKey),
      const VehicleScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: Container(
        height: 82,
        decoration: BoxDecoration(
          color: AppStyles.bottomNavbarColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 7,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) {
            if (i == _selectedIndex) return;
            setState(() => _selectedIndex = i);

            // Saat user pindah KE tab notifikasi (index 1), refresh datanya.
            if (i == 1) {
              _notifKey.currentState?.refreshFromOutside();
            }
          },
          selectedItemColor: AppStyles.primaryColor,
          unselectedItemColor: const Color.fromARGB(255, 189, 189, 189),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                AppMedia.routeRegulerIcon,
                width: 23,
                height: 23,
              ),
              activeIcon: SvgPicture.asset(
                AppMedia.routeFilledIcon,
                width: 23,
                height: 23,
                colorFilter: ColorFilter.mode(
                  AppStyles.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              label: translate.navTracker,
            ),
            BottomNavigationBarItem(
              icon: _notifBadge(
                notifCount,
                const Icon(FluentSystemIcons.ic_fluent_alert_regular),
              ),
              activeIcon: _notifBadge(
                notifCount,
                const Icon(FluentSystemIcons.ic_fluent_alert_filled),
              ),
              label: translate.navNotification,
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                AppMedia.truckRegulerIcon,
                width: 24,
                height: 24,
              ),
              activeIcon: SvgPicture.asset(
                AppMedia.truckFilledIcon,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppStyles.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
              label: translate.navVehicle,
            ),
            BottomNavigationBarItem(
              icon: const Icon(FluentSystemIcons.ic_fluent_person_regular),
              activeIcon: const Icon(FluentSystemIcons.ic_fluent_person_filled),
              label: translate.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
