import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../widgets/food_primary_button.dart';
import '../widgets/food_text_field.dart';

const _cuisineTypes = ['إيطالي', 'جزائري تقليدي', 'شرقي', 'مأكولات بحرية', 'وجبات سريعة', 'أخرى'];

/// Screen 62 — Restaurant verification docs.
class RestaurantDocsScreen extends ConsumerStatefulWidget {
  const RestaurantDocsScreen({super.key});

  @override
  ConsumerState<RestaurantDocsScreen> createState() => _RestaurantDocsScreenState();
}

class _RestaurantDocsScreenState extends ConsumerState<RestaurantDocsScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _openingHours = TextEditingController();
  String _cuisine = _cuisineTypes.first;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _openingHours.dispose();
    super.dispose();
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
          const Text('أدخل بيانات مطعمك لمراجعتها من طرف الإدارة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF7C8574))),
          const SizedBox(height: 20),
          FoodTextField(controller: _name, hint: 'اسم المطعم', small: true),
          const SizedBox(height: 10),
          FoodTextField(controller: _address, hint: 'العنوان (حدّد على الخريطة)', small: true),
          const SizedBox(height: 10),
          InkWell(
            onTap: controller.toggleDoc,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFC7CDC3), width: 1.5), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text(s.doc1 ? '✅' : '📄', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(s.doc1 ? 'تم رفع رخصة النشاط' : 'رفع رخصة/وثيقة النشاط', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF7C8574))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: const Color(0xFFF8F9F8), border: Border.all(color: const Color(0xFFE1E5DF), width: 1.5), borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _cuisine,
                isExpanded: true,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF1A1D16)),
                items: _cuisineTypes.map((t) => DropdownMenuItem(value: t, child: Text('نوع المطبخ: $t'))).toList(),
                onChanged: (v) => setState(() => _cuisine = v ?? _cuisine),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FoodTextField(controller: _openingHours, hint: 'ساعات العمل (مثال: 10:00 - 23:00)', small: true),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: _UploadPlaceholder(emoji: '🖼️', label: 'صورة الغلاف')),
              SizedBox(width: 10),
              Expanded(child: _UploadPlaceholder(emoji: '🏷️', label: 'الشعار')),
            ],
          ),
          if (s.authError != null) ...[
            const SizedBox(height: 10),
            Text(s.authError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 20),
          FoodPrimaryButton(
            label: 'متابعة',
            isLoading: s.isSubmitting,
            onPressed: () => controller.submitRestaurantDocs(
              name: _name.text.trim(),
              address: _address.text.trim(),
              cuisineType: _cuisine,
              openingHours: _openingHours.text.trim(),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFC7CDC3), width: 1.5), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF7C8574))),
        ],
      ),
    );
  }
}
