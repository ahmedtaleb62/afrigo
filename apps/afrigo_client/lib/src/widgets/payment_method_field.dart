import 'package:flutter/material.dart';

/// Cash / بنكيلي / bank settlement — no real payment gateway exists (or was
/// asked for) yet, this just records which of the three the client picked
/// so it lands on the order row instead of being silently assumed-cash.
const kPaymentMethods = {
  'cash': '💵 نقدًا',
  'baridimob': '📱 بنكيلي',
  'bank_transfer': '🏦 سداد مصرفي',
};

class PaymentMethodField extends StatelessWidget {
  const PaymentMethodField({super.key, required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 6, 20, 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('طريقة الدفع', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
              for (final entry in kPaymentMethods.entries)
                InkWell(
                  onTap: () => Navigator.of(ctx).pop(entry.key),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(child: Text(entry.value, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 14))),
                        if (entry.key == value) const Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 20),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD6D3D1), width: 1.5), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(kPaymentMethods[value] ?? kPaymentMethods['cash']!, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
            const Text('›', style: TextStyle(color: Color(0xFFA8A29E))),
          ],
        ),
      ),
    );
  }
}
