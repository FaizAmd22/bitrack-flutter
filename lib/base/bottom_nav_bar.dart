// ignore_for_file: unused_element, deprecated_member_use

import 'package:bitrack_mobile_flutter/base/res/media.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/l10n/app_localizations.dart';
import 'package:bitrack_mobile_flutter/screens/home/home_screen.dart';
import 'package:bitrack_mobile_flutter/screens/profile/profile.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle/vehicle.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context);

    final screens = [
      HomeScreen(isActive: _selectedIndex == 0),
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
              ),
              label: translate.navTracker,
            ),
            // BottomNavigationBarItem(
            //   icon: _BadgeIcon(
            //     icon: FluentSystemIcons.ic_fluent_alert_regular,
            //     count: alertCount,
            //   ),
            //   activeIcon: _BadgeIcon(
            //     icon: FluentSystemIcons.ic_fluent_alert_filled,
            //     count: alertCount,
            //   ),
            //   label: "Alert",
            // ),
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
              ),
              label: translate.navVehicle,
            ),
            BottomNavigationBarItem(
              icon: Icon(FluentSystemIcons.ic_fluent_person_regular),
              activeIcon: Icon(FluentSystemIcons.ic_fluent_person_filled),
              label: translate.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final int count;
  const _BadgeIcon({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            top: -10,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppStyles.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppStyles.bottomNavbarColor,
                  width: 2,
                ),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: AppStyles.textXsBold.copyWith(
                  color: AppStyles.whiteColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
