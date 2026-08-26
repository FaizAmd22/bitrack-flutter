import 'package:ams/base/network/api_response.dart';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/routes/app_routes.dart';
import 'package:ams/base/widgets/app_toast.dart';
import 'package:ams/base/widgets/option_picker_sheet.dart';
import 'package:ams/base/widgets/picker_field.dart';
import 'package:ams/base/widgets/tx_inputs.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/work_order/models/work_order_args.dart';
import 'package:ams/screens/work_order/providers/work_order_providers.dart';
import 'package:ams/screens/work_order/utils/format_date.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Padanan `pages/work-order/pages/create-work-order/create-work-order.jsx`.
class CreateWorkOrderScreen extends ConsumerStatefulWidget {
  const CreateWorkOrderScreen({super.key});

  @override
  ConsumerState<CreateWorkOrderScreen> createState() =>
      _CreateWorkOrderScreenState();
}

class _CreateWorkOrderScreenState extends ConsumerState<CreateWorkOrderScreen> {
  String? _fleetGroupId;
  String? _technicianId;
  DateTime? _date;
  bool _isSubmitting = false;

  bool get _canSubmit =>
      _fleetGroupId != null && _technicianId != null && _date != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workOrderOptionsProvider.notifier).load();
    });
  }

  Future<void> _submit() async {
    if (!_canSubmit || _isSubmitting) return;

    final t = AppLocalizations.of(context);
    setState(() => _isSubmitting = true);

    try {
      final created = await ref
          .read(workOrderApiProvider)
          .createWorkOrderHeader(
            fleetGroupId: _fleetGroupId!,
            technician: _technicianId!,
            dateFrom: formatDatePayload(_date!),
          );

      if (!mounted) return;
      ref.read(selectedWorkOrderProvider.notifier).select(created);

      // Ganti halaman create dengan work list WO yang baru dibuat, supaya
      // tombol back kembali ke daftar work order.
      await Navigator.pushReplacementNamed(
        context,
        AppRoutes.workListScreen,
        arguments: WorkListArgs(
          workOrderId: (created['id'] ?? '').toString(),
          workOrderNo: (created['work_order_no'] ?? '').toString(),
        ),
        result: true,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      AppToast.showFailed(context, apiErrorText(e, t.woCreateFailed));
    } catch (_) {
      if (!mounted) return;
      AppToast.showFailed(context, t.woCreateFailed);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final options = ref.watch(workOrderOptionsProvider);

    return Scaffold(
      backgroundColor: AppStyles.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyles.bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(t.woCreateTitle, style: AppStyles.textMdBold),
        leading: const BackButton(color: AppStyles.blackColor),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PickerField(
                      label: t.woFleetGroup,
                      hintText: t.woFleetGroupPlaceholder,
                      searchable: true,
                      searchHint: t.filterSearch,
                      value: _fleetGroupId,
                      options: options.fleetGroup
                          .map(
                            (o) => PickerOption(value: o.value, label: o.label),
                          )
                          .toList(),
                      onSelected: (o) =>
                          setState(() => _fleetGroupId = o.value),
                    ),
                    PickerField(
                      label: t.woTechnician,
                      hintText: t.woTechnicianPlaceholder,
                      searchable: true,
                      searchHint: t.filterSearch,
                      value: _technicianId,
                      options: options.technician
                          .map(
                            (o) => PickerOption(value: o.value, label: o.label),
                          )
                          .toList(),
                      onSelected: (o) =>
                          setState(() => _technicianId = o.value),
                    ),
                    TxInputDate(
                      label: t.woDate,
                      hintText: t.woDatePlaceholder,
                      value: _date,
                      onChanged: (value) => setState(() => _date = value),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              decoration: const BoxDecoration(
                color: AppStyles.whiteColor,
                border: Border(
                  top: BorderSide(color: AppStyles.borderLightGray),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          side: const BorderSide(color: AppStyles.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          t.cancel,
                          style: AppStyles.textMd.copyWith(
                            color: AppStyles.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _canSubmit && !_isSubmitting
                            ? _submit
                            : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: AppStyles.primaryColor,
                          disabledBackgroundColor: AppStyles.inputDisableBg,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppStyles.whiteColor,
                                ),
                              )
                            : Text(
                                t.woCreate,
                                style: AppStyles.textMd.copyWith(
                                  color: _canSubmit
                                      ? AppStyles.whiteColor
                                      : AppStyles.textDarkGrayColor,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
