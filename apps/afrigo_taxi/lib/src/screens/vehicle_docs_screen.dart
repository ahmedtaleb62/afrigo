import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/context_ext.dart';
import '../state/taxi_flow_controller.dart';
import '../widgets/taxi_primary_button.dart';
import '../widgets/taxi_text_field.dart';

// Car brand names (plus the trailing 'أخرى'/"Other" entry) are persisted
// verbatim to `vehicles.car_type` — kept as fixed, unlocalized values (not
// routed through l10n) so the data written to the DB doesn't change
// depending on which language the driver happened to have selected.
const _carTypes = ['Dacia Logan', 'Renault Symbol', 'Hyundai Accent', 'Peugeot 301', 'أخرى'];

Future<void> _pickLicenseSource(BuildContext context, TaxiFlowController controller) async {
  final l10n = context.l10n;
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.camera_alt_outlined), title: Text(l10n.taxiTakePhoto, style: const TextStyle(fontFamily: 'Tajawal')), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
          ListTile(leading: const Icon(Icons.photo_library_outlined), title: Text(l10n.taxiPickFromGallery, style: const TextStyle(fontFamily: 'Tajawal')), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
        ],
      ),
    ),
  );
  if (source != null) await controller.pickAndUploadLicense(source);
}

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
    final l10n = context.l10n;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 30, 20, 20),
      child: ListView(
        children: [
          Text(l10n.taxiVehicleDocsTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 6),
          Text(l10n.taxiVehicleDocsDesc, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 20),
          TaxiTextField(controller: _vehicleName, hint: l10n.taxiVehicleOwnerNameHint),
          const SizedBox(height: 10),
          TaxiTextField(controller: _address, hint: l10n.taxiAddressHint),
          const SizedBox(height: 10),
          InkWell(
            onTap: s.licenseUploading ? null : () => _pickLicenseSource(context, controller),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD6D3D1), width: 1.5, style: BorderStyle.solid), borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  if (s.licenseUploading)
                    const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  else
                    Text(s.licensePhoto ? '✅' : '📷', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    s.licenseUploading ? l10n.taxiUploading : (s.licensePhoto ? l10n.taxiLicenseUploadedHint : l10n.taxiLicenseUploadPrompt),
                    style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF78716C)),
                  ),
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
                items: _carTypes.map((t) => DropdownMenuItem(value: t, child: Text(l10n.taxiCarTypePrefix(t)))).toList(),
                onChanged: (v) => setState(() => _carType = v ?? _carType),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TaxiTextField(controller: _plateNumber, hint: l10n.taxiPlateNumberHint),
          const SizedBox(height: 10),
          TaxiTextField(controller: _notes, hint: l10n.taxiNotesHint),
          if (s.authError != null) ...[
            const SizedBox(height: 10),
            Text(s.authError!, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFFDC2626))),
          ],
          const SizedBox(height: 20),
          TaxiPrimaryButton(
            label: l10n.taxiSubmitForReviewBtn,
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
