// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/features/auth/providers/user_storage_provider.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final List<TextEditingController> _otpCtrls = List.generate(
    otpLen,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpNodes = List.generate(otpLen, (_) => FocusNode());

  String? _otpError;

  Timer? _resendTimer;
  int _resendSeconds = 0;

  final _newPassCtrl = TextEditingController();
  final _rePassCtrl = TextEditingController();
  bool _showNewPass = false;
  bool _showRePass = false;

  bool _ruleMin8 = false;
  bool _ruleUpper = false;
  bool _ruleNumber = false;
  bool _ruleSymbol = false;

  String? _passError;

  @override
  void initState() {
    super.initState();
    _startResendCountdown(0);
    _newPassCtrl.addListener(_evalPasswordRules);
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

  void _submitOtp() {
    final t = AppLocalizations.of(context);

    final code = _otpValue();
    if (code.length < otpLen) {
      setState(() => _otpError = t.otpEnter5Digits);
      return;
    }

    // dummy
    if (code == "55555") {
      setState(() {
        _otpError = null;
        _step = StepView.change;
      });
      return;
    }

    setState(() => _otpError = t.otpInvalidTryAgain);
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

  void _submitNewPassword() {
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.passwordUpdatedDummy)));
    Navigator.pop(context);
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
                onTap: _resendSeconds > 0
                    ? null
                    : () {
                        _clearOtp();
                        setState(() => _otpError = null);
                        _startResendCountdown(30);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(t.otpCodeResentDummy)),
                        );
                      },
                child: Text(
                  _resendSeconds > 0
                      ? t.otpTryAgainCountdown(_resendSeconds)
                      : t.otpTryAgain,
                  style: AppStyles.textMd.copyWith(
                    color: _resendSeconds > 0
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
              onPressed: _submitOtp,
              child: Text(t.otpVerifyCodeBtn),
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
            onPressed: _submitNewPassword,
            child: Text(t.passwordChangeSaveBtn),
          ),
        ),
      ),
    );
  }
}
