// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:bitrack_core/base/network/api_client.dart';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/routes/app_routes.dart';
import 'package:bitrack_core/base/widgets/app_version_label.dart';
import 'package:bitrack_core/base/widgets/confirm_dialog.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tab Profil: avatar inisial, nama dan role user, menu ke Ganti Password /
/// Pengaturan Notifikasi / Bahasa, tombol Sign Out, dan label versi + nomor
/// patch di bagian bawah.
///
/// Nama dan role dibaca dari secure storage (disimpan saat login), bukan dari
/// API.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _loadingUser = true;
  String _name = '-';
  String _role = '-';

  /// Hash sederhana yang selalu sama untuk teks yang sama (beda dengan
  /// `String.hashCode` yang tidak dijamin stabil antar-proses), supaya warna
  /// avatar user tidak berganti tiap app dibuka.
  int _stableHash(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  /// Warna avatar acak tapi tetap per nama. Nilai RGB dibatasi 0-199 supaya
  /// cukup gelap untuk teks putih.
  Color get _avatarColor {
    final random = Random(_stableHash(_name));
    return Color.fromARGB(
      255,
      random.nextInt(200),
      random.nextInt(200),
      random.nextInt(200),
    );
  }

  /// Inisial nama: huruf pertama kata pertama + huruf pertama kata terakhir.
  String get _initials {
    final parts = _name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty || parts.first == '-') return '-';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final name = (await _storage.read(key: 'user_name'))?.trim();
      final role = (await _storage.read(key: 'user_role'))?.trim();

      if (!mounted) return;
      setState(() {
        _name = (name == null || name.isEmpty) ? '-' : name;
        _role = (role == null || role.isEmpty) ? '-' : role;
        _loadingUser = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _name = '-';
        _role = '-';
        _loadingUser = false;
      });
    }
  }

  /// Konfirmasi lalu logout lewat [ApiClient.logout] (yang juga memindahkan
  /// user ke halaman login).
  Future<void> _signOut(AppLocalizations t) async {
    await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: t.signOutTitle,
        desc: t.signOutDesc,
        textCancel: t.cancel,
        textSubmit: t.logout,
        funcSubmit: () async {
          await ApiClient.logout();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    final menus = [
      _ProfileMenuItem(
        title: t.profileChangePassword,
        route: AppRoutes.changePasswordScreen,
      ),
      _ProfileMenuItem(
        title: t.profileNotificationSetting,
        route: AppRoutes.notificationSettingScreen,
      ),
      _ProfileMenuItem(
        title: t.profileLanguage,
        route: AppRoutes.languageScreen,
      ),
    ];

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: AppStyles.bgColor,
        padding: const EdgeInsets.fromLTRB(10, 80, 10, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60.0,
              backgroundColor: _avatarColor,
              child: Text(
                _initials,
                style: AppStyles.textMdBold.copyWith(
                  color: AppStyles.whiteColor,
                  fontSize: 32,
                ),
              ),
            ),

            const SizedBox(height: 15),

            if (_loadingUser) ...[
              const SizedBox(height: 6),
              const CircularProgressIndicator(strokeWidth: 2),
              const SizedBox(height: 10),
            ] else ...[
              Text(_name, style: AppStyles.textMdBold),
              Text(_role, style: AppStyles.textSm),
            ],

            const SizedBox(height: 30),

            Column(
              children: menus.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, item.route);
                    },
                    child: Row(
                      children: [
                        Text(
                          item.title,
                          style: AppStyles.textSm.copyWith(
                            color: AppStyles.blackColor,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppStyles.primaryColor,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            TextButton(
              onPressed: () => _signOut(t),
              child: Row(
                children: [
                  Text(
                    t.signOut,
                    style: AppStyles.textSm.copyWith(
                      color: AppStyles.blackColor,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppStyles.primaryColor,
                  ),
                ],
              ),
            ),

            const Spacer(),

            const AppVersionLabel(),
          ],
        ),
      ),
    );
  }
}

/// Satu baris menu di Profil: teks + route tujuan.
class _ProfileMenuItem {
  final String title;
  final String route;

  const _ProfileMenuItem({required this.title, required this.route});
}
