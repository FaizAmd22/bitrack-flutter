// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';

import 'package:bitrack_core/base/res/styles/app_styles.dart';
import 'package:bitrack_core/base/widgets/app_toast.dart';
import 'package:bitrack_core/l10n/app_localizations.dart';
import 'package:bitrack_core/screens/work_order/pages/work_details/models/evidence_slot.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum EvidenceSection { before, after }

/// Padanan `pages/work-details/components/evidence-tab.jsx`.
class EvidenceTab extends StatelessWidget {
  final List<EvidenceSlot?> beforeImages;
  final List<EvidenceSlot?> afterImages;
  final bool readOnly;

  /// Dipanggil saat satu slot berubah (diisi, diganti, atau dikosongkan).
  final void Function(EvidenceSection section, int index, EvidenceSlot? slot)
  onSlotChanged;

  /// Dipanggil saat foto milik server dihapus — URL-nya dikumpulkan dulu dan
  /// baru benar-benar dihapus ketika user menyimpan.
  final ValueChanged<String> onRemoteImageRemoved;

  const EvidenceTab({
    super.key,
    required this.beforeImages,
    required this.afterImages,
    required this.readOnly,
    required this.onSlotChanged,
    required this.onRemoteImageRemoved,
  });

  List<EvidenceSlot?> _slotsOf(EvidenceSection section) =>
      section == EvidenceSection.before ? beforeImages : afterImages;

  Future<void> _pickImage(
    BuildContext context,
    EvidenceSection section,
    int index,
  ) async {
    final t = AppLocalizations.of(context);

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppStyles.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(t.woEvidenceUploadTitle, style: AppStyles.textMdBold),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppStyles.primaryColor,
              ),
              title: Text(t.woEvidenceTakePhoto, style: AppStyles.textMd),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppStyles.primaryColor,
              ),
              title: Text(t.woEvidenceFromGallery, style: AppStyles.textMd),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (picked == null) return;

      final extension = picked.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        if (context.mounted) {
          AppToast.showFailed(context, t.woEvidenceInvalidFormat);
        }
        return;
      }

      _replaceSlot(section, index, EvidenceSlot(file: File(picked.path)));
    } catch (_) {
      if (context.mounted) {
        AppToast.showFailed(context, t.woEvidenceProcessFailed);
      }
    }
  }

  void _replaceSlot(EvidenceSection section, int index, EvidenceSlot? slot) {
    final previous = _slotsOf(section)[index];
    if (previous != null && previous.isFromServer && slot == null) {
      onRemoteImageRemoved(previous.remoteUrl!);
    }
    onSlotChanged(section, index, slot);
  }

  Future<void> _openSlotActions(
    BuildContext context,
    EvidenceSection section,
    int index,
  ) async {
    final t = AppLocalizations.of(context);
    final slot = _slotsOf(section)[index];
    if (slot == null) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppStyles.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(t.woEvidenceProofTitle, style: AppStyles.textMdBold),
            const SizedBox(height: 8),
            ListTile(
              title: Text(t.woEvidenceView, style: AppStyles.textMd),
              onTap: () => Navigator.pop(context, 'view'),
            ),
            if (!readOnly) ...[
              ListTile(
                title: Text(t.woEvidenceReplace, style: AppStyles.textMd),
                onTap: () => Navigator.pop(context, 'replace'),
              ),
              ListTile(
                title: Text(
                  t.woEvidenceDelete,
                  style: AppStyles.textMd.copyWith(color: AppStyles.redColor),
                ),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (action == null || !context.mounted) return;

    switch (action) {
      case 'view':
        await _showFullImage(context, slot);
        break;
      case 'replace':
        await _pickImage(context, section, index);
        break;
      case 'delete':
        _replaceSlot(section, index, null);
        break;
    }
  }

  Future<void> _showFullImage(BuildContext context, EvidenceSlot slot) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: _slotImage(slot, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotImage(EvidenceSlot slot, {BoxFit fit = BoxFit.cover}) {
    if (slot.file != null) {
      return Image.file(slot.file!, fit: fit);
    }
    return Image.network(
      slot.remoteUrl!,
      fit: fit,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: AppStyles.inputDisableBg,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: AppStyles.darkGrayColor,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, EvidenceSection section) {
    final slots = _slotsOf(section);

    return SizedBox(
      height: 115,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: slots.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final slot = slots[index];

          return GestureDetector(
            onTap: () {
              if (slot != null) {
                _openSlotActions(context, section, index);
              } else if (!readOnly) {
                _pickImage(context, section, index);
              }
            },
            child: Container(
              width: 115,
              height: 115,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: readOnly
                    ? AppStyles.inputDisableBg
                    : const Color(0xFFF9F9F9),
                border: Border.all(color: AppStyles.borderLightGray),
                borderRadius: BorderRadius.circular(8),
              ),
              child: slot != null
                  ? _slotImage(slot)
                  : _EmptySlot(readOnly: readOnly),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(t.woEvidenceBefore, style: AppStyles.textMdBold),
        const SizedBox(height: 10),
        _buildRow(context, EvidenceSection.before),
        const SizedBox(height: 22),
        Text(t.woEvidenceAfter, style: AppStyles.textMdBold),
        const SizedBox(height: 10),
        _buildRow(context, EvidenceSection.after),
      ],
    );
  }
}

class _EmptySlot extends StatelessWidget {
  final bool readOnly;

  const _EmptySlot({required this.readOnly});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Opacity(
      opacity: readOnly ? 0.5 : 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppStyles.inputDisableBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_camera_outlined,
              size: 20,
              color: AppStyles.darkGrayColor,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              t.woEvidenceTakeOrUpload,
              textAlign: TextAlign.center,
              style: AppStyles.textXs.copyWith(
                color: AppStyles.textDarkGrayColor,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
