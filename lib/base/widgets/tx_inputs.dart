// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ams/base/res/styles/app_styles.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TxInputText extends StatelessWidget {
  const TxInputText({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.textInputAction,
    this.inputFormatters,
    this.keyboardType,
    this.visible = true,
  });

  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final hasValue = controller?.text.trim().isNotEmpty == true;

    return Offstage(
      offstage: !visible,
      child: _TxFieldWrapper(
        label: label,
        child: TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          enabled: enabled,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: AppStyles.textMd.copyWith(
            color: enabled ? AppStyles.blackColor : AppStyles.darkGrayColor,
          ),
          decoration: _txInputDecoration(
            hintText,
            enabled: enabled,
            borderColor: _borderColorByValue(
              hasValue: hasValue,
              enabled: enabled,
            ),
          ),
        ),
      ),
    );
  }
}

class TxInputNumber extends StatelessWidget {
  const TxInputNumber({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.textInputAction,
  });

  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final hasValue = controller?.text.trim().isNotEmpty == true;

    return _TxFieldWrapper(
      label: label,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        validator: validator,
        enabled: enabled,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: textInputAction,
        style: AppStyles.textMd.copyWith(
          color: enabled ? AppStyles.blackColor : AppStyles.darkGrayColor,
        ),
        decoration: _txInputDecoration(
          hintText,
          enabled: enabled,
          borderColor: _borderColorByValue(
            hasValue: hasValue,
            enabled: enabled,
          ),
        ),
      ),
    );
  }
}

class TxInputDropdown<T> extends StatelessWidget {
  const TxInputDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.validator,
    this.hintText,
    this.enabled = true,
  });

  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final String? hintText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final hasItem = value != null && items.any((it) => it.value == value);
    final safeValue = hasItem ? value : null;

    final hasValue = safeValue != null;

    final borderColor = _borderColorByValue(
      enabled: enabled,
      hasValue: hasValue,
    );

    return _TxFieldWrapper(
      label: label,
      child: IgnorePointer(
        ignoring: !enabled,
        child: DropdownButtonFormField<T>(
          value: safeValue,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          icon: Icon(
            Icons.chevron_right,
            size: 22,
            color: enabled ? AppStyles.primaryColor : AppStyles.darkGrayColor,
          ),
          style: AppStyles.textMd.copyWith(
            color: enabled ? AppStyles.blackColor : AppStyles.darkGrayColor,
          ),
          decoration: _txInputDecoration(
            hintText,
            enabled: enabled,
            borderColor: borderColor,
          ),
        ),
      ),
    );
  }
}

class TxInputDate extends FormField<DateTime> {
  TxInputDate({
    super.key,
    required String label,
    String? hintText,
    DateTime? value,
    required ValueChanged<DateTime?> onChanged,
    String displayFormat = 'd MMMM y',
    DateTime? firstDate,
    DateTime? lastDate,
    bool enabled = true,
    super.validator,
  }) : super(
         initialValue: value,
         builder: (state) {
           final text = state.value == null
               ? ''
               : DateFormat(displayFormat, 'id_ID').format(state.value!);

           final borderColor = _borderColorByValue(
             hasValue: state.value != null,
             hasError: state.hasError,
             enabled: enabled,
           );

           final textColor = enabled
               ? AppStyles.blackColor
               : AppStyles.darkGrayColor;

           return _TxFieldWrapper(
             label: label,
             child: GestureDetector(
               onTap: !enabled
                   ? null
                   : () async {
                       final now = DateTime.now();
                       final picked = await showDatePicker(
                         context: state.context,
                         initialDate: state.value ?? now,
                         firstDate: firstDate ?? DateTime(2000),
                         lastDate: lastDate ?? DateTime(now.year + 20),
                       );
                       if (picked != null) {
                         state.didChange(picked);
                         onChanged(picked);
                       }
                     },
               child: AbsorbPointer(
                 child: TextField(
                   controller: TextEditingController(text: text),
                   readOnly: true,
                   style: AppStyles.textMd.copyWith(color: textColor),
                   decoration:
                       _txInputDecoration(
                         hintText,
                         enabled: enabled,
                         borderColor: borderColor,
                       ).copyWith(
                         prefixIcon: Icon(
                           Icons.calendar_month,
                           color: enabled
                               ? AppStyles.primaryColor
                               : AppStyles.darkGrayColor,
                         ),
                         errorText: state.errorText,
                       ),
                 ),
               ),
             ),
           );
         },
       );
}

