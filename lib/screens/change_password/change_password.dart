// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:ams/base/network/api_client.dart';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/features/auth/providers/auth_providers.dart';
import 'package:ams/features/auth/providers/user_storage_provider.dart';
import 'package:ams/screens/change_password/services/otp_service.dart';
import 'package:ams/screens/change_password/services/update_password_service.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'widgets/otp_box.dart';
import 'widgets/password_field.dart';
import 'widgets/rule_text.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

enum StepView { verify, change }

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  StepView _step = StepView.verify;

  static const int otpLen = 5;
  static const int resendCooldown = 60; // detik

  final List<TextEditingController> _otpCtrls = List.generate(
    otpLen,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpNodes = List.generate(otpLen, (_) => FocusNode());

  String? _otpError;

  Timer? _resendTimer;
  int _resendSeconds = 0;

  bool _sending = false; // sedang kirim/resend OTP
  bool _verifying = false; // sedang verifikasi OTP

  final _newPassCtrl = TextEditingController();
  final _rePassCtrl = TextEditingController();
  bool _showNewPass = false;
  bool _showRePass = false;

  bool _ruleMin8 = false;
  bool _ruleUpper = false;
  bool _ruleNumber = false;
  bool _ruleSymbol = false;

  String? _passError;
  bool _updating = false; // sedang submit password baru ke backend

  final _updatePasswordService = const UpdatePasswordService();

  @override
  void initState() {
    super.initState();
    _newPassCtrl.addListener(_evalPasswordRules);
    // Kirim OTP otomatis begitu layar terbuka (setelah frame pertama,
    // supaya context & provider sudah siap).
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
  }

  @override
  void dispose() {
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final n in _otpNodes) {
      n.dispose();
    }
    _newPassCtrl.dispose();
    _rePassCtrl.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCountdown(int seconds) {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = seconds);

    if (seconds <= 0) return;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_resendSeconds <= 1) {
        t.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds -= 1);
      }
    });
  }

  String _otpValue() => _otpCtrls.map((e) => e.text).join();

  void _clearOtp() {
    for (final c in _otpCtrls) {
      c.clear();
    }
    _otpNodes.first.requestFocus();
  }

  // ── Kirim / Resend OTP ─────────────────────────────────────────────────────
  Future<void> _sendOtp({bool resend = false}) async {
    if (_sending) return;
    final t = AppLocalizations.of(context);

    setState(() {
      _sending = true;
      _otpError = null;
    });

    try {
      final email = await ref.read(userEmailProvider.future);
      if (email.isEmpty) {
        if (!mounted) return;
        // TODO: ganti dengan key lokalisasi yang sesuai jika tersedia.
        setState(() => _otpError = 'Email tidak ditemukan.');
        return;
      }

      final result = await ref.read(otpApiProvider).sendOtp(email);
      if (!mounted) return;

      if (result.ok) {
        _startResendCountdown(resendCooldown);
        if (resend) {
          _clearOtp();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.otpCodeResentDummy)));
        }
      } else if (result.cooldown) {
        // Backend masih cooldown → mulai hitung mundur lokal.
        _startResendCountdown(resendCooldown);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.reason ?? 'Tunggu sebelum minta OTP lagi.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.reason ?? 'Gagal mengirim OTP.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      // Timeout / connection refused / dll.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim OTP. Periksa koneksi.')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _onOtpChanged(int index, String v) {
    setState(() => _otpError = null);

    if (v.length > 1) {
      _otpCtrls[index].text = v.substring(v.length - 1);
      _otpCtrls[index].selection = TextSelection.fromPosition(
        TextPosition(offset: _otpCtrls[index].text.length),
      );
    }

    if (_otpCtrls[index].text.isNotEmpty) {
      if (index < otpLen - 1) {
        _otpNodes[index + 1].requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
    }
  }

  void _onOtpBackspace(int index) {
    if (_otpCtrls[index].text.isNotEmpty) {
      _otpCtrls[index].clear();
      setState(() {});
      return;
    }
    if (index > 0) {
      _otpNodes[index - 1].requestFocus();
      _otpCtrls[index - 1].selection = TextSelection.fromPosition(
        TextPosition(offset: _otpCtrls[index - 1].text.length),
      );
    }
  }

  // ── Verifikasi OTP ke backend ──────────────────────────────────────────────
  Future<void> _submitOtp() async {
    final t = AppLocalizations.of(context);

    final code = _otpValue();
    if (code.length < otpLen) {
      setState(() => _otpError = t.otpEnter5Digits);
      return;
    }

    setState(() {
      _verifying = true;
      _otpError = null;
    });

    try {
      final email = await ref.read(userEmailProvider.future);
      final result = await ref.read(otpApiProvider).verifyOtp(email, code);
      if (!mounted) return;

      if (result.ok) {
        setState(() => _step = StepView.change);
      } else {
        setState(() => _otpError = result.reason ?? t.otpInvalidTryAgain);
        _clearOtp();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _otpError = t.otpInvalidTryAgain);
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  void _evalPasswordRules() {
    final p = _newPassCtrl.text;

    final hasMin8 = p.length >= 8;
    final hasUpper = RegExp(r"[A-Z]").hasMatch(p);
    final hasNumber = RegExp(r"[0-9]").hasMatch(p);
    final hasSymbol = RegExp(r'[^a-zA-Z0-9]').hasMatch(p);

    setState(() {
      _ruleMin8 = hasMin8;
      _ruleUpper = hasUpper;
      _ruleNumber = hasNumber;
      _ruleSymbol = hasSymbol;
      _passError = null;
    });
  }

  Future<void> _submitNewPassword() async {
    final t = AppLocalizations.of(context);

    final newP = _newPassCtrl.text.trim();
    final reP = _rePassCtrl.text.trim();

    if (newP.isEmpty || reP.isEmpty) {
      setState(() => _passError = t.passwordFillAllFields);
      return;
    }

    if (!_ruleMin8 || !_ruleUpper || !_ruleNumber || !_ruleSymbol) {
      setState(() => _passError = t.passwordNotMeetRequirements);
      return;
    }

    if (newP != reP) {
      setState(() => _passError = t.passwordNotMatch);
      return;
    }

    const storage = FlutterSecureStorage();
    final userId = await storage.read(key: 'user_id') ?? '';
    if (userId.isEmpty) {
      setState(() => _passError = t.passwordUpdateFailed);
      return;
    }

    setState(() {
      _updating = true;
      _passError = null;
    });

    try {
      final result = await _updatePasswordService.updatePassword(
        id: userId,
        password: newP,
      );
      if (!mounted) return;

      if (!result.success) {
        setState(() {
          _updating = false;
          _passError = result.errorMsg ?? t.passwordUpdateFailed;
        });
        return;
      }

      setState(() => _updating = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.passwordUpdatedDummy)));

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      // biometric_password lama sudah tidak valid begitu password berganti;
      // hapus dulu sebelum logout supaya tidak ada percobaan biometric login
      // yang diam-diam gagal pakai password basi.
      await ref.read(authControllerProvider.notifier).clearBiometricCredential();

      // Samakan dengan logout supaya tidak ada token/cache lama yang
      // nyangkut. Pakai ApiClient.logout() (bukan deleteAll()) supaya kalau
      // ada data lain yang sengaja dipertahankan di masa depan, ini tetap
      // konsisten dengan jalur logout biasa.
      await ApiClient.logout();
    } on DioException catch (e) {
      if (!mounted) return;
      final data = e.response?.data;
      final msg = data is Map
          ? (data['message'] ?? data['error_msg'])?.toString()
          : null;
      setState(() {
        _updating = false;
        _passError = msg ?? t.passwordUpdateFailed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _updating = false;
        _passError = t.passwordUpdateFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final emailAsync = ref.watch(userEmailProvider);

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        surfaceTintColor: AppStyles.bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            if (_step == StepView.change) {
              setState(() => _step = StepView.verify);
              return;
            }
            Navigator.pop(context);
          },
        ),
        title: Text(t.profileChangePassword, style: AppStyles.textLBold),
      ),
      body: SafeArea(
        top: false,
        child: _step == StepView.verify
            ? _buildVerifyView(emailAsync)
            : _buildChangeView(),
      ),
      bottomNavigationBar: _step == StepView.change
          ? _buildBottomButton()
          : null,
    );
  }

  Widget _buildVerifyView(AsyncValue<String> emailAsync) {
    final t = AppLocalizations.of(context);

    final emailText = emailAsync.when(
      data: (email) => email.isNotEmpty ? email : '-',
      loading: () => '...',
      error: (_, __) => '-',
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        children: [
          const SizedBox(height: 24),

          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFF7D6D6),
              borderRadius: BorderRadius.circular(44),
            ),
            child: const Center(
              child: Icon(
                Icons.mail_outline,
                size: 34,
                color: Color(0xFFD64545),
              ),
            ),
          ),

          const SizedBox(height: 18),
          Text(
            t.otpEnterVerificationCodeTitle,
            style: AppStyles.textLBold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            t.otpSentToEmail(emailText),
            style: AppStyles.textMd,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(otpLen, (i) {
              return TxOtpBox(
                controller: _otpCtrls[i],
                focusNode: _otpNodes[i],
                autoFocus: i == 0,
                onChanged: (v) => _onOtpChanged(i, v),
                onBackspace: () => _onOtpBackspace(i),
              );
            }),
          ),

          const SizedBox(height: 12),

          if (_otpError != null) ...[
            Text(
              _otpError!,
              style: AppStyles.textMd.copyWith(color: AppStyles.redColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
          ],

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.otpNotReceivedEmailPrefix,
                style: AppStyles.textMd.copyWith(color: Colors.black54),
              ),
              GestureDetector(
                onTap: (_resendSeconds > 0 || _sending)
                    ? null
                    : () => _sendOtp(resend: true),
                child: Text(
                  _resendSeconds > 0
                      ? t.otpTryAgainCountdown(_resendSeconds)
                      : t.otpTryAgain,
                  style: AppStyles.textMd.copyWith(
                    color: (_resendSeconds > 0 || _sending)
                        ? Colors.black38
                        : AppStyles.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _verifying ? null : _submitOtp,
              child: _verifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(t.otpVerifyCodeBtn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeView() {
    final t = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.passwordNewTitle,
            style: AppStyles.textMd.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TxPasswordField(
            controller: _newPassCtrl,
            hint: t.passwordNewHint,
            obscure: !_showNewPass,
            onToggle: () => setState(() => _showNewPass = !_showNewPass),
          ),

          const SizedBox(height: 10),
          RuleText(t.passwordRuleMin8, ok: _ruleMin8),
          RuleText(t.passwordRuleUpper, ok: _ruleUpper),
          RuleText(t.passwordRuleNumber, ok: _ruleNumber),
          RuleText(t.passwordRuleSymbol, ok: _ruleSymbol),

          const SizedBox(height: 16),

          Text(
            t.passwordReEnterTitle,
            style: AppStyles.textMd.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TxPasswordField(
            controller: _rePassCtrl,
            hint: t.passwordReEnterHint,
            obscure: !_showRePass,
            onToggle: () => setState(() => _showRePass = !_showRePass),
          ),

          const SizedBox(height: 10),

          if (_passError != null) ...[
            Text(
              _passError!,
              style: AppStyles.textMd.copyWith(color: AppStyles.redColor),
            ),
            const SizedBox(height: 8),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final t = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppStyles.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _updating ? null : _submitNewPassword,
            child: _updating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(t.passwordChangeSaveBtn),
          ),
        ),
      ),
    );
  }
}
