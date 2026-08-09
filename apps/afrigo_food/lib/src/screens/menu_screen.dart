import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../state/dish.dart';
import '../state/food_flow_controller.dart';
import '../state/food_screen.dart';
import '../widgets/back_circle_button.dart';
import '../widgets/food_text_field.dart';

/// Screen 67 — Menu management.
///
/// Fully real: loads `restaurant_dish_categories`/`restaurant_dishes` for
/// the signed-in owner's restaurant on open, and every toggle/stock/add
/// action here writes straight back to Supabase.
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final _newDishName = TextEditingController();
  final _newDishPrice = TextEditingController();
  Uint8List? _newDishImage;
  String? _selectedCategoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(foodFlowControllerProvider.notifier).loadMenu());
  }

  @override
  void dispose() {
    _newDishName.dispose();
    _newDishPrice.dispose();
    super.dispose();
  }

  Future<void> _pickDishImage() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => _newDishImage = bytes);
    } catch (_) {
      // Previously unguarded — any failure (permission denial, a picker
      // platform exception) left the "اضغط لإضافة صورة" box looking
      // untouched with zero feedback, which is exactly what "لا تعمل" (it
      // doesn't work) looks like from the outside.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر فتح معرض الصور، تأكد من صلاحية الوصول للصور')));
    }
  }

  Future<void> _changeExistingDishImage(Dish dish) async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      await ref.read(foodFlowControllerProvider.notifier).updateDishImage(dish, bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر فتح معرض الصور، تأكد من صلاحية الوصول للصور')));
    }
  }

  Future<void> _saveDish() async {
    final image = _newDishImage;
    final categoryId = _selectedCategoryId;
    if (image == null || categoryId == null) return;
    setState(() => _saving = true);
    await ref.read(foodFlowControllerProvider.notifier).addDish(_newDishName.text, num.tryParse(_newDishPrice.text) ?? 0, image, categoryId);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _newDishImage = null;
    });
    _newDishName.clear();
    _newDishPrice.clear();
  }

  Future<void> _addCategoryThenSelect() async {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final before = ref.read(foodFlowControllerProvider).categories;
    await _promptNewCategory(context, controller);
    if (!mounted) return;
    final after = ref.read(foodFlowControllerProvider).categories;
    if (after.length > before.length) {
      setState(() => _selectedCategoryId = after.last.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(foodFlowControllerProvider.notifier);
    final s = ref.watch(foodFlowControllerProvider);
    _selectedCategoryId ??= s.categories.isNotEmpty ? s.categories.first.id : null;
    if (_selectedCategoryId != null && s.categories.every((c) => c.id != _selectedCategoryId)) {
      _selectedCategoryId = s.categories.isNotEmpty ? s.categories.first.id : null;
    }

    return Container(
      color: const Color(0xFFF5F5F4),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 54, 20, 12),
            child: Row(
              children: [
                BackCircleButton(onTap: controller.back),
                const SizedBox(width: 12),
                const Expanded(child: Text('إدارة القائمة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17))),
                InkWell(
                  onTap: controller.toggleAddDish,
                  customBorder: const CircleBorder(),
                  child: Container(width: 34, height: 34, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle), child: const Text('+', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white))),
                ),
              ],
            ),
          ),
          if (s.addDishOpen)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Column(
                children: [
                  InkWell(
                    onTap: _pickDishImage,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      height: 90,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(color: const Color(0xFFF5F5F4), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE7E5E4))),
                      child: _newDishImage != null
                          ? Image.memory(_newDishImage!, fit: BoxFit.cover)
                          : const Center(
                              child: Text('📷 اضغط لإضافة صورة الطبق (مطلوبة)', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF78716C))),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Was auto-assigned to whichever category happened to be
                  // first (or a generic auto-created one) — no way to
                  // actually choose where a new dish belongs.
                  if (s.categories.isEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _addCategoryThenSelect,
                        child: const Text('+ أضف تصنيفًا أولًا (مثال: مقبلات)', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE7E5E4)), borderRadius: BorderRadius.circular(10)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategoryId,
                          isExpanded: true,
                          style: const TextStyle(fontFamily: 'Tajawal', fontSize: 13, color: Color(0xFF1C1917)),
                          items: [
                            for (final c in s.categories) DropdownMenuItem(value: c.id, child: Text('التصنيف: ${c.name}')),
                            const DropdownMenuItem(value: '__new__', child: Text('+ تصنيف جديد')),
                          ],
                          onChanged: (v) {
                            if (v == '__new__') {
                              _addCategoryThenSelect();
                            } else {
                              setState(() => _selectedCategoryId = v);
                            }
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  FoodTextField(controller: _newDishName, hint: 'اسم الطبق الجديد', small: true),
                  const SizedBox(height: 8),
                  FoodTextField(controller: _newDishPrice, hint: 'السعر (أوقية)', small: true, keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_newDishImage == null || _selectedCategoryId == null || _saving) ? null : _saveDish,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white, padding: const EdgeInsets.all(12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: _saving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('حفظ الطبق', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            color: const Color(0xFFF0FDF4),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFDCFCE7)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🚚 رسوم التوصيل: ${s.deliveryFee} أوقية · ${s.prepTime}', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF166534))),
                InkWell(
                  onTap: () => controller.goTo(FoodScreen.deliverySettings),
                  child: const Text('تعديل ›', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF166534))),
                ),
              ],
            ),
          ),
          Expanded(
            child: s.menuLoading
                ? const Center(child: CircularProgressIndicator())
                : s.categories.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('لا توجد تصنيفات أو أطباق بعد', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF78716C))),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () => _promptNewCategory(context, controller),
                                child: const Text('+ إضافة تصنيف', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF16A34A))),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          for (final category in s.categories) ...[
                            _CategoryHeader(
                              category: category,
                              dishCount: s.dishes.where((d) => d.categoryId == category.id).length,
                              showAddButton: category == s.categories.first,
                              onAddCategory: () => _promptNewCategory(context, controller),
                            ),
                            const SizedBox(height: 8),
                            for (final dish in s.dishes.where((d) => d.categoryId == category.id))
                              _DishCard(dish: dish, controller: controller, onChangeImage: () => _changeExistingDishImage(dish)),
                            const SizedBox(height: 18),
                          ],
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

