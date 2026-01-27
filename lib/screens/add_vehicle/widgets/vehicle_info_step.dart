// ignore_for_file: control_flow_in_finally, unrelated_type_equality_checks

import 'package:bitrack_mobile_flutter/base/constants/select_options.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/base/services/plate_number_formatter.dart';
import 'package:bitrack_mobile_flutter/base/widgets/tx_inputs.dart';
import 'package:bitrack_mobile_flutter/l10n/app_localizations.dart';
import 'package:bitrack_mobile_flutter/screens/add_vehicle/models/add_vehicle_form_data.dart';
import 'package:bitrack_mobile_flutter/screens/add_vehicle/services/vehicle_master_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class VehicleInfoStep extends StatefulWidget {
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
  State<VehicleInfoStep> createState() => _VehicleInfoStepState();
}

class _VehicleInfoStepState extends State<VehicleInfoStep> {
  final _api = const VehicleMasterApi();

  late final TextEditingController _plateCtrl;
  late final TextEditingController _typeCtrl;
  late final TextEditingController _colorCtrl;
  late final TextEditingController _vinCtrl;
  late final TextEditingController _engineCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _odoCtrl;

  bool _loading = false;

  String? _brandId;
  String? _modelId;
  String? _vehicleCategory;

  List<Map<String, dynamic>> _brands = [];
  List<Map<String, dynamic>> _models = [];

  late CancelToken _cancelToken;

  @override
  void initState() {
    super.initState();

    _plateCtrl = TextEditingController(text: widget.data.plateNumber);
    _typeCtrl = TextEditingController(text: widget.data.type);
    _colorCtrl = TextEditingController(text: widget.data.color);
    _vinCtrl = TextEditingController(text: widget.data.vin);
    _engineCtrl = TextEditingController(text: widget.data.engineNumber);
    _yearCtrl = TextEditingController(text: widget.data.year);
    _odoCtrl = TextEditingController(text: widget.data.odometerKm);

    _vehicleCategory = widget.data.vehicleCategory;

    _cancelToken = CancelToken();
    _loadMasters();
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    _typeCtrl.dispose();
    _colorCtrl.dispose();
    _vinCtrl.dispose();
    _engineCtrl.dispose();
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

      final brandExists = _brandId != null &&
          brands.any((b) => (b['id'] ?? '').toString() == _brandId);
      final modelExists = _modelId != null &&
          models.any((m) => (m['id'] ?? '').toString() == _modelId);

      if (!mounted) return;
      setState(() {
        _brands = brands;
        _models = models;
        if (!brandExists) _brandId = null;
        if (!modelExists) _modelId = null;
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
                  if (!widget.status)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppStyles.plateNumberBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            t.plateNumber,
                            textAlign: TextAlign.center,
                            style: AppStyles.textSm,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            _plateCtrl.text,
                            textAlign: TextAlign.center,
                            style: AppStyles.textLBold,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 25),
                  TxInputText(
                    label: t.plateNumber,
                    hintText: t.plateNumberHint,
                    controller: _plateCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) => _requiredText(context, v, t.plateNumber),
                    onChanged: (v) => widget.data.plateNumber = v,
                    inputFormatters: const [PlateNumberFormatter()],
                    visible: widget.status,
                  ),
                  TxInputDropdown<String>(
                    label: t.brand,
                    hintText: t.selectBrandHint,
                    value: _brandId,
                    items: _brands.map((b) {
                      return DropdownMenuItem<String>(
                        value: b['id'].toString(),
                        child: Text(b['brand_name'].toString()),
                      );
                    }).toList(),
                    validator: (v) => _requiredDropdown(context, v, t.brand),
                    enabled: !_loading,
                    onChanged: (id) {
                      setState(() {
                        _brandId = id;
                        _modelId = null;
                      });

                      final name = _brands
                          .firstWhere(
                            (b) => b['id'].toString() == id,
                          )['brand_name']
                          .toString();

                      widget.data.brand = name;
                      widget.data.model = null;
                    },
                  ),
                  TxInputDropdown<String>(
                    label: t.model,
                    hintText: _brandId == null
                        ? t.selectBrandFirst
                        : t.selectModelHint,
                    value: _modelId,
                    items: _filteredModels.map((m) {
                      return DropdownMenuItem<String>(
                        value: m['id'].toString(),
                        child: Text(m['model_name'].toString()),
                      );
                    }).toList(),
                    validator: (v) => _requiredDropdown(context, v, t.model),
                    enabled: !_loading && _brandId != null,
                    onChanged: (id) {
                      setState(() => _modelId = id);

                      final name = _models
                          .firstWhere(
                            (m) => m['id'].toString() == id,
                          )['model_name']
                          .toString();

                      widget.data.model = name;
                    },
                  ),
                  TxInputText(
                    label: t.vehicleType,
                    hintText: t.vehicleTypeHint,
                    controller: _typeCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) => _requiredText(context, v, t.vehicleType),
                    onChanged: (v) => widget.data.type = v,
                  ),
                  TxInputNumber(
                    label: t.vehicleYear,
                    hintText: t.vehicleYearHint,
                    controller: _yearCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) => _requiredText(context, v, t.vehicleYear),
                    onChanged: (v) => widget.data.year = v,
                  ),
                  TxInputText(
                    label: t.vehicleColor,
                    hintText: t.vehicleColorHint,
                    controller: _colorCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) => _requiredText(context, v, t.vehicleColor),
                    onChanged: (v) => widget.data.color = v,
                  ),
                  TxInputDropdown<String>(
                    label: t.vehicleCategory,
                    hintText: t.selectVehicleCategoryHint,
                    value: _vehicleCategory,
                    items: vehicleCategoryOptions
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.value,
                            child: Text(e.label),
                          ),
                        )
                        .toList(),
                    validator: (v) =>
                        _requiredDropdown(context, v, t.vehicleCategory),
                    onChanged: (v) {
                      setState(() => _vehicleCategory = v);
                      widget.data.vehicleCategory = v;
                    },
                  ),
                  TxInputNumber(
                    label: t.odometerKm,
                    hintText: t.odometerHint,
                    controller: _odoCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) => _requiredText(context, v, t.odometerKm),
                    onChanged: (v) => widget.data.odometerKm = v,
                  ),
                  TxInputText(
                    label: t.vin,
                    hintText: t.vinHint,
                    controller: _vinCtrl,
                    textInputAction: TextInputAction.next,
                    validator: (v) => _requiredText(context, v, t.vin),
                    onChanged: (v) => widget.data.vin = v,
                  ),
                  TxInputText(
                    label: t.engineNumber,
                    hintText: t.engineNumberHint,
                    controller: _engineCtrl,
                    textInputAction: TextInputAction.done,
                    validator: (v) => _requiredText(context, v, t.engineNumber),
                    onChanged: (v) => widget.data.engineNumber = v,
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
