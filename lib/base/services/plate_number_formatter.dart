import 'package:flutter/services.dart';

class PlateNumberFormatter extends TextInputFormatter {
  const PlateNumberFormatter({
    this.maxPrefix = 2,
    this.maxNumbers = 4,
    this.maxSuffix = 3,
    this.separator = '-',
  });

  final int maxPrefix;
  final int maxNumbers;
  final int maxSuffix;
  final String separator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = (newValue.text).toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );

    String prefix = '';
    String numbers = '';
    String suffix = '';

    var i = 0;

    while (i < raw.length && prefix.length < maxPrefix) {
      final ch = raw[i];
      if (!RegExp(r'[A-Z]').hasMatch(ch)) break;
      prefix += ch;
      i++;
    }

    while (i < raw.length && numbers.length < maxNumbers) {
      final ch = raw[i];
      if (!RegExp(r'[0-9]').hasMatch(ch)) break;
      numbers += ch;
      i++;
    }

    while (i < raw.length && suffix.length < maxSuffix) {
      final ch = raw[i];
      if (!RegExp(r'[A-Z]').hasMatch(ch)) break;
      suffix += ch;
      i++;
    }

    final parts = <String>[];
    if (prefix.isNotEmpty) parts.add(prefix);
    if (numbers.isNotEmpty) parts.add(numbers);
    if (suffix.isNotEmpty) parts.add(suffix);

    final formatted = parts.join(separator);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }
}
