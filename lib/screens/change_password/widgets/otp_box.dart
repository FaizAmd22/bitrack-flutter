// ignore_for_file: deprecated_member_use

import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TxOtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autoFocus;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const TxOtpBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.autoFocus,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  State<TxOtpBox> createState() => _TxOtpBoxState();
}

class _TxOtpBoxState extends State<TxOtpBox> {
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();

    _hasFocus = widget.focusNode.hasFocus;

    widget.focusNode.addListener(_handleFocus);
    widget.controller.addListener(_handleValue);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocus);
    widget.controller.removeListener(_handleValue);
    super.dispose();
  }

  void _handleFocus() => setState(() => _hasFocus = widget.focusNode.hasFocus);
  void _handleValue() => setState(() {});

  Color get _underlineColor {
    final hasValue = widget.controller.text.trim().isNotEmpty;

    if (hasValue) return AppStyles.greenColor;
    if (_hasFocus) return AppStyles.primaryColor;
    return AppStyles.borderLightGray;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: RawKeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKey: (ev) {
          if (ev is RawKeyDownEvent &&
              ev.logicalKey == LogicalKeyboardKey.backspace) {
            widget.onBackspace();
          }
        },
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          autofocus: widget.autoFocus,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 1,
          style: AppStyles.textMd.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            counterText: "",
            isDense: true,
            contentPadding: const EdgeInsets.only(bottom: 10),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: _underlineColor, width: 1.5),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: _underlineColor, width: 2),
            ),
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
