import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iptv_provider.dart';
import '../models/category.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IPTVProvider>(
      builder: (context, iptvProvider, child) {
        if (!iptvProvider.hasCategories) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: iptvProvider.categories.length + 1, // +1 for "All" category
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCategoryChip(
                  context,
                  'All',
                  iptvProvider.selectedCategory == null,
                  () => iptvProvider.selectCategory(null),
                );
              }

              final category = iptvProvider.categories[index - 1];
              final isSelected = iptvProvider.selectedCategory?.id == category.id;

              return _buildCategoryChip(
                context,
                category.name,
                isSelected,
                () => iptvProvider.selectCategory(category),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
        checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
        labelStyle: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}