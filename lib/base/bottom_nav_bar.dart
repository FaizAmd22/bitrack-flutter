// ignore_for_file: unused_element, deprecated_member_use

import 'package:bitrack_mobile_flutter/base/res/media.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/screens/home/home_screen.dart';
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

  final int alertCount = 3;

  late final List<Widget> _screens = const [
    HomeScreen(),
    // Center(child: Text("Notification")),
    Center(child: Text("Vehicle")),
    Center(child: Text("Profile")),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: SizedBox(
        height: 82,
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
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
              label: "Tracker",
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
              label: "Vehicle",
            ),
            const BottomNavigationBarItem(
              icon: Icon(FluentSystemIcons.ic_fluent_person_regular),
              activeIcon: Icon(FluentSystemIcons.ic_fluent_person_filled),
              label: "Profile",
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
