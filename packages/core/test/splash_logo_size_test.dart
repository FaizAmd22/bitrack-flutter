// Verifikasi perilaku ukuran logo splash: kotak per app + BoxFit.contain.
// Yang dipastikan di sini bukan pixel-perfect-nya, tapi tiga sifat yang jadi
// alasan perubahan ini: rasio logo tidak berubah, logo memanjang vs kotak
// sama-sama muat, dan resolusi file PNG tidak ikut menentukan ukuran tampil.
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// ImageProvider dummy beresolusi bebas, supaya tes tidak bergantung file aset.
class _SolidImage extends ImageProvider<_SolidImage> {
  const _SolidImage(this.width, this.height);
  final int width;
  final int height;

  @override
  Future<_SolidImage> obtainKey(ImageConfiguration configuration) async => this;

  @override
  ImageStreamCompleter loadImage(_SolidImage key, ImageDecoderCallback _) {
    return OneFrameImageStreamCompleter(() async {
      final pixels = Uint8List(width * height * 4)..fillRange(0, width * height * 4, 255);
      final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
      final descriptor = ui.ImageDescriptor.raw(
        buffer,
        width: width,
        height: height,
        pixelFormat: ui.PixelFormat.rgba8888,
      );
      final codec = await descriptor.instantiateCodec();
      final frame = await codec.getNextFrame();
      return ImageInfo(image: frame.image);
    }());
  }

  @override
  bool operator ==(Object other) =>
      other is _SolidImage && other.width == width && other.height == height;

  @override
  int get hashCode => Object.hash(width, height);
}

/// Potongan yang sama persis dengan yang dipakai splash_screen.dart.
Widget _splashLogo(Size box, ImageProvider provider) => MaterialApp(
      home: Center(
        child: SizedBox.fromSize(
          size: box,
          child: Image(image: provider, fit: BoxFit.contain),
        ),
      ),
    );

/// Ukuran logo seperti yang benar-benar tergambar (bukan ukuran kotaknya).
Size _paintedSize(Size box, Size intrinsic) =>
    applyBoxFit(BoxFit.contain, intrinsic, box).destination;

void main() {
  testWidgets('kotak logo mengikuti nilai per app', (tester) async {
    await tester.pumpWidget(_splashLogo(const Size(180, 180), const _SolidImage(800, 800)));
    await tester.pump();
    expect(tester.getSize(find.byType(Image)), const Size(180, 180));
  });

  test('logo memanjang FixTrack: rasio utuh, muat di kotaknya', () {
    // logo_1.png = 279x54, kotak fixtrack = 279x54 -> tergambar apa adanya.
    final painted = _paintedSize(const Size(279, 54), const Size(279, 54));
    expect(painted, const Size(279, 54));
  });

  test('logo memanjang di kotak kotak: dibatasi lebar, rasio tetap', () {
    final painted = _paintedSize(const Size(180, 180), const Size(279, 54));
    expect(painted.width, 180);
    expect(painted.height, closeTo(180 * 54 / 279, 0.01)); // ~34.8
    expect(painted.width / painted.height, closeTo(279 / 54, 0.01));
  });

  test('logo kotak: mengisi kotaknya penuh', () {
    final painted = _paintedSize(const Size(180, 180), const Size(1024, 1024));
    expect(painted, const Size(180, 180));
  });

  test('resolusi file TIDAK mengubah ukuran tampil', () {
    // Inti perubahan dari ConstrainedBox ke SizedBox: PNG kecil pun tetap
    // digambar sebesar kotaknya, bukan sebesar resolusi aslinya.
    final kecil = _paintedSize(const Size(180, 180), const Size(64, 64));
    final besar = _paintedSize(const Size(180, 180), const Size(2732, 2732));
    expect(kecil, besar);
    expect(kecil, const Size(180, 180));
  });
}
