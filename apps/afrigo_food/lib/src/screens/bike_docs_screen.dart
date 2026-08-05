import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../widgets/food_primary_button.dart';
import '../widgets/food_text_field.dart';

const _bikeTypes = ['نارية', 'دراجة هوائية', 'سيارة صغيرة'];

/// Screen 63 — Delivery bike verification docs.
class BikeDocsScreen extends ConsumerStatefulWidget {
  const BikeDocsScreen({super.key});

  @override
  ConsumerState<BikeDocsScreen> createState() => _BikeDocsScreenState();
}

class _BikeDocsScreenState extends ConsumerState<BikeDocsScreen> {
  final _vehicleName = TextEditingController();
  final _address = TextEditingController();
  final _plateNumber = TextEditingController();
  final _notes = TextEditingController();
  String _bikeType = _bikeTypes.first;

  @override
  void dispose() {
    _vehicleName.dispose();
    _address.dispose();
    _plateNumber.dispose();
    _notes.dispose();
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
          const Text('توثيق دراجة التوصيل', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 6),
          const Text('بيانات مركبة/دراجة التوصيل الخاصة بالمطعم', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF7C8574))),
          const SizedBox(height: 20),
          FoodTextField(controller: _vehicleName, hint: 'اسم المركبة', small: true),
          const SizedBox(height: 10),
          FoodTextField(controller: _address, hint: 'العنوان', small: true),
          const SizedBox(height: 10),
          InkWell(
            onTap: controller.toggleDoc2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFC7CDC3), width: 1.5), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text(s.doc2 ? '✅' : '📷', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(s.doc2 ? 'تم رفع رخصة القيادة' : 'رفع صورة رخصة القيادة', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF7C8574))),
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
                value: _bikeType,
                isExpanded: true,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF1A1D16)),
                items: _bikeTypes.map((t) => DropdownMenuItem(value: t, child: Text('نوع الدراجة: $t'))).toList(),
                onChanged: (v) => setState(() => _bikeType = v ?? _bikeType),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FoodTextField(controller: _plateNumber, hint: 'رقم اللوحة', small: true),
          const SizedBox(height: 10),
          FoodTextField(controller: _notes, hint: 'ملاحظات', small: true),
          if (s.authError != null) ...[
            const SizedBox(height: 10),
            Text(s.authError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 20),
          FoodPrimaryButton(
            label: 'إرسال للمراجعة',
            isLoading: s.isSubmitting,
            onPressed: () => controller.submitBikeDocs(
              vehicleName: _vehicleName.text.trim(),
              address: _address.text.trim(),
              bikeType: _bikeType,
              plateNumber: _plateNumber.text.trim(),
              notes: _notes.text.trim(),
            ),
          ),
        ],
      ),
    );
  }
}
