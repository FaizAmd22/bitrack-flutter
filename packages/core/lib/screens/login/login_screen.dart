import 'package:bitrack_core/base/res/media.dart';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/widgets/app_version_label.dart';
import 'package:bitrack_core/screens/login/widgets/form_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Halaman login (route `/login-screen`): latar brand, logo, kartu
/// [FormLogin], dan label versi + nomor patch di bawahnya.
///
/// Dibungkus `GuestGuard` di `main.dart`, jadi user yang sudah login langsung
/// dipindah ke Home.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// True untuk build dev (`VITE_APP_TYPES` berisi "dev"): tampilkan label
  /// DEVELOPMENT di bawah logo supaya build dev tidak tertukar dengan prod.
  bool get _isDevEnv =>
      (dotenv.env['VITE_APP_TYPES'] ?? '').toLowerCase().contains('dev');

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Dibungkus SingleChildScrollView supaya kartu bisa digeser saat keyboard
    // muncul; tingginya dikunci setinggi layar supaya isi tetap di tengah.
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: AppStyles.darkRedColor,
            image: DecorationImage(
              image: AssetImage(AppMedia.bgLogin),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              const Expanded(child: SizedBox()),
              Image.asset(AppMedia.logo, scale: 1.7),
              if (_isDevEnv) ...[
                const SizedBox(height: 4),
                Text(
                  'DEVELOPMENT',
                  style: AppStyles.textSmBold.copyWith(
                    color: AppStyles.whiteColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
              SizedBox(height: 20),
              Container(
                width: size.width * 0.9,
                padding: const EdgeInsets.symmetric(
                  vertical: 35,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppStyles.whiteColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FormLogin(),
              ),
              SizedBox(height: 20),
              const AppVersionLabel(color: AppStyles.whiteColor),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
