import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/client_bottom_nav.dart';
import '../core/context_ext.dart';

const _terminalStatuses = {
  'completed', 'delivered', 'cancelled', 'cancelled_by_client', 'cancelled_by_driver',
  'rejected_by_restaurant', 'no_driver_found', 'no_livreur_found',
};

const _statusLabels = {
  'completed': 'مكتملة',
  'delivered': 'مكتملة',
  'cancelled': 'ملغاة',
  'cancelled_by_client': 'ملغاة',
  'cancelled_by_driver': 'ملغاة',
  'rejected_by_restaurant': 'مرفوضة',
  'no_driver_found': 'لم يُعثر على سائق',
  'no_livreur_found': 'لم يُعثر على مندوب',
};

/// Screen 40 — Order history (active/past tabs). Real orders merged from
/// `rides`/`food_orders`/`delivery_requests` — replaces the design's 2
/// hardcoded demo cards.
class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(clientFlowControllerProvider.notifier).loadOrderHistory());
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);
    final isActive = s.orderTab == OrderTab.active;
    final orders = s.orderHistory.where((o) {
      final terminal = _terminalStatuses.contains(o['status']);
      return isActive ? !terminal : terminal;
    }).toList();

    Widget tabButton(String label, OrderTab value) {
      final selected = s.orderTab == value;
      return Expanded(
        child: InkWell(
          onTap: () => controller.setOrderTab(value),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(color: selected ? const Color(0xFF14532D) : const Color(0xFFF5F5F4), borderRadius: BorderRadius.circular(10)),
            child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: selected ? Colors.white : const Color(0xFF78716C))),
          ),
        ),
      );
    }

    (String, String) emojiAndLabel(Map<String, dynamic> o) {
      switch (o['order_type']) {
        case 'ride':
          return ('🚕', 'رحلة تكسي');
        case 'delivery_request':
          return ('📦', 'توصيل طرد');
        default:
          final restaurant = o['restaurants'];
          final name = restaurant is Map ? restaurant['name'] as String? : null;
          return ('🍔', name != null ? 'طلب من $name' : 'طلب طعام');
      }
    }

    String priceOf(Map<String, dynamic> o) {
      final v = (o['order_type'] == 'food_order' ? o['total'] : o['price']) as num?;
      return v == null ? '—' : '${v.toStringAsFixed(0)} أوقية';
    }

    String dateOf(Map<String, dynamic> o) {
      final iso = o['created_at'] as String?;
      final d = iso == null ? null : DateTime.tryParse(iso);
      if (d == null) return '';
      return '${d.year}/${d.month}/${d.day}';
    }

    Widget orderCard(Map<String, dynamic> o) {
      final (emoji, label) = emojiAndLabel(o);
      final statusLabel = _statusLabels[o['status']] ?? 'جارية';
      return Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x0F1C1917), blurRadius: 3)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$emoji $label', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(999)),
                  child: Text(statusLabel, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF166534))),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${dateOf(o)} · ${priceOf(o)}', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
            if (!isActive) ...[
              const SizedBox(height: 6),
              InkWell(
                onTap: () {
                  if (o['order_type'] == 'food_order') {
                    controller.goToFoodList();
                  } else if (o['order_type'] == 'delivery_request') {
                    // Delivery needs pickup/dropoff/recipient re-entered — a
                    // past order's fare and recipient details don't carry
                    // over, so this starts a fresh parcel request rather
                    // than jumping straight to a confirm screen that
                    // (wrongly) reused the taxi fare and blank recipient
                    // fields.
                    controller.goTo(
                      ClientScreen.parcelPickup,
                      patch: (s) => s.copyWith(
                        flowType: ClientFlowType.delivery,
                        pickupLat: null,
                        pickupLng: null,
                        pickupAddress: null,
                        pickupIsUserSet: false,
                      ),
                    );
                  } else {
                    controller.goTo(ClientScreen.rideConfirm, patch: (s) => s.copyWith(flowType: ClientFlowType.taxi));
                  }
                },
                child: const Text('إعادة الطلب ›', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF166534))),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      color: const Color(0xFFFAFAF9),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20, context.topGap(30), 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('طلباتي', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 14),
                Row(children: [tabButton('نشطة', OrderTab.active), const SizedBox(width: 8), tabButton('سابقة', OrderTab.past)]),
              ],
            ),
          ),
          Expanded(
            child: s.orderHistoryLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('📭', style: TextStyle(fontSize: 44)),
                              const SizedBox(height: 12),
                              Text(isActive ? 'لا توجد طلبات نشطة حاليًا' : 'لا توجد طلبات سابقة', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(isActive ? 'ستظهر طلباتك الجارية هنا' : 'ستظهر طلباتك المكتملة هنا', style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                            ],
                          ),
                        ),
                      )
                    : ListView(padding: const EdgeInsets.all(20), children: [for (final o in orders) orderCard(o)]),
          ),
          const ClientBottomNav(current: ClientScreen.orderHistory),
        ],
      ),
    );
  }
}
