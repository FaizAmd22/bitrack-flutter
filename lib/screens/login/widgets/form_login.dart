import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/routes/app_routes.dart';
import 'package:ams/base/widgets/app_input_field.dart';
import 'package:ams/base/widgets/confirm_dialog.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/login/widgets/biometric_button.dart';
import 'package:ams/screens/notification/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ams/features/auth/providers/auth_providers.dart';
import 'package:ams/features/app_config/providers/app_config_providers.dart';
import 'package:ams/features/monitoring/providers/monitoring_providers.dart';

class FormLogin extends ConsumerStatefulWidget {
  const FormLogin({super.key});

  @override
  ConsumerState<FormLogin> createState() => _FormLoginState();
}

class _FormLoginState extends ConsumerState<FormLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  bool _showPassword = false;
  bool _showBiometricButton = false;
  BiometricType? _biometricType;

  @override
  void initState() {
    super.initState();
    _initBiometricFlag();
    _detectBiometricType();
  }

  Future<void> _initBiometricFlag() async {
    final controller = ref.read(authControllerProvider.notifier);
    final creds = await controller.readBiometricCredential();
    final hasCreds =
        (creds['email'] ?? '').isNotEmpty &&
        (creds['password'] ?? '').isNotEmpty;

    if (!mounted) return;
    if (_showBiometricButton != hasCreds) {
      setState(() => _showBiometricButton = hasCreds);
    }
  }

  Future<void> _detectBiometricType() async {
    try {
      final available = await LocalAuthentication().getAvailableBiometrics();
      if (!mounted) return;
      BiometricType? detected;
      if (available.contains(BiometricType.face)) {
        detected = BiometricType.face;
      } else if (available.contains(BiometricType.fingerprint)) {
        detected = BiometricType.fingerprint;
      } else if (available.isNotEmpty) {
        detected = available.first;
      }
      if (_biometricType != detected) {
        setState(() => _biometricType = detected);
      }
    } catch (_) {}
  }

  String _biometricTitle(AppLocalizations t) {
    if (_biometricType == BiometricType.face) return t.addFaceId;
    if (_biometricType == BiometricType.fingerprint) return t.addFingerprint;
    return t.addBiometric;
  }

  String _biometricDesc(AppLocalizations t) {
    if (_biometricType == BiometricType.face) return t.addFaceIdDesc;
    if (_biometricType == BiometricType.fingerprint) return t.addFingerprintDesc;
    return t.addBiometricDesc;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _required(AppLocalizations translate, String name, String? v) =>
      (v == null || v.trim().isEmpty) ? translate.fieldRequired(name) : null;

  String? _emailValidator(AppLocalizations translate, String? v) {
    final email = (v ?? '').trim();
    if (email.isEmpty) return translate.emailRequired;
    if (!_emailRegex.hasMatch(email)) return translate.emailInvalid;
    return null;
  }

  Future<void> _goHome() async {
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.homeScreen,
      (_) => false,
    );
  }

  Future<void> _handleLogin(AppLocalizations translate) async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final controller = ref.read(authControllerProvider.notifier);

    final result = await controller.loginAndPersist(
      email: email,
      password: password,
    );
    if (result == null || !mounted) return;

    ref.invalidate(notificationProvider);
    ref.invalidate(notificationServiceProvider);
    ref.invalidate(monitoringProvider);

    await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: _biometricTitle(translate),
        desc: _biometricDesc(translate),
        textCancel: translate.cancel,
        textSubmit: translate.save,
        funcCancel: () async {
          await controller.clearBiometricCredential();
          if (mounted) setState(() => _showBiometricButton = false);
          await _goHome();
        },
        funcSubmit: () async {
          await controller.saveBiometricCredential(
            email: email,
            password: password,
          );
          if (mounted) setState(() => _showBiometricButton = true);
          await _goHome();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context);

    final isLoading = ref.watch(
      authControllerProvider.select((s) => s.isLoading),
    );
    final errorMessage = ref.watch(
      authControllerProvider.select((s) => s.errorMessage),
    );
    final showRegisterLink = ref.watch(showRegisterLinkProvider).value ?? false;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Center(child: Text(translate.login, style: AppStyles.textLBold)),
          const SizedBox(height: 24),

          AppInputField(
            label: translate.email,
            placeholder: translate.emailPlaceholder,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (v) => _emailValidator(translate, v),
            prefixIconColor: AppStyles.primaryColor,
          ),
          const SizedBox(height: 15),
          AppInputField(
            label: translate.password,
            placeholder: translate.passwordPlaceholder,
            controller: _passwordController,
            prefixIcon: Icons.lock_outline,
            prefixIconColor: AppStyles.primaryColor,
            obscureText: !_showPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
              color: AppStyles.primaryColor,
            ),
            validator: (v) => _required(translate, translate.password, v),
          ),

          if ((errorMessage ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                errorMessage!,
                style: AppStyles.textMdBold.copyWith(
                  color: Colors.red.shade600,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      await _handleLogin(translate);
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      translate.login,
                      style: AppStyles.textSmBold.copyWith(
                        color: AppStyles.whiteColor,
                      ),
                    ),
            ),
          ),

          if (_showBiometricButton) const BiometricButton(),

          if (showRegisterLink) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  translate.registerLinkPrefix,
                  style: AppStyles.textMd.copyWith(color: Colors.black54),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.registerScreen),
                  child: Text(
                    translate.registerLinkAction,
                    style: AppStyles.textMd.copyWith(
                      color: AppStyles.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
