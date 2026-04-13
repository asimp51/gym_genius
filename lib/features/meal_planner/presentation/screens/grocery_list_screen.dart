import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_genius/config/theme/app_colors.dart';
import 'package:gym_genius/config/theme/app_typography.dart';
import 'package:gym_genius/config/theme/app_dimensions.dart';
import 'package:gym_genius/core/widgets/app_button.dart';
import 'package:gym_genius/features/meal_planner/domain/grocery_list_model.dart';
import 'package:gym_genius/features/meal_planner/presentation/providers/grocery_providers.dart';

class GroceryListScreen extends ConsumerWidget {
  const GroceryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(activeGroceryListProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Grocery List', style: AppTypography.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.text2),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing grocery list...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.text2),
            onPressed: () {
              ref.read(groceryRepositoryProvider).clearList();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: list == null
            ? _EmptyState(
                onGenerate: () {
                  ref
                      .read(groceryRepositoryProvider)
                      .generateFromActivePlan();
                },
              )
            : _GroceryListView(list: list),
      ),
    );
  }
}

class _GroceryListView extends ConsumerWidget {
  final GroceryList list;
  const _GroceryListView({required this.list});

  static const _categoryIcons = {
    'produce': '\ud83e\udd6c',
    'meat': '\ud83e\udd69',
    'dairy': '\ud83e\udd5b',
    'bakery': '\ud83c\udf5e',
    'pantry': '\ud83c\udf3e',
    'frozen': '\u2744\ufe0f',
    'beverages': '\ud83e\udd64',
    'other': '\ud83d\udecd\ufe0f',
  };

  static const _categoryLabels = {
    'produce': 'Produce',
    'meat': 'Meat & Seafood',
    'dairy': 'Dairy & Eggs',
    'bakery': 'Bakery',
    'pantry': 'Pantry',
    'frozen': 'Frozen',
    'beverages': 'Beverages',
    'other': 'Other',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byCategory = list.itemsByCategory;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.padding2XL,
        AppDimensions.paddingLG,
        AppDimensions.padding2XL,
        AppDimensions.bottomNavHeight + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.2),
                  AppColors.accentSecondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(list.name, style: AppTypography.h2),
                const SizedBox(height: 4),
                Text(
                  '${list.items.length} items  \u2022  ~\$${list.estimatedCost.toStringAsFixed(2)}',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: list.completionPercent,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.15),
                          color: AppColors.success,
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(list.completionPercent * 100).toInt()}%',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...byCategory.entries.map((entry) {
            return _CategorySection(
              category: entry.key,
              label: _categoryLabels[entry.key] ?? entry.key,
              emoji: _categoryIcons[entry.key] ?? '\ud83d\udecd\ufe0f',
              items: entry.value,
              onToggle: (id, v) {
                ref
                    .read(groceryRepositoryProvider)
                    .toggleItem(id, v);
              },
            );
          }),
          const SizedBox(height: 16),
          AppButton.secondary(
            label: 'Add Custom Item',
            icon: Icons.add,
            onPressed: () {
              _showAddItemDialog(context, ref);
            },
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text('Add Item', style: AppTypography.h3),
        content: TextField(
          controller: controller,
          style: AppTypography.body,
          decoration: InputDecoration(
            hintText: 'Item name',
            filled: true,
            fillColor: AppColors.bgTertiary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTypography.button.copyWith(color: AppColors.text3)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(groceryRepositoryProvider)
                    .addCustomItem(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: Text('Add',
                style: AppTypography.button.copyWith(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatefulWidget {
  final String category;
  final String label;
  final String emoji;
  final List<GroceryItem> items;
  final void Function(String id, bool checked) onToggle;

  const _CategorySection({
    required this.category,
    required this.label,
    required this.emoji,
    required this.items,
    required this.onToggle,
  });

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final checkedCount =
        widget.items.where((i) => i.isChecked).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                child: Row(
                  children: [
                    Text(widget.emoji,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: AppTypography.body
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '$checkedCount/${widget.items.length}',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.text3,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 1, color: AppColors.border),
              ...widget.items.map((item) => _GroceryItemRow(
                    item: item,
                    onToggle: (v) => widget.onToggle(item.id, v),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroceryItemRow extends StatelessWidget {
  final GroceryItem item;
  final ValueChanged<bool> onToggle;

  const _GroceryItemRow({required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onToggle(!item.isChecked),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color:
                    item.isChecked ? AppColors.success : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      item.isChecked ? AppColors.success : AppColors.text3,
                ),
              ),
              child: item.isChecked
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTypography.body.copyWith(
                  color: item.isChecked ? AppColors.text3 : AppColors.text1,
                  decoration:
                      item.isChecked ? TextDecoration.lineThrough : null,
                ),
                child: Text(item.name),
              ),
            ),
            Text(
              '${_fmt(item.amount)} ${item.unit}',
              style: AppTypography.caption,
            ),
            const SizedBox(width: 10),
            Text(
              '\$${item.estimatedPrice.toStringAsFixed(2)}',
              style: AppTypography.caption.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onGenerate;
  const _EmptyState({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('\ud83d\uded2', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('No grocery list yet', style: AppTypography.h2),
            const SizedBox(height: 6),
            Text(
              'Generate one from your active meal plan',
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Generate from Meal Plan',
              icon: Icons.auto_awesome,
              onPressed: onGenerate,
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}
