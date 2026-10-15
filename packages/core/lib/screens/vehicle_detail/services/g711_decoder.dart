import 'dart:typed_data';

/// Decoder audio G.711 A-law (format audio dashcam) ke PCM 16-bit / WAV.
/// Logikanya sama dengan `G711AToWAVConverter` di app Cordova lama.
class G711Decoder {
  G711Decoder._();

  /// Tabel 256 entri: byte A-law -> sampel PCM. Dihitung sekali.
  static final List<int> _table = _buildTable();

  static List<int> _buildTable() {
    final t = List<int>.filled(256, 0);
    for (int i = 0; i < 256; i++) {
      int input = i ^ 0x55;
      int exp = (input & 0x70) >> 4;
      int mantissa = input & 0x0f;
      int sample = mantissa << 4;
      if (exp > 0) {
        sample += 0x100;
        sample <<= (exp - 1);
      }
      if ((input & 0x80) == 0) sample = -sample;
      t[i] = sample;
    }
    return t;
  }

  /// Ubah byte A-law menjadi sampel PCM 16-bit.
  static Int16List decode(Uint8List alaw) {
    final pcm = Int16List(alaw.length);
    for (int i = 0; i < alaw.length; i++) {
      pcm[i] = _table[alaw[i]];
    }
    return pcm;
  }

  /// Bungkus sampel PCM dengan header WAV (mono, 16-bit, [sampleRate] Hz)
  /// dan kembalikan byte file WAV-nya.
  static Uint8List toWav(Int16List pcm, {int sampleRate = 8000}) {
    final dataLen = pcm.length * 2;
    final buf = ByteData(44 + dataLen);

    void writeStr(int offset, String s) {
      for (int i = 0; i < s.length; i++) {
        buf.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    writeStr(0, 'RIFF');
    buf.setUint32(4, 36 + dataLen, Endian.little);
    writeStr(8, 'WAVE');
    writeStr(12, 'fmt ');
    buf.setUint32(16, 16, Endian.little);
    buf.setUint16(20, 1, Endian.little); // PCM
    buf.setUint16(22, 1, Endian.little); // mono
    buf.setUint32(24, sampleRate, Endian.little);
    buf.setUint32(28, sampleRate * 2, Endian.little);
    buf.setUint16(32, 2, Endian.little);
    buf.setUint16(34, 16, Endian.little);
    writeStr(36, 'data');
    buf.setUint32(40, dataLen, Endian.little);

    int off = 44;
    for (final s in pcm) {
      buf.setInt16(off, s, Endian.little);
      off += 2;
    }
    return buf.buffer.asUint8List();
  }
}
