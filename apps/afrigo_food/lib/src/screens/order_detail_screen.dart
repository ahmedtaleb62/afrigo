import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../widgets/back_circle_button.dart';

/// Screen 69 — Order detail. Real `food_orders` row, resolved from
/// `FoodFlowState.selectedOrder` (set by `openOrderDetail`, kept live by
/// `watchOrders`'s Realtime stream — this screen updates automatically if
/// the order's status changes while it's open).
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final order = ref.watch(foodFlowControllerProvider.select((s) => s.selectedOrder));

    Widget line(String label, String price) => Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF5F5F4)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
              Text(price, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        );

    if (order == null) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
        child: Column(
          children: [
            Row(children: [BackCircleButton(onTap: controller.back), const SizedBox(width: 12)]),
            const Expanded(child: Center(child: Text('الطلب غير متاح', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C))))),
          ],
        ),
      );
    }

    final id = order['id'] as String;
    final shortId = '#${id.substring(0, 8)}';
    final items = (order['items'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final subtotal = (order['subtotal'] as num?)?.toStringAsFixed(0) ?? '0';
    final deliveryFee = (order['delivery_fee'] as num?)?.toStringAsFixed(0) ?? '0';
    final total = (order['total'] as num?)?.toStringAsFixed(0) ?? '0';
    final note = order['client_note'] as String?;
    final address = order['delivery_address'] as String?;
    final status = order['status'] as String? ?? '';
    final isPickup = order['is_pickup'] == true;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 54, 20, 20),
      child: ListView(
        children: [
          Row(
            children: [
              BackCircleButton(onTap: controller.back),
              const SizedBox(width: 12),
              Text('طلب $shortId', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(color: isPickup ? const Color(0xFFFEF9C3) : const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(999)),
            child: Text(
              isPickup ? '🏪 استلام من المطعم' : '🛵 توصيل',
              style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11, color: isPickup ? const Color(0xFF854D0E) : const Color(0xFF166534)),
            ),
          ),
          if (!isPickup && address != null) Text('التوصيل إلى: $address', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 6),
          for (final item in items) line('${item['name']} ×${item['qty']}', '${((item['price'] as num) * (item['qty'] as num)).toStringAsFixed(0)} أوقية'),
          const SizedBox(height: 10),
          if (note != null && note.isNotEmpty) Text('ملاحظة: $note', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
          const SizedBox(height: 10),
          line('المجموع الفرعي', '$subtotal أوقية'),
          line('رسوم التوصيل', '$deliveryFee أوقية'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الإجمالي', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 15)),
              Text('$total أوقية', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF166534))),
            ],
          ),
          const SizedBox(height: 20),
          if (status == 'pending_restaurant')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      if (await controller.rejectOrder(id)) controller.back();
                    },
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(14)),
                    child: const Text('رفض', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (await controller.acceptOrder(id)) controller.back();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, padding: const EdgeInsets.all(14)),
                    child: const Text('قبول', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            )
          else if (status == 'accepted' || status == 'preparing') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => status == 'accepted' ? controller.markOrderPreparing(id) : controller.markOrderReady(id),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, padding: const EdgeInsets.all(14)),
                child: Text(status == 'accepted' ? 'بدء التحضير' : 'الطلب جاهز', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  if (await controller.cancelOrder(id)) controller.back();
                },
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(14), side: const BorderSide(color: Color(0xFFDC2626))),
                child: const Text('إلغاء الطلب', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, color: Color(0xFFDC2626))),
              ),
            ),
          ] else if (status == 'ready' && isPickup)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (await controller.markOrderPickedUp(id)) controller.back();
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, padding: const EdgeInsets.all(14)),
                child: const Text('تم تسليم الطلب للزبون', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}
