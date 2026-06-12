// lib/base/widgets/option_picker_sheet.dart
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class PickerOption {
  final String value;
  final String label;
  const PickerOption({required this.value, required this.label});
}

class OptionPickerSheet {
  static Future<PickerOption?> open(
    BuildContext context, {
    required String title,
    required List<PickerOption> options,
    PickerOption? selected,
    bool searchable = false,
    String searchHint = 'Cari...',
    String emptyLabel = 'Tidak ada pilihan',
  }) {
    return showModalBottomSheet<PickerOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppStyles.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PickerBody(
        title: title,
        options: options,
        selected: selected,
        searchable: searchable,
        searchHint: searchHint,
        emptyLabel: emptyLabel,
      ),
    );
  }
}

class _PickerBody extends StatefulWidget {
  final String title;
  final List<PickerOption> options;
  final PickerOption? selected;
  final bool searchable;
  final String searchHint;
  final String emptyLabel;

  const _PickerBody({
    required this.title,
    required this.options,
    required this.selected,
    required this.searchable,
    required this.searchHint,
    required this.emptyLabel,
  });

  @override
  State<_PickerBody> createState() => _PickerBodyState();
}

class _PickerBodyState extends State<_PickerBody> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.options
        : widget.options
              .where((o) => o.label.toLowerCase().contains(q))
              .toList();

    final maxHeight = MediaQuery.of(context).size.height * 0.7;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(widget.title, style: AppStyles.textLBold),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              if (widget.searchable)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppStyles.primaryColor,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppStyles.borderLightGray,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppStyles.borderLightGray,
                        ),
                      ),
                    ),
                  ),
                ),
              Flexible(
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          widget.emptyLabel,
                          style: AppStyles.textSm.copyWith(
                            color: AppStyles.textDarkGrayColor,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final opt = filtered[i];
                          final isSel = opt.value == widget.selected?.value;
                          return ListTile(
                            title: Text(
                              opt.label,
                              style: AppStyles.textSm.copyWith(
                                color: AppStyles.blackColor,
                              ),
                            ),
                            trailing: isSel
                                ? const Icon(
                                    Icons.check,
                                    color: AppStyles.primaryColor,
                                  )
                                : null,
                            onTap: () => Navigator.pop(context, opt),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