class TxInputDateTime extends FormField<DateTime> {
  TxInputDateTime({
    super.key,
    required String label,
    String? hintText,
    DateTime? value,
    required ValueChanged<DateTime?> onChanged,
    String displayFormat = 'd MMMM y HH:mm',
    DateTime? firstDate,
    DateTime? lastDate,
    bool enabled = true,
    bool use24HourFormat = true,
    super.validator,
  }) : super(
         initialValue: value,
         builder: (state) {
           final text = state.value == null
               ? ''
               : DateFormat(displayFormat, 'id_ID').format(state.value!);

           final borderColor = _borderColorByValue(
             hasValue: state.value != null,
             hasError: state.hasError,
             enabled: enabled,
           );

           final textColor = enabled
               ? AppStyles.blackColor
               : AppStyles.darkGrayColor;

           Future<void> pickDateTime() async {
             final now = DateTime.now();
             final init = state.value ?? now;

             final pickedDate = await showDatePicker(
               context: state.context,
               initialDate: init,
               firstDate: firstDate ?? DateTime(2000),
               lastDate: lastDate ?? DateTime(now.year + 20),
               builder: (context, child) {
                 return Theme(
                   data: Theme.of(context).copyWith(
                     colorScheme: Theme.of(
                       context,
                     ).colorScheme.copyWith(primary: AppStyles.primaryColor),
                   ),
                   child: child!,
                 );
               },
             );
             if (pickedDate == null) return;

             final pickedTime = await showTimePicker(
               context: state.context,
               initialTime: TimeOfDay(hour: init.hour, minute: init.minute),
               builder: (context, child) {
                 final media = MediaQuery.of(context);
                 return MediaQuery(
                   data: media.copyWith(alwaysUse24HourFormat: use24HourFormat),
                   child: Theme(
                     data: Theme.of(context).copyWith(
                       colorScheme: Theme.of(
                         context,
                       ).colorScheme.copyWith(primary: AppStyles.primaryColor),
                     ),
                     child: child!,
                   ),
                 );
               },
             );
             if (pickedTime == null) return;

             final combined = DateTime(
               pickedDate.year,
               pickedDate.month,
               pickedDate.day,
               pickedTime.hour,
               pickedTime.minute,
             );

             state.didChange(combined);
             onChanged(combined);
           }

           return _TxFieldWrapper(
             label: label,
             child: GestureDetector(
               onTap: !enabled ? null : pickDateTime,
               child: AbsorbPointer(
                 child: TextField(
                   controller: TextEditingController(text: text),
                   readOnly: true,
                   style: AppStyles.textMd.copyWith(color: textColor),
                   decoration:
                       _txInputDecoration(
                         hintText,
                         enabled: enabled,
                         borderColor: borderColor,
                       ).copyWith(
                         prefixIcon: Icon(
                           Icons.calendar_today_rounded,
                           color: enabled
                               ? AppStyles.primaryColor
                               : AppStyles.darkGrayColor,
                         ),
                         suffixIcon: Icon(
                           Icons.arrow_forward_ios_rounded,
                           size: 12,
                           color: enabled
                               ? AppStyles.primaryColor
                               : AppStyles.darkGrayColor,
                         ),
                         errorText: state.errorText,
                       ),
                 ),
               ),
             ),
           );
         },
       );
}

class _TxFieldWrapper extends StatelessWidget {
  const _TxFieldWrapper({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppStyles.textMd.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          child,
        ],
      ),
    );
  }
}

InputDecoration _txInputDecoration(
  String? hintText, {
  required bool enabled,
  Color? borderColor,
}) {
  const double txInputRadius = 12;

  OutlineInputBorder border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(txInputRadius),
    borderSide: BorderSide(color: c, width: 1),
  );

  final effectiveBorderColor = enabled
      ? (borderColor ?? AppStyles.borderLightGray)
      : AppStyles.inputDisableBg;

  return InputDecoration(
    hintText: hintText,
    hintStyle: AppStyles.textMd.copyWith(color: AppStyles.textDarkGrayColor),
    isDense: true,
    filled: true,
    fillColor: enabled ? Colors.transparent : AppStyles.inputDisableBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

    enabledBorder: border(effectiveBorderColor),
    focusedBorder: border(effectiveBorderColor),
    disabledBorder: border(AppStyles.inputDisableBg),
  );
}

Color _borderColorByValue({
  required bool enabled,
  required bool hasValue,
  bool hasError = false,
}) {
  if (!enabled) return AppStyles.inputDisableBg;
  if (hasError) return AppStyles.redColor;

  return hasValue ? AppStyles.greenColor : AppStyles.borderLightGray;
}
