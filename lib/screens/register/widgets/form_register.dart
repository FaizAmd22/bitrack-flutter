import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/app_input_field.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/register/widgets/register_pending_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Form pendaftaran akun baru. Belum terhubung ke backend pendaftaran yang
/// sesungguhnya — submit hanya mensimulasikan pengiriman lalu menampilkan
/// dialog dummy "pendaftaran sedang dikonfirmasi", supaya alur registrasi
/// sudah terlihat lengkap untuk kebutuhan rilis publik walau proses approval
/// akun masih manual di sisi admin.
class FormRegister extends StatefulWidget {
  const FormRegister({super.key});

  @override
  State<FormRegister> createState() => _FormRegisterState();
}

class _FormRegisterState extends State<FormRegister> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyNameController = TextEditingController();

  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
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

  String? _phoneValidator(AppLocalizations translate, String? v) {
    final phone = (v ?? '').trim();
    if (phone.isEmpty) return translate.fieldRequired(translate.registerPhone);
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      return translate.registerPhoneInvalid;
    }
    return null;
  }

  Future<void> _handleSubmit(AppLocalizations translate) async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _submitting = true);
    // Simulasi pengiriman ke server — belum ada endpoint pendaftaran nyata.
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _submitting = false);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RegisterPendingDialog(
        title: translate.registerPendingTitle,
        desc: translate.registerPendingDesc,
        textOk: translate.registerPendingOkBtn,
        funcOk: () {
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final translate = AppLocalizations.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppInputField(
            label: translate.registerFullName,
            placeholder: translate.registerFullNamePlaceholder,
            controller: _nameController,
            prefixIcon: Icons.person_outline,
            prefixIconColor: AppStyles.primaryColor,
            validator: (v) =>
                _required(translate, translate.registerFullName, v),
          ),
          const SizedBox(height: 15),
          AppInputField(
            label: translate.email,
            placeholder: translate.emailPlaceholder,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            prefixIconColor: AppStyles.primaryColor,
            validator: (v) => _emailValidator(translate, v),
          ),
          const SizedBox(height: 15),
          AppInputField(
            label: translate.registerPhone,
            placeholder: translate.registerPhonePlaceholder,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icons.phone_outlined,
            prefixIconColor: AppStyles.primaryColor,
            validator: (v) => _phoneValidator(translate, v),
          ),
          const SizedBox(height: 15),
          AppInputField(
            label: translate.registerCompanyName,
            placeholder: translate.registerCompanyNamePlaceholder,
            controller: _companyNameController,
            prefixIcon: Icons.business_outlined,
            prefixIconColor: AppStyles.primaryColor,
          ),

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
              onPressed: _submitting
                  ? null
                  : () async {
                      await _handleSubmit(translate);
                    },
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      translate.registerSubmitBtn,
                      style: AppStyles.textSmBold.copyWith(
                        color: AppStyles.whiteColor,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
