import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/base/routes/app_routes.dart';
import 'package:bitrack_mobile_flutter/features/auth/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricButton extends ConsumerStatefulWidget {
  const BiometricButton({super.key});

  @override
  ConsumerState<BiometricButton> createState() => _BiometricButtonState();
}

class _BiometricButtonState extends ConsumerState<BiometricButton> {
  static const _storage = FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  bool _isLoading = false;
  String _savedEmail = '';
  String _savedPassword = '';

  @override
  void initState() {
    super.initState();
    _loadCreds();
  }

  Future<void> _loadCreds() async {
    final r = await Future.wait([
      _storage.read(key: 'biometric_email'),
      _storage.read(key: 'biometric_password'),
    ]);
    if (!mounted) return;
    _savedEmail = (r[0] ?? '').trim();
    _savedPassword = (r[1] ?? '').trim();
  }

  Future<void> _handleBiometricLogin() async {
    if (_isLoading) return;

    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();

      if (!canCheck || !supported) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perangkat tidak mendukung biometric login'),
          ),
        );
        return;
      }

      final ok = await _localAuth.authenticate(
        localizedReason: 'Gunakan biometrik untuk login',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!ok) return;

      if (_savedEmail.isEmpty || _savedPassword.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data login biometric tidak ditemukan'),
            backgroundColor: AppStyles.redColor,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final controller = ref.read(authControllerProvider.notifier);
      final result = await controller.loginAndPersist(
        email: _savedEmail,
        password: _savedPassword,
      );

      if (!mounted) return;

      if (result == null) {
        final err =
            ref.read(authControllerProvider).errorMessage ??
            'Login gagal, coba lagi';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppStyles.redColor),
        );
        return;
      }

      Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', 'Terjadi error: '),
          ),
          backgroundColor: AppStyles.redColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isLoading ? null : _handleBiometricLogin,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Icon(Icons.fingerprint, size: 40, color: AppStyles.primaryColor),
          const SizedBox(height: 8),
          if (_isLoading)
            const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text(
              "Login Using Biometric Method",
              style: AppStyles.textMdBold.copyWith(
                color: AppStyles.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
