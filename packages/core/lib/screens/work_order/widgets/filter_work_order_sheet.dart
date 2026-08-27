import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/widgets/option_picker_sheet.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/work_order/models/work_order_options.dart';
import 'package:bitrack_core/screens/work_order/providers/work_order_providers.dart';
import 'package:bitrack_core/screens/work_order/utils/format_date.dart';
import 'package:flutter/material.dart';

/// Padanan `components/filter-work-order-popup.jsx`.
/// Mengembalikan filter baru, atau [WorkOrderFilter.empty] saat di-clear.
class FilterWorkOrderSheet {
  static Future<WorkOrderFilter?> open(
    BuildContext context, {
    required WorkOrderFilter current,
    required WorkOrderOptions options,
    required bool isTechnician,
    required String languageCode,
  }) {
    return showModalBottomSheet<WorkOrderFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyles.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FilterBody(
        current: current,
        options: options,
        isTechnician: isTechnician,
        languageCode: languageCode,
      ),
    );
  }
}

class _FilterBody extends StatefulWidget {
  final WorkOrderFilter current;
  final WorkOrderOptions options;
  final bool isTechnician;
  final String languageCode;

  const _FilterBody({
    required this.current,
    required this.options,
    required this.isTechnician,
    required this.languageCode,
  });

  @override
  State<_FilterBody> createState() => _FilterBodyState();
}

class _FilterBodyState extends State<_FilterBody> {
  String? _createdAt;
  OptionItem? _fleetGroup;
  OptionItem? _technician;

  @override
  void initState() {
    super.initState();
    _createdAt = widget.current.createdAt;
    _fleetGroup = _findOption(
      widget.options.fleetGroup,
      widget.current.fleetGroupId,
    );
    _technician = _findOption(
      widget.options.technician,
      widget.current.technician,
    );
  }

  OptionItem? _findOption(List<OptionItem> source, String? value) {
    if (value == null) return null;
    for (final o in source) {
      if (o.value == value) return o;
    }
    return null;
  }

  Future<void> _pickOption({
    required String title,
    required List<OptionItem> source,
    required OptionItem? selected,
    required ValueChanged<OptionItem> onPicked,
  }) async {
    final t = AppLocalizations.of(context);

    final picked = await OptionPickerSheet.open(
      context,
      title: title,
      searchable: true,
      searchHint: t.filterSearch,
      emptyLabel: t.filterNoOptions,
      selected: selected == null
          ? null
          : PickerOption(value: selected.value, label: selected.label),
      options: source
          .map((o) => PickerOption(value: o.value, label: o.label))
          .toList(),
    );

    if (picked == null) return;
    onPicked(OptionItem(value: picked.value, label: picked.label));
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = parseDate(_createdAt) ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;

    setState(() => _createdAt = formatDatePayload(picked));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppStyles.borderLightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(t.filterTitle, style: AppStyles.textLBold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppStyles.borderLightGray),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FilterField(
                    label: t.woFleetGroup,
                    value: _fleetGroup?.label,
                    hint: t.filterChooseFleetGroup,
                    onTap: () => _pickOption(
                      title: t.woFleetGroup,
                      source: widget.options.fleetGroup,
                      selected: _fleetGroup,
                      onPicked: (o) => setState(() => _fleetGroup = o),
                    ),
                  ),
                  if (!widget.isTechnician) ...[
                    const SizedBox(height: 16),
                    _FilterField(
                      label: t.woTechnician,
                      value: _technician?.label,
                      hint: t.woTechnicianPlaceholder,
                      onTap: () => _pickOption(
                        title: t.woTechnician,
                        source: widget.options.technician,
                        selected: _technician,
                        onPicked: (o) => setState(() => _technician = o),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _FilterField(
                    label: t.woDate,
                    value: _createdAt == null
                        ? null
                        : formatDateWithText(_createdAt, widget.languageCode),
                    hint: t.woDatePlaceholder,
                    icon: Icons.calendar_month,
                    onTap: _pickDate,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(context, WorkOrderFilter.empty),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppStyles.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        t.filterClear,
                        style: AppStyles.textMd.copyWith(
                          color: AppStyles.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(
                        context,
                        WorkOrderFilter(
                          createdAt: _createdAt,
                          fleetGroupId: _fleetGroup?.value,
                          technician: _technician?.value,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AppStyles.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        t.filterApply,
                        style: AppStyles.textMd.copyWith(
                          color: AppStyles.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilterField({
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.textMdBold),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppStyles.borderLightGray),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: AppStyles.primaryColor),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    value ?? hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.textMd.copyWith(
                      color: value == null
                          ? AppStyles.textDarkGrayColor
                          : AppStyles.blackColor,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppStyles.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
