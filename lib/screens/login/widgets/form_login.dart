import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/base/routes/app_routes.dart';
import 'package:bitrack_mobile_flutter/base/widgets/app_input_field.dart';
import 'package:bitrack_mobile_flutter/base/widgets/confirm_dialog.dart';
import 'package:bitrack_mobile_flutter/l10n/app_localizations.dart';
import 'package:bitrack_mobile_flutter/screens/login/widgets/biometric_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitrack_mobile_flutter/features/auth/providers/auth_providers.dart';

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

  @override
  void initState() {
    super.initState();
    _initBiometricFlag();
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

    await showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: translate.addFingerprint,
        desc: translate.addFingerprintDesc,
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
        ],
      ),
    );
  }
}
