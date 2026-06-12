import 'package:ams/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

enum _ToastKind { success, failed }

class AppToast {
  static void show(BuildContext context, String message) {
    _show(context, message, _ToastKind.success, const Duration(seconds: 2));
  }

  static void showFailed(BuildContext context, String message) {
    _show(context, message, _ToastKind.failed, const Duration(seconds: 5));
  }

  static void _show(
    BuildContext context,
    String message,
    _ToastKind kind,
    Duration duration,
  ) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    final isFailed = kind == _ToastKind.failed;
    final bg = isFailed ? AppStyles.redColor : AppStyles.whiteColor;
    final fg = isFailed ? AppStyles.whiteColor : AppStyles.blackColor;

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
        elevation: 6,
        duration: duration,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
        content: Row(
          children: [
            Expanded(
              child: Text(message, style: AppStyles.textMd.copyWith(color: fg)),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => messenger.hideCurrentSnackBar(),
              child: Icon(Icons.close, size: 18, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
