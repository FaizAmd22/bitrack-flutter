import 'dart:io';

/// Satu slot bukti pekerjaan. Sama seperti di bitrack-mobile ada 5 slot untuk
/// "before" dan 5 untuk "after"; slot bisa berisi foto dari server (sudah
/// tersimpan) atau foto baru yang belum diunggah.
class EvidenceSlot {
  final File? file;
  final String? remoteUrl;

  const EvidenceSlot({this.file, this.remoteUrl});

  /// Foto lama dari server (belum diganti).
  bool get isFromServer => file == null && remoteUrl != null;

  /// Foto baru dari kamera/galeri yang belum diunggah.
  bool get isNew => file != null;
}

/// Jumlah slot foto per kelompok (before / after).
const evidenceSlotCount = 5;

/// Lima slot kosong.
List<EvidenceSlot?> emptyEvidenceSlots() =>
    List<EvidenceSlot?>.filled(evidenceSlotCount, null, growable: false);

/// Isi slot dari daftar URL foto di server (maksimal 5; sisanya kosong).
List<EvidenceSlot?> evidenceSlotsFromUrls(dynamic raw) {
  final slots = List<EvidenceSlot?>.filled(
    evidenceSlotCount,
    null,
    growable: false,
  );
  if (raw is! List) return slots;

  for (var i = 0; i < raw.length && i < evidenceSlotCount; i++) {
    final url = raw[i]?.toString();
    if (url == null || url.isEmpty) continue;
    slots[i] = EvidenceSlot(remoteUrl: url);
  }
  return slots;
}
