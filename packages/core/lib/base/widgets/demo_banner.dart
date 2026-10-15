import 'package:bitrack_core/base/services/demo_mode.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pita oranye "versi demo" di bawah layar selama mode demo aktif.
///
/// Ditaruh di `MaterialApp.builder` supaya tampil di semua halaman (termasuk
/// yang di-push di luar BottomNavBar seperti Vehicle Detail dan Periodic
/// Track), dan reaktif lewat [demoModeProvider] tanpa perlu restart app.
/// `IgnorePointer` membuat pita tidak menghalangi sentuhan ke halaman.
class DemoBanner extends ConsumerWidget {
  final Widget child;
  const DemoBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDemo = ref.watch(demoModeProvider);

    if (!isDemo) return child;

    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: IgnorePointer(
              child: Container(
                width: double.infinity,
                height: 26,
                color: Colors.orange.shade700,
                alignment: Alignment.center,
                child: Text(
                  AppLocalizations.of(context).demoVersionBanner,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
