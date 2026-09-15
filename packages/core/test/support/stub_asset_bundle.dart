import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Aset gambar app (ikon SVG, PNG truk, animasi lottie) ada di `apps/*/assets`,
/// bukan di packages/core, jadi tidak bisa di-resolve dari test package ini.
/// Bundle ini menjawab setiap aset dengan isi minimal yang valid sesuai
/// ekstensinya.
class StubAssetBundle extends CachingAssetBundle {
  static final _pixel = Uint8List.fromList(const [
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, //
    0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, //
    0, 0, 0, 11, 73, 68, 65, 84, 120, 156, 99, 96, 0, 2, 0, 0, //
    5, 0, 1, 122, 94, 171, 63, 0, 0, 0, 0, 73, 69, 78, 68, //
    174, 66, 96, 130,
  ]);
  static const _svgXml =
      '<svg xmlns="http://www.w3.org/2000/svg" width="36" height="36">'
      '<rect width="36" height="36"/></svg>';
  static const _lottieJson =
      '{"v":"5.5.7","fr":30,"ip":0,"op":30,"w":100,"h":100,"layers":[]}';

  static Uint8List _bytes(String key) {
    if (key.endsWith('.svg')) return Uint8List.fromList(_svgXml.codeUnits);
    if (key.endsWith('.json')) return Uint8List.fromList(_lottieJson.codeUnits);
    return _pixel;
  }

  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(_bytes(key));

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      String.fromCharCodes(_bytes(key));

  @override
  Future<T> loadStructuredBinaryData<T>(
    String key,
    FutureOr<T> Function(ByteData data) parser,
  ) async =>
      parser(const StandardMessageCodec().encodeMessage(<String, Object>{})!);
}

Widget withStubAssets(Widget child) =>
    DefaultAssetBundle(bundle: StubAssetBundle(), child: child);
