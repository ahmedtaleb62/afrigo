import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/taxi_flow_controller.dart';
import '../widgets/taxi_primary_button.dart';
import '../widgets/taxi_text_field.dart';

const _carTypes = ['Dacia Logan', 'Renault Symbol', 'Hyundai Accent', 'Peugeot 301', 'أخرى'];

/// Screen 48 — Vehicle verification docs.
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
  String _carType = _carTypes.first;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final vehicle = await ref.read(taxiFlowControllerProvider.notifier).fetchMyVehicle();
      if (vehicle == null || !mounted) return;
      _vehicleName.text = vehicle['vehicle_name'] as String? ?? '';
      _address.text = vehicle['address'] as String? ?? '';
      _plateNumber.text = vehicle['plate_number'] as String? ?? '';
      _notes.text = vehicle['notes'] as String? ?? '';
      final carType = vehicle['car_type'] as String?;
      final licenseUrl = vehicle['driving_license_url'] as String?;
      setState(() {
        if (carType != null && _carTypes.contains(carType)) _carType = carType;
      });
      ref.read(taxiFlowControllerProvider.notifier).setLicensePhoto(licenseUrl != null && licenseUrl.isNotEmpty);
    });
  }

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
    final controller = ref.read(taxiFlowControllerProvider.notifier);
    final s = ref.watch(taxiFlowControllerProvider);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 30, 20, 20),
      child: ListView(
        children: [
          const Text('توثيق المركبة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 6),
          const Text('أدخل بيانات مركبتك لمراجعتها من طرف الإدارة', style: TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 20),
          TaxiTextField(controller: _vehicleName, hint: 'اسم صاحب المركبة'),
          const SizedBox(height: 10),
          TaxiTextField(controller: _address, hint: 'العنوان'),
          const SizedBox(height: 10),
          InkWell(
            onTap: controller.toggleLicensePhoto,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD6D3D1), width: 1.5, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12)),
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
            decoration: BoxDecoration(color: const Color(0xFFFAFAF9), border: Border.all(color: const Color(0xFFE7E5E4), width: 1.5), borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _carType,
                isExpanded: true,
                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF1C1917)),
                items: _carTypes.map((t) => DropdownMenuItem(value: t, child: Text('نوع السيارة: $t'))).toList(),
                onChanged: (v) => setState(() => _carType = v ?? _carType),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TaxiTextField(controller: _plateNumber, hint: 'رقم اللوحة'),
          const SizedBox(height: 10),
          TaxiTextField(controller: _notes, hint: 'ملاحظات'),
          if (s.authError != null) ...[
            const SizedBox(height: 10),
            Text(s.authError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 20),
          TaxiPrimaryButton(
            label: 'إرسال للمراجعة',
            isLoading: s.isSubmitting,
            onPressed: () => controller.submitVehicleDocs(
              vehicleName: _vehicleName.text.trim(),
              address: _address.text.trim(),
              carType: _carType,
              plateNumber: _plateNumber.text.trim(),
              notes: _notes.text.trim(),
            ),
          ),
        ],
      ),
    );
  }
}
