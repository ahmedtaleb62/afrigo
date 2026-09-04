import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../state/client_flow_controller.dart';
import '../../state/client_screen.dart';
import '../../widgets/back_circle_button.dart';
import '../../widgets/client_primary_button.dart';
import '../../widgets/client_text_field.dart';
import '../../core/context_ext.dart';

/// Screen 33 — Parcel type/size/photo.
class ParcelDetailsScreen extends ConsumerWidget {
  const ParcelDetailsScreen({super.key});

  Future<void> _pickPhoto(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Text('📷'), title: Text(l10n.clientProfileTakePhoto, style: const TextStyle(fontFamily: 'Tajawal')), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
            ListTile(leading: const Text('🖼️'), title: Text(l10n.clientProfilePickFromGallery, style: const TextStyle(fontFamily: 'Tajawal')), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          ],
        ),
      ),
    );
    if (source != null) await ref.read(clientFlowControllerProvider.notifier).pickAndUploadParcelPhoto(source);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);
    final l10n = context.l10n;

    Widget typeChip(String label, String emoji, String value) {
      final selected = s.parcelType == value;
      return Expanded(
        child: InkWell(
          onTap: () => controller.setParcelType(value),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: selected ? const Color(0xFF16A34A) : const Color(0xFFE7E5E4), width: 2),
              color: selected ? const Color(0xFFF0FDF4) : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text('$emoji $label', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12))),
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, context.topGap(30), 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BackCircleButton(onTap: controller.back),
              const SizedBox(width: 12),
              Text(l10n.clientParcelDetailsTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 20),
          Text(l10n.clientParcelTypeLabel, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 8),
          Row(
            children: [
              // NOTE: `value:` (3rd arg) stays the raw Arabic identifier
              // stored as `s.parcelType` — only the display label is localized.
              typeChip(l10n.clientParcelTypeDocuments, '📄', 'وثائق'),
              const SizedBox(width: 8),
              typeChip(l10n.clientParcelTypeFood, '🍱', 'طعام'),
              const SizedBox(width: 8),
              typeChip(l10n.clientParcelTypeOther, '📦', 'أخرى'),
            ],
          ),
          const SizedBox(height: 18),
          Text(l10n.clientParcelSizeLabel, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _SizeChip(l10n.clientParcelSizeSmall, selected: true)),
              const SizedBox(width: 8),
              Expanded(child: _SizeChip(l10n.clientParcelSizeMedium)),
              const SizedBox(width: 8),
              Expanded(child: _SizeChip(l10n.clientParcelSizeLarge)),
            ],
          ),
          const SizedBox(height: 14),
          ClientTextField(hint: l10n.clientParcelNotesHint, onChanged: controller.setParcelNotes),
          const SizedBox(height: 14),
          InkWell(
            onTap: s.parcelPhotoUploading ? null : () => _pickPhoto(context, ref),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD6D3D1), width: 1.5),
                borderRadius: BorderRadius.circular(12),
                image: s.parcelPhotoUrl != null
                    ? DecorationImage(image: NetworkImage(s.parcelPhotoUrl!), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.25), BlendMode.darken))
                    : null,
              ),
              child: Column(
                children: [
                  if (s.parcelPhotoUploading)
                    const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                  else
                    Text(s.parcelPhotoUrl != null ? '✅' : '📷', style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(
                    s.parcelPhotoUrl != null ? l10n.clientParcelPhotoAttached : l10n.clientParcelPhotoAddHint,
                    style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: s.parcelPhotoUrl != null ? Colors.white : const Color(0xFF78716C)),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          ClientPrimaryButton(label: l10n.commonContinue, onPressed: () => controller.goTo(ClientScreen.parcelConfirm)),
        ],
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip(this.label, {this.selected = false});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: selected ? const Color(0xFF16A34A) : const Color(0xFFE7E5E4), width: 2),
        color: selected ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12))),
    );
  }
}
