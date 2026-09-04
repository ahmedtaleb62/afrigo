import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/context_ext.dart';
import '../state/taxi_flow_controller.dart';
import '../widgets/taxi_primary_button.dart';
import '../widgets/taxi_text_field.dart';

/// Screen 58 — Rate customer.
class RateCustomerScreen extends ConsumerStatefulWidget {
  const RateCustomerScreen({super.key});

  @override
  ConsumerState<RateCustomerScreen> createState() => _RateCustomerScreenState();
}

class _RateCustomerScreenState extends ConsumerState<RateCustomerScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(taxiFlowControllerProvider.notifier);
    final rating = ref.watch(taxiFlowControllerProvider.select((s) => s.custRating));
    final clientName = ref.watch(taxiFlowControllerProvider.select((s) => s.clientName)) ?? '';
    final l10n = context.l10n;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 36, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: 64, height: 64, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF5F5F4), shape: BoxShape.circle), child: const Text('👩', style: TextStyle(fontSize: 26))),
          const SizedBox(height: 14),
          Text('${l10n.taxiRateCustomerTitle}${clientName.isNotEmpty ? ': $clientName' : ''}', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = rating >= i + 1;
              return InkWell(
                onTap: () => controller.rateCustomer(i + 1),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(filled ? '⭐' : '☆', style: const TextStyle(fontSize: 30))),
              );
            }),
          ),
          const SizedBox(height: 24),
          TaxiTextField(hint: l10n.taxiCommentHint, controller: _commentController),
          const Spacer(),
          TaxiPrimaryButton(label: l10n.taxiSendBtn, onPressed: () => controller.finishRateCustomer(comment: _commentController.text)),
        ],
      ),
    );
  }
}
