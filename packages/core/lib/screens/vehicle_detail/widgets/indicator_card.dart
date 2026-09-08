// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/widgets/skeleton_box.dart';

class IndicatorItemData {
  final String icon;
  final String label;
  final Color background;
  final Color color;

  /// Nilainya belum diketahui karena response detail belum tiba.
  ///
  /// [label] diganti skeleton, bukan ditampilkan apa adanya: chip bahan bakar
  /// misalnya akan membaca `fuel_consumed` yang masih 0 dan menampilkan
  /// "0 %" berlatar merah — terbaca sebagai tangki kosong, padahal datanya
  /// memang belum ada.
  final bool loading;

  const IndicatorItemData({
    required this.icon,
    required this.label,
    required this.background,
    required this.color,
    this.loading = false,
  });
}

class IndicatorCard extends StatelessWidget {
  final List<IndicatorItemData> items;

  const IndicatorCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Expanded(child: _IndicatorItem(data: items[i])),
            if (i != items.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _IndicatorItem extends StatelessWidget {
  final IndicatorItemData data;

  const _IndicatorItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
        decoration: BoxDecoration(
          color: data.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/icons/${data.icon}',
              width: 30,
              height: 30,
              color: data.color,
            ),
            const SizedBox(height: 3),
            if (data.loading)
              // Tingginya disamakan dengan satu baris textSm supaya chip tidak
              // berubah ukuran saat data akhirnya tiba.
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: SkeletonBox(
                  width: 34,
                  height: 10,
                  alignment: Alignment.center,
                ),
              )
            else
              Text(
                data.label,
                style: AppStyles.textSm.copyWith(color: data.color),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
