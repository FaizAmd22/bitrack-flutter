import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/routes/app_routes.dart';
import 'package:ams/base/widgets/app_input_field.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/vehicle/services/check_license_plate.dart';
import 'package:ams/screens/vehicle_detail/models/add_vehicle_args.dart';
import 'package:flutter/material.dart';

class AddVehicleSheet {
  static Future<bool?> open(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyles.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => const _AddVehicleBody(),
    );
  }
}

class _AddVehicleBody extends StatefulWidget {
  const _AddVehicleBody();

  @override
  State<_AddVehicleBody> createState() => _AddVehicleBodyState();
}

class _AddVehicleBodyState extends State<_AddVehicleBody> {
  final _controller = TextEditingController();
  final _service = const CheckLicensePlateService();

  String? _error;
  bool _isChecking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final t = AppLocalizations.of(context);
    final raw = _controller.text.trim();

    if (raw.isEmpty) {
      setState(() => _error = t.addVehicleRequiredError);
      return;
    }

    final valueForApi = raw;

    setState(() {
      _isChecking = true;
      _error = null;
    });

    try {
      final exists = await _service.isPlateExists(valueForApi);

      if (!mounted) return;

      if (exists) {
        setState(() {
          _isChecking = false;
          _error = t.addVehiclePlateExistsError;
        });
        return;
      }

      // Plat belum ada → push screen, tunggu hasil, baru tutup sheet
      final created = await Navigator.pushNamed<dynamic>(
        context,
        AppRoutes.addVehicleScreen,
        arguments: AddVehicleArgs(
          status: AddVehicleStatus.create,
          license: valueForApi,
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, created == true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isChecking = false;
        _error = t.addVehicleCheckFailedError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppStyles.borderLightGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t.addVehicleTitle, style: AppStyles.textLBold),
                  const SizedBox(height: 24),
                  AppInputField(
                    label: t.addVehicleIdentifierTitle,
                    placeholder: t.addVehicleIdentifierPlaceholder,
                    controller: _controller,
                    enabled: !_isChecking,
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: AppStyles.redColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _error!,
                            style: AppStyles.textSm.copyWith(
                              color: AppStyles.redColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isChecking ? null : _onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isChecking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              t.addVehicleContinue,
                              style: AppStyles.textSmBold.copyWith(
                                color: AppStyles.whiteColor,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
