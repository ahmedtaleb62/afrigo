import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/livreur_flow_controller.dart';
import '../widgets/livreur_primary_button.dart';
import '../widgets/livreur_text_field.dart';

const _bikeTypes = ['نارية', 'دراجة هوائية', 'سيارة صغيرة'];

/// Screen 74 — Vehicle verification docs.
class VehicleDocsScreen extends ConsumerStatefulWidget {
  const VehicleDocsScreen({super.key});

  @override
  ConsumerState<VehicleDocsScreen> createState() => _VehicleDocsScreenState();
}

class _VehicleDocsScreenState extends ConsumerState<VehicleDocsScreen> {
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
    final controller = ref.read(livreurFlowControllerProvider.notifier);
    final s = ref.watch(livreurFlowControllerProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
      child: ListView(
        children: [
          const Text('توثيق الدراجة/المركبة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 6),
          const Text('أدخل بياناتك لمراجعتها من طرف الإدارة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 20),
          LivreurTextField(controller: _vehicleName, hint: 'اسم صاحب المركبة'),
          const SizedBox(height: 10),
          LivreurTextField(controller: _address, hint: 'العنوان'),
          const SizedBox(height: 10),
          InkWell(
            onTap: controller.toggleLicensePhoto,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD6D3D1), width: 2), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text(s.licensePhoto ? '✅' : '📷', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(s.licensePhoto ? 'تم رفع صورة رخصة القيادة' : 'رفع صورة رخصة القيادة', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF78716C))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD6D3D1), width: 1.5), borderRadius: BorderRadius.circular(10)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _bikeType,
                isExpanded: true,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF1C1917)),
                items: _bikeTypes.map((t) => DropdownMenuItem(value: t, child: Text('نوع الدراجة: $t'))).toList(),
                onChanged: (v) => setState(() => _bikeType = v ?? _bikeType),
              ),
            ),
          ),
          const SizedBox(height: 10),
          LivreurTextField(controller: _plateNumber, hint: 'رقم اللوحة'),
          const SizedBox(height: 10),
          LivreurTextField(controller: _notes, hint: 'ملاحظات'),
          if (s.authError != null) ...[
            const SizedBox(height: 10),
            Text(s.authError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 20),
          LivreurPrimaryButton(
            label: 'إرسال للمراجعة',
            isLoading: s.isSubmitting,
            onPressed: () => controller.submitVehicleDocs(
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
