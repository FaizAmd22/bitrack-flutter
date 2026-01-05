import 'package:flutter/services.dart';

class PlateInputFormatter extends TextInputFormatter {
  const PlateInputFormatter();

  bool _isUpperAlpha(int c) => c >= 65 && c <= 90;
  bool _isDigit(int c) => c >= 48 && c <= 57;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.toUpperCase();

    final buf = StringBuffer();
    for (final code in text.codeUnits) {
      if (_isUpperAlpha(code) || _isDigit(code)) buf.writeCharCode(code);
    }
    final raw = buf.toString();

    final sb = StringBuffer();
    int i = 0;

    int prefixLen = 0;
    while (i < raw.length && prefixLen < 2) {
      final c = raw.codeUnitAt(i);
      if (!_isUpperAlpha(c)) break;
      sb.writeCharCode(c);
      prefixLen++;
      i++;
    }

    int numLen = 0;
    final numStart = i;
    while (i < raw.length && numLen < 4) {
      final c = raw.codeUnitAt(i);
      if (!_isDigit(c)) break;
      numLen++;
      i++;
    }
    if (numLen > 0) {
      sb.write('-');
      sb.write(raw.substring(numStart, numStart + numLen));
    }

    int sufLen = 0;
    final sufStart = i;
    while (i < raw.length && sufLen < 3) {
      final c = raw.codeUnitAt(i);
      if (!_isUpperAlpha(c)) break;
      sufLen++;
      i++;
    }
    if (sufLen > 0) {
      sb.write('-');
      sb.write(raw.substring(sufStart, sufStart + sufLen));
    }

    final formatted = sb.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
