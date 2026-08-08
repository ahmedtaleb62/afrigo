import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/food_flow_controller.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/food_primary_button.dart';

/// Screen — Working hours, per-day open/closed toggle + hours, persisted
/// to `restaurants.opening_hours`.
class WorkingHoursScreen extends ConsumerStatefulWidget {
  const WorkingHoursScreen({super.key});

  @override
  ConsumerState<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends ConsumerState<WorkingHoursScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(foodFlowControllerProvider.notifier).loadWorkingHours());
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final hours = ref.watch(foodFlowControllerProvider.select((s) => s.workingHours));

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 6),
            child: Row(
              children: [
                BackCircleButton(onTap: controller.back),
                const SizedBox(width: 12),
                const Text('أوقات العمل', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              itemCount: hours.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final h = hours[i];
                final isOpen = h['open'] as bool;
                final is24h = h['from'] == '00:00' && h['to'] == '23:59';

                Future<void> pickTime(bool isFrom) async {
                  final current = (isFrom ? h['from'] : h['to']) as String;
                  final parts = current.split(':');
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: int.tryParse(parts[0]) ?? 10, minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0),
                  );
                  if (picked == null) return;
                  final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                  controller.setWorkingHoursTime(i, from: isFrom ? formatted : null, to: isFrom ? null : formatted);
                }

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E5E4)), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () => controller.toggleWorkingHoursDay(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 40,
                              height: 22,
                              padding: const EdgeInsets.all(2),
                              alignment: isOpen ? Alignment.centerLeft : Alignment.centerRight,
                              decoration: BoxDecoration(color: isOpen ? const Color(0xFF16A34A) : const Color(0xFFD6D3D1), borderRadius: BorderRadius.circular(11)),
                              child: Container(width: 18, height: 18, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(width: 60, child: Text(h['day'] as String, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13))),
                          if (!isOpen)
                            const Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('مغلق', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFFA8A29E))),
                              ),
                            )
                          else if (is24h)
                            const Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('مفتوح على مدار الساعة (مرن)', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF166534))),
                              ),
                            )
                          else
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(onTap: () => pickTime(true), child: Text(h['from'] as String, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF16A34A)))),
                                  const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('—', style: TextStyle(color: Color(0xFF78716C)))),
                                  InkWell(onTap: () => pickTime(false), child: Text(h['to'] as String, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF16A34A)))),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (isOpen) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => controller.toggleWorkingHours24h(i),
                          child: Row(
                            children: [
                              Icon(is24h ? Icons.check_box : Icons.check_box_outline_blank, size: 16, color: is24h ? const Color(0xFF16A34A) : const Color(0xFFA8A29E)),
                              const SizedBox(width: 6),
                              const Text('مفتوح على مدار الساعة (بدون وقت محدد)', style: TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF78716C))),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: FoodPrimaryButton(label: 'حفظ', onPressed: controller.saveWorkingHours),
          ),
        ],
      ),
    );
  }
}
