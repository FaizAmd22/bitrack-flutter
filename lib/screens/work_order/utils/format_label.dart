// Padanan `pages/work-order/functions/format-label.js`.

const _specialCases = {
  'imei': 'IMEI',
  'obd': 'OBD',
  'sim': 'SIM',
  'gps': 'GPS',
};

/// "on_process" -> "On Process"
String formatStatus(String? status) {
  if (status == null || status.trim().isEmpty) return '-';

  return status
      .toLowerCase()
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

/// "simcardNumber" -> "Simcard Number", dengan pengecualian IMEI/OBD/SIM/GPS.
String formatLabel(String? key, String? type) {
  if (key == null || key.isEmpty) return '';

  final normalizedType = (type ?? '').toLowerCase();
  if (normalizedType.contains('sim card replacement') ||
      normalizedType.contains('gps sim card replacement')) {
    return 'New ';
  }

  return key
      .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
      .split(RegExp(r'[\s_]+'))
      .map((word) {
        if (word.isEmpty) return word;
        final lower = word.toLowerCase();
        final special = _specialCases[lower];
        if (special != null) return special;
        return '${word[0].toUpperCase()}${word.substring(1)}';
      })
      .join(' ')
      .trim();
}

/// Ubah label kategori/tipe jadi key yang dikirim ke API:
/// "Sim Card Replacement" -> "SIMCARD_REPLACEMENT".
String formatPayloadKey(String? text) {
  if (text == null || text.isEmpty) return '';
  if (text == 'GPS') return 'GPS';
  if (text.toLowerCase() == 'sim card replacement') {
    return 'SIMCARD_REPLACEMENT';
  }
  return text.toUpperCase().replaceAll(RegExp(r'\s+'), '_');
}

String normalizeKey(String? value) =>
    (value ?? '').toLowerCase().replaceAll(RegExp(r'[_\s]'), '');
