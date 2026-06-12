import 'package:ams/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String desc;
  final String textCancel;
  final String textSubmit;
  final VoidCallback? funcCancel;
  final VoidCallback funcSubmit;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.desc,
    required this.textCancel,
    required this.textSubmit,
    required this.funcSubmit,
    this.funcCancel,
  });

  void _onCancel(BuildContext context) {
    if (funcCancel != null) {
      funcCancel!();
    } else {
      Navigator.pop(context);
    }
  }

  void _onSubmit(BuildContext context) {
    Navigator.pop(context);
    funcSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppStyles.whiteColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppStyles.textMdBold,
            ),
            const SizedBox(height: 20),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: AppStyles.textSm.copyWith(color: AppStyles.textBlackColor),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _onCancel(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppStyles.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      textCancel,
                      style: AppStyles.textMd.copyWith(
                        color: AppStyles.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onSubmit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      textSubmit,
                      style: AppStyles.textMd.copyWith(
                        color: AppStyles.whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
