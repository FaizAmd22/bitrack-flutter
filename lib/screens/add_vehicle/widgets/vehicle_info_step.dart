// ignore_for_file: control_flow_in_finally, unrelated_type_equality_checks

import 'package:ams/base/constants/select_options.dart';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/services/plate_number_formatter.dart';
import 'package:ams/base/widgets/option_picker_sheet.dart';
import 'package:ams/base/widgets/picker_field.dart';
import 'package:ams/base/widgets/tx_inputs.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/add_vehicle/models/add_vehicle_form_data.dart';
import 'package:ams/screens/add_vehicle/services/vehicle_master_api.dart';
import 'package:ams/screens/vehicle/providers/fleet_group_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VehicleInfoStep extends ConsumerStatefulWidget {
  const VehicleInfoStep({
    super.key,
    required this.data,
    required this.formKey,
    this.onReady,
    required this.status,
  });

  final AddVehicleFormData data;
  final GlobalKey<FormState> formKey;
  final VoidCallback? onReady;
  final bool status;

  @override
  ConsumerState<VehicleInfoStep> createState() => _VehicleInfoStepState();
}

class _VehicleInfoStepState extends ConsumerState<VehicleInfoStep> {
  final _api = const VehicleMasterApi();

  late final TextEditingController _plateCtrl;
  late final TextEditingController _vinCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _odoCtrl;

  bool _loading = false;

  String? _brandId;
  String? _modelId;
  String? _vehicleCategory;
  String? _fleetGroupId;

  List<Map<String, dynamic>> _fleetGroups = [];
  List<Map<String, dynamic>> _brands = [];
  List<Map<String, dynamic>> _models = [];

  late CancelToken _cancelToken;

  @override
  void initState() {
    super.initState();

    _plateCtrl = TextEditingController(text: widget.data.plateNumber);
    _vinCtrl = TextEditingController(text: widget.data.vin);
    _yearCtrl = TextEditingController(text: widget.data.year);
    _odoCtrl = TextEditingController(text: widget.data.odometer);

    _vehicleCategory = widget.data.vehicleCategory;
    _fleetGroupId = widget.data.fleetGroupId;

    _cancelToken = CancelToken();
    _loadMasters();
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    _vinCtrl.dispose();
    _yearCtrl.dispose();
    _odoCtrl.dispose();
    _cancelToken.cancel("disposed");
    super.dispose();
  }

  String? _requiredText(BuildContext context, String? v, String fieldName) {
    final t = AppLocalizations.of(context);
    if (v == null || v.trim().isEmpty) {
      return t.fieldRequired(fieldName);
    }
    return null;
  }

  String? _requiredDropdown(BuildContext context, dynamic v, String fieldName) {
    final t = AppLocalizations.of(context);
    if (v == null) {
      return t.fieldRequired(fieldName);
    }
    return null;
  }

  Future<void> _loadMasters() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final brandsRaw = await _api.fetchBrandsRaw(cancelToken: _cancelToken);
      final modelsRaw = await _api.fetchModelsRaw(cancelToken: _cancelToken);
      final fleetRaw = await ref.read(fleetGroupProvider.future);

      if (!mounted) return;

      final brandMap = <String, Map<String, dynamic>>{};
      for (final b in brandsRaw) {
        final id = (b['id'] ?? '').toString().trim();
        final name = (b['brand_name'] ?? '').toString().trim();
        if (id.isNotEmpty) {
          brandMap[id] = b;
        } else if (name.isNotEmpty) {
          brandMap['name:$name'] = b;
        }
      }

      final modelMap = <String, Map<String, dynamic>>{};
      for (final m in modelsRaw) {
        final id = (m['id'] ?? '').toString().trim();
        final name = (m['model_name'] ?? '').toString().trim();
        final brandId = (m['brand_id'] ?? '').toString().trim();
        final key = id.isNotEmpty ? id : 'name:$brandId|$name';
        if (name.isNotEmpty) modelMap[key] = m;
      }

      final brands = brandMap.values.toList()
        ..sort(
          (a, b) => (a['brand_name'] ?? '').toString().compareTo(
            (b['brand_name'] ?? '').toString(),
          ),
        );

      final models = modelMap.values.toList()
        ..sort(
          (a, b) => (a['model_name'] ?? '').toString().compareTo(
            (b['model_name'] ?? '').toString(),
          ),
        );

      final brandExists =
          _brandId != null &&
          brands.any((b) => (b['id'] ?? '').toString() == _brandId);
      final modelExists =
          _modelId != null &&
          models.any((m) => (m['id'] ?? '').toString() == _modelId);

      final fleetGroups = <Map<String, dynamic>>[];
      final seenFleet = <String>{};
      for (final f in fleetRaw) {
        final m = Map<String, dynamic>.from(f as Map);
        final id = (m['id'] ?? '').toString().trim();
        final name = (m['fleet_group_name'] ?? '').toString().trim();
        if (id.isEmpty || name.isEmpty) continue;
        if (seenFleet.add(id)) fleetGroups.add(m);
      }
      fleetGroups.sort(
        (a, b) => (a['fleet_group_name'] ?? '').toString().compareTo(
          (b['fleet_group_name'] ?? '').toString(),
        ),
      );

      final fleetExists =
          _fleetGroupId != null &&
          fleetGroups.any((f) => (f['id'] ?? '').toString() == _fleetGroupId);

