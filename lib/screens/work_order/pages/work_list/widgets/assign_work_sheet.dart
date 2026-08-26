import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/base/widgets/option_picker_sheet.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:ams/screens/work_order/models/work_order_options.dart';
import 'package:flutter/material.dart';

/// Hasil pilihan sheet "Assign Work": kategori + tipe pekerjaan.
class AssignWorkSelection {
  final WorkCategoryOption category;
  final OptionItem type;

  const AssignWorkSelection({required this.category, required this.type});
}

/// Padanan `pages/work-list/components/work-list-popup.jsx`.
class AssignWorkSheet {
  static Future<AssignWorkSelection?> open(
    BuildContext context, {
    required List<WorkCategoryOption> categories,
  }) {
    return showModalBottomSheet<AssignWorkSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyles.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AssignWorkBody(categories: categories),
    );
  }
}

class _AssignWorkBody extends StatefulWidget {
  final List<WorkCategoryOption> categories;

  const _AssignWorkBody({required this.categories});

  @override
  State<_AssignWorkBody> createState() => _AssignWorkBodyState();
}

class _AssignWorkBodyState extends State<_AssignWorkBody> {
  WorkCategoryOption? _category;
  OptionItem? _type;

  bool get _canCreate => _category != null && _type != null;

  Future<void> _pickCategory() async {
    final t = AppLocalizations.of(context);

    final picked = await OptionPickerSheet.open(
      context,
      title: t.woWorkCategory,
      emptyLabel: t.filterNoOptions,
      options: widget.categories
          .map((c) => PickerOption(value: c.name, label: c.name))
          .toList(),
      selected: _category == null
          ? null
          : PickerOption(value: _category!.name, label: _category!.name),
    );
    if (picked == null) return;

    setState(() {
      _category = widget.categories.firstWhere((c) => c.name == picked.value);
      _type = null; // tipe lama tidak valid untuk kategori baru
    });
  }

  Future<void> _pickType() async {
    final category = _category;
    if (category == null) return;

    final t = AppLocalizations.of(context);

    final picked = await OptionPickerSheet.open(
      context,
      title: t.woWorkType,
      emptyLabel: t.filterNoOptions,
      options: category.workType
          .map((o) => PickerOption(value: o.value, label: o.label))
          .toList(),
      selected: _type == null
          ? null
          : PickerOption(value: _type!.value, label: _type!.label),
    );
    if (picked == null) return;

    setState(
      () => _type = OptionItem(value: picked.value, label: picked.label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return SafeArea(
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
                  child: Text(t.woAssignTitle, style: AppStyles.textLBold),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Column(
              children: [
                _SheetField(
                  label: t.woWorkCategory,
                  value: _category?.name,
                  hint: t.woWorkCategoryPlaceholder,
                  onTap: _pickCategory,
                ),
                if (_category != null) ...[
                  const SizedBox(height: 14),
                  _SheetField(
                    label: t.woWorkType,
                    value: _type?.label,
                    hint: t.woWorkTypePlaceholder,
                    onTap: _pickType,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
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
                    onPressed: _canCreate
                        ? () => Navigator.pop(
                            context,
                            AssignWorkSelection(
                              category: _category!,
                              type: _type!,
                            ),
                          )
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
                    child: Text(
                      t.woCreate,
                      style: AppStyles.textMd.copyWith(
                        color: _canCreate
                            ? AppStyles.whiteColor
                            : AppStyles.textDarkGrayColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final VoidCallback onTap;

  const _SheetField({
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
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
                  Icons.keyboard_arrow_down,
                  color: AppStyles.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
