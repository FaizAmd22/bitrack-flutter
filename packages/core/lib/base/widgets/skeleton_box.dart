import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

/// Kotak abu-abu berdenyut sebagai penanda "data sedang dimuat".
///
/// Dipakai menggantikan teks placeholder seperti `-` atau `0 %`. Placeholder
/// semacam itu tidak bisa dibedakan dari data yang memang kosong atau bernilai
/// nol, sehingga layar terbaca "datanya tidak ada" padahal request-nya masih
/// berjalan.
///
/// Sengaja tidak memakai paket shimmer: satu AnimationController yang
/// menggerakkan opacity sudah cukup, dan tidak menambah dependensi.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    this.height = 12,
    this.alignment = Alignment.centerLeft,
  });

  final double width;
  final double height;
  final Alignment alignment;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.25,
    end: 0.6,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: FadeTransition(
        opacity: _opacity,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppStyles.darkGrayColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
