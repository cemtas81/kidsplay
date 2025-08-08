import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom Tab Bar widget implementing progressive disclosure
/// with smooth transitions for child-focused mobile applications.
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// List of tab labels
  final List<String> tabs;

  /// Current selected tab index
  final int currentIndex;

  /// Callback when tab is tapped
  final ValueChanged<int> onTap;

  /// Type of tab bar
  final CustomTabBarType type;

  /// Whether tabs are scrollable
  final bool isScrollable;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom selected label color
  final Color? selectedLabelColor;

  /// Custom unselected label color
  final Color? unselectedLabelColor;

  /// Custom indicator color
  final Color? indicatorColor;

  /// Tab controller for external control
  final TabController? controller;

  /// Badge counts for tabs
  final Map<int, int>? badges;

  /// Custom icons for tabs
  final List<IconData>? icons;

  /// Whether to show icons
  final bool showIcons;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.type = CustomTabBarType.text,
    this.isScrollable = false,
    this.backgroundColor,
    this.selectedLabelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
    this.controller,
    this.badges,
    this.icons,
    this.showIcons = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on theme
    final bgColor = backgroundColor ??
        (isDark ? const Color(0xFF212621) : const Color(0xFFF5F7F5));
    final selectedColor = selectedLabelColor ??
        (isDark ? const Color(0xFF8BAA8B) : const Color(0xFF6B8E6B));
    final unselectedColor = unselectedLabelColor ??
        (isDark ? const Color(0xFFB8C5B8) : const Color(0xFF6B7B6B));
    final indicatorClr = indicatorColor ?? selectedColor;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x0AFFFFFF) : const Color(0x0A000000),
            offset: const Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
        ],
      ),
      child: _buildTabBar(
        context,
        selectedColor,
        unselectedColor,
        indicatorClr,
      ),
    );
  }

  Widget _buildTabBar(
    BuildContext context,
    Color selectedColor,
    Color unselectedColor,
    Color indicatorColor,
  ) {
    switch (type) {
      case CustomTabBarType.text:
        return _buildTextTabBar(
          context,
          selectedColor,
          unselectedColor,
          indicatorColor,
        );
      case CustomTabBarType.icon:
        return _buildIconTabBar(
          context,
          selectedColor,
          unselectedColor,
          indicatorColor,
        );
      case CustomTabBarType.mixed:
        return _buildMixedTabBar(
          context,
          selectedColor,
          unselectedColor,
          indicatorColor,
        );
      case CustomTabBarType.segmented:
        return _buildSegmentedTabBar(
          context,
          selectedColor,
          unselectedColor,
        );
    }
  }

  Widget _buildTextTabBar(
    BuildContext context,
    Color selectedColor,
    Color unselectedColor,
    Color indicatorColor,
  ) {
    return TabBar(
      controller: controller,
      tabs: tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final badgeCount = badges?[index];

        return Tab(
          child: _buildTabContent(
            label: label,
            badgeCount: badgeCount,
            isSelected: currentIndex == index,
          ),
        );
      }).toList(),
      isScrollable: isScrollable,
      labelColor: selectedColor,
      unselectedLabelColor: unselectedColor,
      indicatorColor: indicatorColor,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 3,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
      onTap: (index) {
        onTap(index);
        _handleTabNavigation(context, index);
      },
    );
  }

  Widget _buildIconTabBar(
    BuildContext context,
    Color selectedColor,
    Color unselectedColor,
    Color indicatorColor,
  ) {
    return TabBar(
      controller: controller,
      tabs: tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final icon = icons?[index] ?? Icons.circle_outlined;
        final badgeCount = badges?[index];

        return Tab(
          child: _buildTabContent(
            icon: icon,
            label: label,
            badgeCount: badgeCount,
            isSelected: currentIndex == index,
            showIcon: true,
          ),
        );
      }).toList(),
      isScrollable: isScrollable,
      labelColor: selectedColor,
      unselectedLabelColor: unselectedColor,
      indicatorColor: indicatorColor,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorWeight: 3,
      onTap: (index) {
        onTap(index);
        _handleTabNavigation(context, index);
      },
    );
  }

  Widget _buildMixedTabBar(
    BuildContext context,
    Color selectedColor,
    Color unselectedColor,
    Color indicatorColor,
  ) {
    return TabBar(
      controller: controller,
      tabs: tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final label = entry.value;
        final icon = icons?[index];
        final badgeCount = badges?[index];

        return Tab(
          child: _buildTabContent(
            icon: icon,
            label: label,
            badgeCount: badgeCount,
            isSelected: currentIndex == index,
            showIcon: icon != null,
          ),
        );
      }).toList(),
      isScrollable: isScrollable,
      labelColor: selectedColor,
      unselectedLabelColor: unselectedColor,
      indicatorColor: indicatorColor,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 3,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
      onTap: (index) {
        onTap(index);
        _handleTabNavigation(context, index);
      },
    );
  }

  Widget _buildSegmentedTabBar(
    BuildContext context,
    Color selectedColor,
    Color unselectedColor,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unselectedColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = currentIndex == index;
          final badgeCount = badges?[index];

          return Expanded(
            child: GestureDetector(
              onTap: () {
                onTap(index);
                _handleTabNavigation(context, index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? selectedColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: selectedColor.withValues(alpha: 0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: _buildTabContent(
                  label: label,
                  badgeCount: badgeCount,
                  isSelected: isSelected,
                  textColor: isSelected ? Colors.white : unselectedColor,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent({
    IconData? icon,
    required String label,
    int? badgeCount,
    required bool isSelected,
    bool showIcon = false,
    Color? textColor,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showIcon && icon != null) ...[
              Icon(
                icon,
                size: 20,
                color: textColor,
              ),
              const SizedBox(height: 4),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: showIcon ? 12 : 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: textColor,
                letterSpacing: 0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        // Badge
        if (badgeCount != null && badgeCount > 0)
          Positioned(
            right: -8,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFD67B7B), // Error color
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _handleTabNavigation(BuildContext context, int index) {
    // Handle navigation based on tab selection
    // This is a placeholder - implement actual navigation logic
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/child-selection-dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/parent-onboarding');
        break;
      case 2:
        Navigator.pushNamed(context, '/parent-registration');
        break;
      case 3:
        Navigator.pushNamed(context, '/parent-login');
        break;
      case 4:
        Navigator.pushNamed(context, '/child-profile-creation');
        break;
      default:
        Navigator.pushNamed(context, '/splash-screen');
        break;
    }
  }

  @override
  Size get preferredSize {
    switch (type) {
      case CustomTabBarType.text:
        return const Size.fromHeight(48);
      case CustomTabBarType.icon:
        return const Size.fromHeight(56);
      case CustomTabBarType.mixed:
        return const Size.fromHeight(64);
      case CustomTabBarType.segmented:
        return const Size.fromHeight(80);
    }
  }
}

/// Enum defining different types of tab bars
enum CustomTabBarType {
  /// Text-only tabs
  text,

  /// Icon-only tabs
  icon,

  /// Mixed icon and text tabs
  mixed,

  /// Segmented control style tabs
  segmented,
}
