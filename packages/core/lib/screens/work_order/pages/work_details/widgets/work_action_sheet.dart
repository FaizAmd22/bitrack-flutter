import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/work_order/utils/format_label.dart';
import 'package:flutter/material.dart';

/// Aksi simpan di detail task: simpan sebagai draft, atau tandai selesai.
enum WorkAction { saveDraft, markComplete }

/// Sheet pilihan simpan saat menekan tombol simpan di detail task: "Save as
/// draft" atau "Mark as complete" (yang terakhir hanya untuk non-teknisi).
/// (Porting `pages/work-details/components/work-action-popup.jsx`.)
class WorkActionSheet {
  static Future<WorkAction?> open(
    BuildContext context, {
    required String title,
    required String licensePlate,
    required bool allowComplete,
  }) {
    return showModalBottomSheet<WorkAction>(
      context: context,
      backgroundColor: AppStyles.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final t = AppLocalizations.of(context);

        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppStyles.borderLightGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatStatus(title),
                            style: AppStyles.textMdBold.copyWith(
                              color: AppStyles.blackColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            licensePlate,
                            style: AppStyles.textSm.copyWith(
                              color: AppStyles.textDarkGrayColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppStyles.borderLightGray),
              ListTile(
                title: Text(
                  t.woActionSaveDraft,
                  style: AppStyles.textMd.copyWith(color: AppStyles.blackColor),
                ),
                onTap: () => Navigator.pop(context, WorkAction.saveDraft),
              ),
              if (allowComplete)
                ListTile(
                  title: Text(
                    t.woActionMarkComplete,
                    style: AppStyles.textMd.copyWith(
                      color: AppStyles.blackColor,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, WorkAction.markComplete),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
