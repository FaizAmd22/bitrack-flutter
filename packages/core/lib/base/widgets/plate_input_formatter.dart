import 'package:flutter/services.dart';

/// Memformat input plat nomor saat diketik: `b1234abc` -> `B-1234-ABC`
/// (maks. 2 huruf, 4 angka, 3 huruf). Dipakai di form work order.
///
/// Hasilnya sama dengan [PlateNumberFormatter] (dipakai di form tambah
/// kendaraan); keduanya ada karena berasal dari dua fitur yang dibuat
/// terpisah.
class PlateInputFormatter extends TextInputFormatter {
  const PlateInputFormatter();

  // Dicek lewat kode ASCII: 65-90 = A-Z, 48-57 = 0-9.
  bool _isUpperAlpha(int c) => c >= 65 && c <= 90;
  bool _isDigit(int c) => c >= 48 && c <= 57;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.toUpperCase();

    // Buang semua karakter selain huruf dan angka (termasuk spasi dan '-').
    final buf = StringBuffer();
    for (final code in text.codeUnits) {
      if (_isUpperAlpha(code) || _isDigit(code)) buf.writeCharCode(code);
    }
    final raw = buf.toString();

    final sb = StringBuffer();
    int i = 0;

    // Kode wilayah: sampai 2 huruf di awal.
    int prefixLen = 0;
    while (i < raw.length && prefixLen < 2) {
      final c = raw.codeUnitAt(i);
      if (!_isUpperAlpha(c)) break;
      sb.writeCharCode(c);
      prefixLen++;
      i++;
    }

    // Nomor: sampai 4 angka.
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

    // Seri: sampai 3 huruf.
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
