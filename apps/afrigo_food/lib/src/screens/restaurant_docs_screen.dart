import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../state/food_flow_controller.dart';
import '../widgets/food_primary_button.dart';
import '../widgets/food_text_field.dart';
import '../widgets/location_picker_map.dart';

/// Screen 62 — Restaurant verification docs. Simplified to exactly 4
/// fields per an explicit product request: name, business license (real
/// upload), a real map-tap address (was free-text), and a logo (real
/// upload) — cuisine type and the opening-hours text field are gone.
class RestaurantDocsScreen extends ConsumerStatefulWidget {
  const RestaurantDocsScreen({super.key});

  @override
  ConsumerState<RestaurantDocsScreen> createState() => _RestaurantDocsScreenState();
}

class _RestaurantDocsScreenState extends ConsumerState<RestaurantDocsScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickSource(BuildContext context, Future<void> Function(ImageSource) upload) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Text('📷'), title: const Text('التقاط صورة', style: TextStyle(fontFamily: 'Tajawal')), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
            ListTile(leading: const Text('🖼️'), title: const Text('اختيار من المعرض', style: TextStyle(fontFamily: 'Tajawal')), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          ],
        ),
      ),
    );
    if (source != null) await upload(source);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final s = ref.watch(foodFlowControllerProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
      child: ListView(
        children: [
          const Text('توثيق المطعم', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 6),
          const Text('أدخل بيانات مطعمك لمراجعتها من طرف الإدارة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 20),
          FoodTextField(controller: _name, hint: 'اسم المطعم', small: true),
          const SizedBox(height: 14),
          const Text('حدد عنوان المطعم على الخريطة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF57534E))),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LocationPickerMap(
              height: 180,
              initialLat: s.pickedLat ?? 18.0858,
              initialLng: s.pickedLng ?? -15.9785,
              onChanged: controller.setPickedLocation,
            ),
          ),
          if (s.pickedAddress != null) ...[
            const SizedBox(height: 6),
            Text(s.pickedAddress!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF78716C))),
          ],
          const SizedBox(height: 14),
          InkWell(
            onTap: s.licenseUploading ? null : () => _pickSource(context, controller.pickAndUploadLicense),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD6D3D1), width: 1.5), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  if (s.licenseUploading)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Text(s.doc1 ? '✅' : '📄', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(s.doc1 ? 'تم رفع رخصة النشاط' : 'رفع رخصة النشاط', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF78716C))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: s.logoUploading ? null : () => _pickSource(context, controller.pickAndUploadLogo),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD6D3D1), width: 1.5), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  if (s.logoUploading)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Text(s.logoUploaded ? '✅' : '🏷️', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(s.logoUploaded ? 'تم رفع شعار المطعم' : 'رفع شعار المطعم', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF78716C))),
                ],
              ),
            ),
          ),
          if (s.authError != null) ...[
            const SizedBox(height: 10),
            Text(s.authError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 20),
          FoodPrimaryButton(
            label: 'متابعة',
            isLoading: s.isSubmitting,
            onPressed: () => controller.submitRestaurantDocs(name: _name.text.trim()),
          ),
        ],
      ),
    );
  }
}
