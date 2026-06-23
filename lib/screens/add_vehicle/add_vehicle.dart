// ignore_for_file: deprecated_member_use, use_build_context_synchronously, control_flow_in_finally

import 'package:ams/base/widgets/app_toast.dart';
import 'package:ams/base/widgets/confirm_dialog.dart';
import 'package:ams/base/widgets/full_screen_loading.dart';
import 'package:ams/screens/add_vehicle/services/fetch_vehicle_by_license.dart';
import 'package:ams/screens/add_vehicle/services/submit_vehicle.dart';
import 'package:ams/screens/vehicle_detail/models/add_vehicle_args.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/app_stepper.dart';
import 'package:ams/screens/add_vehicle/models/add_vehicle_form_data.dart';
import 'package:ams/screens/add_vehicle/widgets/device_info_step.dart';
import 'package:ams/screens/add_vehicle/widgets/review_step.dart';
import 'package:ams/screens/add_vehicle/widgets/vehicle_info_step.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  AddVehicleFormData data = AddVehicleFormData();

  String? _vehicleId;
  String? fleetGroupId;
  bool _submitting = false;
  final _vehicleFormKey = GlobalKey<FormState>();
  final _deviceFormKey = GlobalKey<FormState>();
  final _submitService = const SubmitVehicleService();

  AddVehicleArgs? _args;

  bool _loadingVehicle = false;
  String _initKey = 'create';
  bool _vehicleStepReady = false;
  bool get _pageLoading => _loadingVehicle || !_vehicleStepReady || _submitting;

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
        data = AddVehicleFormData()..plateNumber = (a.license ?? '').trim();
        _initKey = 'create';
        _loadingVehicle = false;
      });
      return;
    }

    final id = (a.id ?? '').trim();
    final plate = (a.license ?? '').trim();
    if (id.isEmpty && plate.isEmpty) {
      setState(() {
        data = AddVehicleFormData();
        _initKey = 'update-empty-plate';
      });
      return;
    }

    // Id sudah pasti benar (datang dari list), pakai langsung untuk submit
    // update walau fetch detail di bawah gagal/tidak ketemu.
    if (id.isNotEmpty) _vehicleId = id;

    setState(() => _loadingVehicle = true);
    try {
      final v = id.isNotEmpty
          ? await _vehicleApi.fetchVehicleById(id)
          : await _vehicleApi.fetchVehicleByLicense(plate);
      debugPrint('>>> fetch vehicle for update result: $v');

      final next = AddVehicleFormData();
      if (v != null) {
        next.applyFromVehicleApi(v, forcedPlate: plate.isEmpty ? null : plate);
        _initKey = (v['id'] ?? id).toString();
        _vehicleId ??= (v['id'] ?? '').toString();
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

    await showDialog(
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
        funcSubmit: () async {
          await _doSubmit(isUpdate);
        },
      ),
    );
  }

  Future<void> _doSubmit(bool isUpdate) async {
    final t = AppLocalizations.of(context);

    setState(() => _submitting = true);

    const storage = FlutterSecureStorage();
    final createdBy = await storage.read(key: 'user_name') ?? '';

    try {
      final result = isUpdate
          ? await _submitService.update(
              data,
              id: _vehicleId ?? '',
              createdBy: createdBy,
            )
          : await _submitService.create(data, createdBy: createdBy);

      if (!mounted) return;

      // Jalur 1: HTTP 200 + status:"false" (mis. SIM card)
      if (!result.success) {
        setState(() => _submitting = false);
        AppToast.showFailed(
          context,
          result.errorMsg ?? (isUpdate ? t.errFailedUpdate : t.errFailedAdd),
        );
        return; // jangan navigate
      }

      // SUKSES
      setState(() => _submitting = false);
      AppToast.show(
        context,
        isUpdate ? t.successUpdateVehicle : t.successAddVehicle,
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pop(context, true); // ← kirim sinyal sukses (create & update)
    } on DioException catch (e) {
      // Jalur 2: HTTP 422 (mis. VIN validation.unique)
      if (!mounted) return;
      setState(() => _submitting = false);

      debugPrint('>>> submit 422 body: ${e.response?.data}');

      final uniqueMsg = _pickUniqueMessage(e);
      AppToast.showFailed(
        context,
        uniqueMsg ?? (isUpdate ? t.errFailedUpdate : t.errFailedAdd),
      );
      return; // jangan navigate
    } catch (e) {
      // Error lain (jaringan, timeout)
      if (!mounted) return;
      setState(() => _submitting = false);
      AppToast.showFailed(
        context,
        isUpdate ? t.errFailedUpdate : t.errFailedAdd,
      );
    }
  }

  String? _pickUniqueMessage(DioException e) {
    final t = AppLocalizations.of(context);
    final data = e.response?.data;
    if (data is! Map) return null;

    final errors = data['errors'] is Map ? data['errors'] as Map : data;

    bool hasUnique(String field) {
      final v = errors[field];
      if (v == null) return false;
      if (v is String) return v == 'validation.unique';
      if (v is List) return v.contains('validation.unique');
      if (v is Map) {
        return v['code'] == 'validation.unique' ||
            v['message'] == 'validation.unique' ||
            v.values.contains('validation.unique');
      }
      return false;
    }

    if (hasUnique('vin')) return t.errVinUnique;
    return null;
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
