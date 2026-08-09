import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/client_flow_controller.dart';
import '../../widgets/back_circle_button.dart';
import '../../core/context_ext.dart';

/// Screens 21/22 — Food list. Real `restaurants` rows (via the
/// `nearby_restaurants` RPC — real rating/distance included), loaded by
/// `ClientFlowController.loadRestaurants` when this screen is entered (see
/// `goToFoodList`, called from the Home screen's food card). Search text and
/// the filter/sort chip row are both real — applied client-side over the
/// already-fetched list (small dataset, no need for a round trip per
/// keystroke/filter tap).
class FoodListScreen extends ConsumerWidget {
  const FoodListScreen({super.key});

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> restaurants, String search, String filter) {
    var list = restaurants;
    final q = search.trim();
    if (q.isNotEmpty) {
      list = list.where((r) {
        final name = (r['name'] as String? ?? '');
        final cuisine = (r['cuisine_type'] as String? ?? '');
        return name.contains(q) || cuisine.contains(q);
      }).toList();
    }
    switch (filter) {
      case 'rating':
        list = [...list]..sort((a, b) => ((b['avg_rating'] as num?) ?? 0).compareTo((a['avg_rating'] as num?) ?? 0));
      case 'price_low':
        list = [...list]..sort((a, b) => ((a['min_order'] as num?) ?? 0).compareTo((b['min_order'] as num?) ?? 0));
      case 'price_high':
        list = [...list]..sort((a, b) => ((b['min_order'] as num?) ?? 0).compareTo((a['min_order'] as num?) ?? 0));
      case 'open':
        list = [...list]..sort((a, b) => ((a['distance_km'] as num?) ?? 999999).compareTo((b['distance_km'] as num?) ?? 999999));
        list = list.where((r) => r['is_open'] == true).toList();
      case 'closed':
        list = [...list]..sort((a, b) => ((a['distance_km'] as num?) ?? 999999).compareTo((b['distance_km'] as num?) ?? 999999));
        list = list.where((r) => r['is_open'] != true).toList();
      case 'nearest':
      default:
        // Nearest-first is the natural default order too, not just an
        // explicit filter choice — a client opening the list for the first
        // time should already see the closest restaurant on top.
        list = [...list]..sort((a, b) => ((a['distance_km'] as num?) ?? 999999).compareTo((b['distance_km'] as num?) ?? 999999));
    }
    return list;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);
    final restaurants = _applyFilters(s.restaurants, s.restaurantSearch, s.restaurantFilter);
    final l10n = context.l10n;
    final filters = <String, String>{
      'all': l10n.clientFoodFilterAll,
      'rating': l10n.clientFoodFilterTopRated,
      'nearest': l10n.clientFoodFilterNearest,
      'price_low': l10n.clientFoodFilterPriceLow,
      'price_high': l10n.clientFoodFilterPriceHigh,
      'open': l10n.clientFoodFilterOpenNow,
      'closed': l10n.clientFoodFilterClosedNow,
    };

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
                Row(
                  children: [
                    BackCircleButton(onTap: controller.back),
                    const SizedBox(width: 12),
                    Text(l10n.clientFoodListTitle, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  onChanged: controller.setRestaurantSearch,
                  style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13),
                  decoration: InputDecoration(
                    hintText: l10n.clientFoodSearchHint,
                    hintStyle: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFFA8A29E)),
                    filled: true,
                    fillColor: const Color(0xFFFAFAF9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFFA8A29E)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE7E5E4), width: 1.5)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE7E5E4), width: 1.5)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final entry in filters.entries) ...[
                        _FilterChip(entry.value, selected: s.restaurantFilter == entry.key, onTap: () => controller.setRestaurantFilter(entry.key)),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: s.restaurantsLoading
                ? const Center(child: CircularProgressIndicator())
                : restaurants.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🍽️', style: TextStyle(fontSize: 52)),
                              const SizedBox(height: 14),
                              Text(
                                s.restaurants.isEmpty ? l10n.clientFoodEmptyNoRestaurants : l10n.clientFoodEmptyNoMatches,
                                style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                s.restaurants.isEmpty ? l10n.clientFoodEmptyTryLater : l10n.clientFoodEmptyTryDifferentSearch,
                                style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF78716C)),
                              ),
                              const SizedBox(height: 18),
                              TextButton(
                                onPressed: controller.loadRestaurants,
                                style: TextButton.styleFrom(backgroundColor: const Color(0xFFF5F5F4), padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12)),
                                child: Text(l10n.commonRetry, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          for (final r in restaurants)
                            _RestaurantCard(
                              name: r['name'] as String? ?? '',
                              subtitle: l10n.clientFoodRestaurantSubtitle(r['cuisine_type'] as String? ?? '', (r['min_order'] as num?) ?? 0, (r['delivery_fee'] as num?) ?? 0),
                              rating: (r['avg_rating'] as num?)?.toDouble() ?? 0,
                              ratingsCount: (r['ratings_count'] as num?)?.toInt() ?? 0,
                              distanceKm: (r['distance_km'] as num?)?.toDouble(),
                              isOpen: r['is_open'] == true,
                              onTap: () => controller.openRestaurant(r['id'] as String, r['name'] as String? ?? ''),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(this.label, {this.selected = false, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: selected ? const Color(0xFF14532D) : const Color(0xFFF5F5F4), borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: TextStyle(fontFamily: 'Tajawal', fontWeight: selected ? FontWeight.w700 : FontWeight.w600, fontSize: 12, color: selected ? Colors.white : const Color(0xFF1C1917))),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.ratingsCount,
    required this.distanceKm,
    required this.isOpen,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final double rating;
  final int ratingsCount;
  final double? distanceKm;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F1C1917), blurRadius: 3)]),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFACC15), Color(0xFFFDE047)])),
                  alignment: Alignment.center,
                  child: const Text('🍽️', style: TextStyle(fontSize: 34)),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: isOpen ? const Color(0xFFDCFCE7) : const Color(0xFFF5F5F4), borderRadius: BorderRadius.circular(999)),
                    child: Text(isOpen ? l10n.clientFoodOpenBadge : l10n.clientFoodClosedBadge, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11, color: isOpen ? const Color(0xFF166534) : const Color(0xFF78716C))),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 14))),
                      if (ratingsCount > 0)
                        Row(
                          children: [
                            Text(rating.toStringAsFixed(1), style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF1C1917))),
                            const SizedBox(width: 2),
                            const Text('⭐', style: TextStyle(fontSize: 11)),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    distanceKm == null ? subtitle : l10n.clientFoodDistanceSuffix(subtitle, distanceKm!.toStringAsFixed(1)),
                    style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
