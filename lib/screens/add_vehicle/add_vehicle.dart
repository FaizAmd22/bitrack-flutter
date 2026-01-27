// ignore_for_file: deprecated_member_use, use_build_context_synchronously, control_flow_in_finally

import 'package:bitrack_mobile_flutter/base/widgets/confirm_dialog.dart';
import 'package:bitrack_mobile_flutter/base/widgets/full_screen_loading.dart';
import 'package:bitrack_mobile_flutter/screens/add_vehicle/services/fetch_vehicle_by_license.dart';
import 'package:bitrack_mobile_flutter/screens/vehicle_detail/models/add_vehicle_args.dart';
import 'package:flutter/material.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/base/widgets/app_stepper.dart';
import 'package:bitrack_mobile_flutter/screens/add_vehicle/models/add_vehicle_form_data.dart';
import 'package:bitrack_mobile_flutter/screens/add_vehicle/widgets/device_info_step.dart';
import 'package:bitrack_mobile_flutter/screens/add_vehicle/widgets/review_step.dart';
import 'package:bitrack_mobile_flutter/screens/add_vehicle/widgets/vehicle_info_step.dart';
import 'package:bitrack_mobile_flutter/l10n/app_localizations.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  AddVehicleFormData data = AddVehicleFormData();

  final _vehicleFormKey = GlobalKey<FormState>();
  final _deviceFormKey = GlobalKey<FormState>();

  AddVehicleArgs? _args;

  bool _loadingVehicle = false;
  String _initKey = 'create';
  bool _vehicleStepReady = false;
  bool get _pageLoading => _loadingVehicle || !_vehicleStepReady;

  final VehicleApi _vehicleApi = const VehicleApi();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is AddVehicleArgs) {
      if (_args == null) {
        _args = args;
        _bootstrap();
      }
    } else {
      _args ??= const AddVehicleArgs(status: AddVehicleStatus.create);
      if (_initKey == 'create') {
        _bootstrap();
      }
    }
  }

  Future<void> _bootstrap() async {
    setState(() => _vehicleStepReady = false);

    final a = _args!;
    if (a.status != AddVehicleStatus.update) {
      setState(() {
        data = AddVehicleFormData();
        _initKey = 'create';
        _loadingVehicle = false;
      });
      return;
    }

    final plate = (a.license ?? '').trim();
    if (plate.isEmpty) {
      setState(() {
        data = AddVehicleFormData();
        _initKey = 'update-empty-plate';
      });
      return;
    }

    setState(() => _loadingVehicle = true);
    try {
      final v = await _vehicleApi.fetchVehicleByLicense(plate);

      final next = AddVehicleFormData();
      if (v != null) {
        next.applyFromVehicleApi(v, forcedPlate: plate);
        _initKey = (v['id'] ?? 'update').toString();
      } else {
        next.plateNumber = plate;
        _initKey = 'update-no-data';
      }

      setState(() => data = next);
    } catch (_) {
      setState(() {
        data = AddVehicleFormData()..plateNumber = plate;
        _initKey = 'update-error';
      });
    } finally {
      if (!mounted) return;
      setState(() => _loadingVehicle = false);
    }
  }

  Future<void> _confirmSubmit() async {
    final t = AppLocalizations.of(context);
    final isUpdate = _args?.status == AddVehicleStatus.update;

    final ok = await showDialog(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: isUpdate
            ? t.addVehicleConfirmUpdateTitle
            : t.addVehicleConfirmAddTitle,
        desc: isUpdate
            ? t.addVehicleConfirmUpdateDesc
            : t.addVehicleConfirmAddDesc,
        textCancel: t.cancel,
        textSubmit: t.confirm,
        funcCancel: () async {
          Navigator.pop(ctx, false);
        },
        funcSubmit: () async {
          Navigator.pop(ctx, true);
        },
      ),
    );

    if (ok == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isUpdate ? t.updateTodo : t.createTodo)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final status = _args?.status ?? AddVehicleStatus.create;
    final isUpdate = status == AddVehicleStatus.update;

    final title = isUpdate ? t.updateVehicleTitle : t.addNewVehicleTitle;

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        elevation: 0,
        surfaceTintColor: AppStyles.bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: AppStyles.textLBold),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Stack(
          children: [
            AppStepper(
              steps: [t.vehicleInformation, t.deviceInformation, t.review],
              formKeys: [_vehicleFormKey, _deviceFormKey, null],
              stepContents: [
                VehicleInfoStep(
                  key: ValueKey('vehicle-$_initKey'),
                  data: data,
                  formKey: _vehicleFormKey,
                  onReady: () {
                    if (!mounted) return;
                    if (_vehicleStepReady) return;
                    setState(() => _vehicleStepReady = true);
                  },
                  status: isUpdate ? false : true,
                ),
                DeviceInfoStep(
                  key: ValueKey('device-$_initKey'),
                  data: data,
                  formKey: _deviceFormKey,
                ),
                ReviewStep(key: ValueKey('review-$_initKey'), data: data),
              ],
              onSubmit: _confirmSubmit,
              activeColor: AppStyles.primaryColor,
              nextLabel: t.next,
              prevLabel: t.previous,
              submitLabel: isUpdate ? t.updateVehicleCta : t.addVehicleCta,
            ),

            if (_pageLoading)
              const Positioned.fill(child: FullScreenLoading(opacity: 0.08)),
          ],
        ),
      ),
    );
  }
}
