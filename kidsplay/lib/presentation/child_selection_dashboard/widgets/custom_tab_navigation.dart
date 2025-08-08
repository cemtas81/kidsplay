import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CustomTabNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const CustomTabNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: _buildTabItems(context),
      ),
    );
  }

  List<Widget> _buildTabItems(BuildContext context) {
    final tabs = [
      {'label': 'Dashboard', 'icon': 'dashboard'},
      {'label': 'Activities', 'icon': 'explore'},
      {'label': 'Progress', 'icon': 'analytics'},
      {'label': 'Settings', 'icon': 'settings'},
    ];

    return tabs.asMap().entries.map((entry) {
      final index = entry.key;
      final tab = entry.value;
      final isSelected = currentIndex == index;

      return Expanded(
        child: _TabItem(
          label: tab['label']!,
          iconName: tab['icon']!,
          isSelected: isSelected,
          onTap: () => onTabChanged(index),
        ),
      );
    }).toList();
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final String iconName;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.iconName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(4),
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isSelected
                  ? (isDark ? AppTheme.onPrimaryDark : AppTheme.onPrimaryLight)
                  : (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
              size: 20,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? (isDark
                        ? AppTheme.onPrimaryDark
                        : AppTheme.onPrimaryLight)
                    : (isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
