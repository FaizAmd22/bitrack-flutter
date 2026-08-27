import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:flutter/material.dart';

class RegisterPendingDialog extends StatelessWidget {
  final String title;
  final String desc;
  final String textOk;
  final VoidCallback funcOk;

  const RegisterPendingDialog({
    super.key,
    required this.title,
    required this.desc,
    required this.textOk,
    required this.funcOk,
  });

  void _onOk(BuildContext context) {
    Navigator.pop(context);
    funcOk();
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
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppStyles.bgYellowColor,
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Center(
                child: Icon(
                  Icons.hourglass_top_rounded,
                  size: 30,
                  color: AppStyles.yellowColor,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(title, textAlign: TextAlign.center, style: AppStyles.textMdBold),
            const SizedBox(height: 12),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: AppStyles.textSm.copyWith(color: AppStyles.textBlackColor),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onOk(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  textOk,
                  style: AppStyles.textMd.copyWith(color: AppStyles.whiteColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