Future<void> _promptNewCategory(BuildContext context, FoodFlowController controller) async {
  final nameController = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('تصنيف جديد', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800)),
      content: TextField(controller: nameController, autofocus: true, decoration: const InputDecoration(hintText: 'مثال: مشروبات')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Tajawal'))),
        TextButton(onPressed: () => Navigator.pop(ctx, nameController.text), child: const Text('إضافة', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700))),
      ],
    ),
  );
  if (name != null && name.trim().isNotEmpty) await controller.addCategory(name);
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category, required this.dishCount, required this.showAddButton, required this.onAddCategory});
  final DishCategory category;
  final int dishCount;
  final bool showAddButton;
  final VoidCallback onAddCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE7E5E4))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                Flexible(child: Text(category.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1C1917)))),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(999)),
                  child: Text('$dishCount طبق', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 10, color: Color(0xFF166534))),
                ),
              ],
            ),
          ),
          if (showAddButton)
            InkWell(
              onTap: onAddCategory,
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text('+ تصنيف جديد', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF78716C))),
              ),
            ),
        ],
      ),
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({required this.dish, required this.controller, required this.onChangeImage});
  final Dish dish;
  final FoodFlowController controller;
  final VoidCallback onChangeImage;

  @override
  Widget build(BuildContext context) {
    final (badgeLabel, badgeBg, badgeFg) = dish.stockBadge;

    Widget miniSwitch(bool value, VoidCallback onTap) => InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 20,
            padding: const EdgeInsets.all(2),
            alignment: value ? Alignment.centerLeft : Alignment.centerRight,
            decoration: BoxDecoration(color: value ? const Color(0xFF16A34A) : const Color(0xFFE7E5E4), borderRadius: BorderRadius.circular(11)),
            child: Container(width: 16, height: 16, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onChangeImage,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(color: const Color(0xFFFEF9C3), borderRadius: BorderRadius.circular(10)),
              child: dish.hasImage
                  ? Image.network(dish.imageUrl!, fit: BoxFit.cover, errorBuilder: (context, error, stack) => const Text('🍽️', style: TextStyle(fontSize: 22)))
                  // Tappable even without a photo yet — dishes created
                  // before photos were required had no way to ever get one
                  // added; the small camera hint makes the thumbnail itself
                  // discoverable as a tap target.
                  : const Text('📷', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(dish.name, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 13))),
                    Text('${dish.price} أوقية', style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF166534))),
                  ],
                ),
                if (dish.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 8),
                    child: Text(dish.description, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 11, color: Color(0xFF78716C))),
                  )
                else
                  const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(color: Color(badgeBg), borderRadius: BorderRadius.circular(999)),
                      child: Text(badgeLabel, style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 10, color: Color(badgeFg))),
                    ),
                    const SizedBox(width: 10),
                    InkWell(onTap: () => controller.changeStock(dish, -1), child: Container(width: 20, height: 20, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF5F5F4), shape: BoxShape.circle), child: const Text('−', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 12)))),
                    SizedBox(width: 24, child: Text('${dish.stock}', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 11))),
                    InkWell(onTap: () => controller.changeStock(dish, 1), child: Container(width: 20, height: 20, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF5F5F4), shape: BoxShape.circle), child: const Text('+', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 12)))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Row(children: [const Text('متاح', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 10, color: Color(0xFF78716C))), const SizedBox(width: 6), miniSwitch(dish.isAvailable, () => controller.toggleDishAvailable(dish))]),
                    const SizedBox(width: 14),
                    Row(children: [const Text('🛵 للتوصيل', style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 10, color: Color(0xFF78716C))), const SizedBox(width: 6), miniSwitch(dish.availableForDelivery, () => controller.toggleDishDelivery(dish))]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
