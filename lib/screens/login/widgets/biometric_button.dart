// ignore_for_file: unused_element, deprecated_member_use

import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/routes/app_routes.dart';
import 'package:ams/features/auth/providers/auth_providers.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/notification/providers/notification_provider.dart';
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

    final t = AppLocalizations.of(context);

    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();

      if (!canCheck || !supported) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.biometricNotSupported)));
        return;
      }

      final ok = await _localAuth.authenticate(
        localizedReason: t.biometricReason,
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
            content: Text(t.biometricCredNotFound),
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
            t.loginFailedTryAgain;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppStyles.redColor),
        );
        return;
      }

      ref.invalidate(notificationProvider);
      ref.invalidate(notificationServiceProvider);

      Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.errorPrefix(msg)),
          backgroundColor: AppStyles.redColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

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
              t.biometricLoginLabel,
              style: AppStyles.textMdBold.copyWith(
                color: AppStyles.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
