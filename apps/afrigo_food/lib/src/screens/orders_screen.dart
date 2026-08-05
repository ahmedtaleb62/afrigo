import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../state/food_screen.dart';
import '../widgets/back_circle_button.dart';

const _readyStatusLabels = {
  'ready': 'جاهز — جارٍ البحث عن مندوب توصيل',
  'searching_livreur': 'جاهز — جارٍ البحث عن مندوب توصيل',
  'no_livreur_found': 'تعذّر العثور على مندوب توصيل',
  'out_for_delivery': 'في الطريق مع مندوب التوصيل',
};

/// Screen 68 — Incoming orders. Real `food_orders` rows, live via
/// `FoodFlowController.watchOrders`'s Realtime stream — see that
/// controller's header comment for why a plain table stream (not a
/// Broadcast channel) is the right tool here.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final s = ref.watch(foodFlowControllerProvider);
    final tab = s.orderTab;

    ref.listen(foodFlowControllerProvider.select((s) => s.actionError), (prev, next) {
      if (next == null) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next)));
      controller.clearActionError();
    });

    Widget tabChip(String label, OrderTab value, int count) {
      final selected = tab == value;
      return InkWell(
        onTap: () => controller.setOrderTab(value),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(color: selected ? const Color(0xFF0F3F23) : const Color(0xFFF0F2EF), borderRadius: BorderRadius.circular(999)),
          child: Text(
            count > 0 ? '$label ($count)' : label,
            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11, color: selected ? Colors.white : const Color(0xFF7C8574)),
          ),
        ),
      );
    }

    final orders = switch (tab) {
      OrderTab.newOrder => s.newOrders,
      OrderTab.prep => s.prepOrders,
      OrderTab.ready => s.readyOrders,
      OrderTab.done => s.doneOrders,
    };

    Widget body = orders.isEmpty
        ? const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: Text('لا توجد طلبات هنا الآن', style: TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF7C8574)))),
          )
        : Column(children: [for (final order in orders) _OrderCard(order: order, tab: tab)]);

    return Container(
      color: const Color(0xFFF8F9F8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 54, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BackCircleButton(onTap: controller.back),
                    const SizedBox(width: 12),
                    const Text('الطلبات الواردة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
                  ],
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      tabChip('جديدة', OrderTab.newOrder, s.newOrders.length),
                      const SizedBox(width: 6),
                      tabChip('قيد التحضير', OrderTab.prep, s.prepOrders.length),
                      const SizedBox(width: 6),
                      tabChip('جاهزة', OrderTab.ready, s.readyOrders.length),
                      const SizedBox(width: 6),
                      tabChip('مكتملة', OrderTab.done, s.doneOrders.length),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: body)),
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order, required this.tab});

  final Map<String, dynamic> order;
  final OrderTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final id = order['id'] as String;
    final shortId = '#${id.substring(0, 8)}';
    final total = (order['total'] as num?)?.toStringAsFixed(0) ?? '0';
    final items = (order['items'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final itemsSummary = items.map((i) => '${i['name']} ×${i['qty']}').join('، ');
    final status = order['status'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => controller.openOrderDetail(id),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('طلب $shortId', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14)),
                  Text('$total أوقية', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF176F3D))),
                ],
              ),
              const SizedBox(height: 6),
              Text(itemsSummary, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF7C8574))),
              const SizedBox(height: 10),
              if (tab == OrderTab.newOrder)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.rejectOrder(id),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
                          child: const Text('رفض', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFFDC2626))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.acceptOrder(id),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFF2AA35C), borderRadius: BorderRadius.circular(10)),
                          child: const Text('قبول', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                )
              else if (tab == OrderTab.prep && status == 'accepted')
                _ActionButton(label: 'بدء التحضير', onTap: () => controller.markOrderPreparing(id))
              else if (tab == OrderTab.prep && status == 'preparing')
                _ActionButton(label: 'الطلب جاهز', onTap: () => controller.markOrderReady(id))
              else
                Text(
                  tab == OrderTab.done ? 'تم التسليم' : (_readyStatusLabels[status] ?? status),
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF176F3D)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFF2AA35C), borderRadius: BorderRadius.circular(10)),
          child: Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
        ),
      ),
    );
  }
}