      if (!mounted) return;
      setState(() {
        _brands = brands;
        _models = models;
        _fleetGroups = fleetGroups;
        if (!brandExists) _brandId = null;
        if (!modelExists) _modelId = null;
        if (!fleetExists) _fleetGroupId = null;
      });
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        return;
      }
    } catch (e) {
      // debugPrint('unexpected error: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
      widget.onReady?.call();
    }
  }

  List<Map<String, dynamic>> get _filteredModels {
    if (_brandId == null || _brandId!.isEmpty) return [];
    return _models
        .where((m) => (m['brand_id'] ?? '').toString() == _brandId)
        .toList();
  }

  String? _findBrandIdByName(String? name) {
    if (name == null) return null;
    final m = _brands.where(
      (b) =>
          (b['brand_name'] ?? '').toString().toLowerCase() ==
          name.toLowerCase(),
    );
    return m.isEmpty ? null : (m.first['id'] ?? '').toString();
  }

  String? _findModelIdByName(String? name) {
    if (name == null) return null;
    final m = _models.where(
      (e) =>
          (e['model_name'] ?? '').toString().toLowerCase() ==
          name.toLowerCase(),
    );
    return m.isEmpty ? null : (m.first['id'] ?? '').toString();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    _brandId ??= _findBrandIdByName(widget.data.brand);
    _modelId ??= _findModelIdByName(widget.data.model);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppStyles.whiteColor,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.only(top: 15),
          child: Form(
            key: widget.formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if (!widget.status)
                  //   Container(
                  //     width: double.infinity,
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 16,
                  //       vertical: 16,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: AppStyles.plateNumberBg,
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     child: Column(
                  //       children: [
                  //         Text(
                  //           t.plateNumber,
                  //           textAlign: TextAlign.center,
                  //           style: AppStyles.textSm,
                  //         ),
                  //         SizedBox(height: 5),
                  //         Text(
                  //           _plateCtrl.text,
                  //           textAlign: TextAlign.center,
                  //           style: AppStyles.textLBold,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // const SizedBox(height: 25),
                  TxInputText(
                    label: t.plateNumber,
                    hintText: t.plateNumberHint,
                    controller: _plateCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) => _requiredText(context, v, t.plateNumber),
                    onChanged: (v) => widget.data.plateNumber = v,
                    inputFormatters: const [PlateNumberFormatter()],
                    // visible: widget.status,
                  ),
                  PickerField(
                    label: t.brand,
                    hintText: t.selectBrandHint,
                    value: _brandId,
                    searchable: true,
                    enabled: !_loading,
                    options: _brands
                        .map(
                          (b) => PickerOption(
                            value: b['id'].toString(),
                            label: b['brand_name'].toString(),
                          ),
                        )
                        .toList(),
                    validator: (v) => _requiredDropdown(context, v, t.brand),
                    onSelected: (opt) {
                      setState(() {
                        _brandId = opt.value;
                        _modelId = null;
                      });
                      widget.data.brand = opt.label;
                      widget.data.model = null;
                    },
                  ),
                  PickerField(
                    label: t.model,
                    hintText: _brandId == null
                        ? t.selectBrandFirst
                        : t.selectModelHint,
                    value: _modelId,
                    searchable: true,
                    enabled: !_loading && _brandId != null,
                    options: _filteredModels
                        .map(
                          (m) => PickerOption(
                            value: m['id'].toString(),
                            label: m['model_name'].toString(),
                          ),
                        )
                        .toList(),
                    validator: (v) => _requiredDropdown(context, v, t.model),
                    onSelected: (opt) {
                      setState(() => _modelId = opt.value);
                      widget.data.model = opt.label;
                    },
                  ),
                  TxInputNumber(
                    label: t.vehicleYear,
                    hintText: t.vehicleYearHint,
                    controller: _yearCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) => _requiredText(context, v, t.vehicleYear),
                    onChanged: (v) => widget.data.year = v,
                  ),
                  PickerField(
                    label: t.vehicleCategory,
                    hintText: t.selectVehicleCategoryHint,
                    value: _vehicleCategory,
                    searchable: false, // ← tanpa search, opsi sedikit
                    options: vehicleCategoryOptions
                        .map(
                          (e) => PickerOption(value: e.value, label: e.label),
                        )
                        .toList(),
                    validator: (v) =>
                        _requiredDropdown(context, v, t.vehicleCategory),
                    onSelected: (opt) {
                      setState(() => _vehicleCategory = opt.value);
                      widget.data.vehicleCategory = opt.value;
                    },
                  ),
                  TxInputNumber(
                    label: t.odometer,
                    hintText: t.odometerHint,
                    controller: _odoCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) => _requiredText(context, v, t.odometer),
                    onChanged: (v) => widget.data.odometer = v,
                  ),
                  TxInputText(
                    label: t.vin,
                    hintText: t.vinHint,
                    controller: _vinCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) => _requiredText(context, v, t.vin),
                    onChanged: (v) => widget.data.vin = v,
                  ),
                  PickerField(
                    label: 'Fleet Group',
                    hintText: _loading ? t.loading : t.selectFleetGroupHint,
                    value: _fleetGroupId,
                    searchable: true,
                    enabled: !_loading,
                    options: _fleetGroups
                        .map(
                          (f) => PickerOption(
                            value: f['id'].toString(),
                            label: f['fleet_group_name'].toString(),
                          ),
                        )
                        .toList(),
                    validator: (v) =>
                        _requiredDropdown(context, v, 'Fleet Group'),
                    onSelected: (opt) {
                      setState(() => _fleetGroupId = opt.value);
                      widget.data.fleetGroupId = opt.value;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
