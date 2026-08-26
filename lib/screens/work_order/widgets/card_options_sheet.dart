import 'package:ams/base/res/styles/app_styles.dart';
import 'package:ams/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum CardAction { details, delete }

/// Padanan `components/card-modal.jsx`: sheet aksi yang muncul saat kartu
/// work order / work list ditekan. Opsi hapus hanya untuk non-teknisi.
class CardOptionsSheet {
  static Future<CardAction?> open(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool allowDelete,
  }) {
    return showModalBottomSheet<CardAction>(
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
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.textMdBold.copyWith(
                              color: AppStyles.blackColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
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
                  t.woOptionDetails,
                  style: AppStyles.textMd.copyWith(color: AppStyles.blackColor),
                ),
                onTap: () => Navigator.pop(context, CardAction.details),
              ),
              if (allowDelete)
                ListTile(
                  title: Text(
                    t.woOptionDelete,
                    style: AppStyles.textMd.copyWith(color: AppStyles.redColor),
                  ),
                  onTap: () => Navigator.pop(context, CardAction.delete),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
