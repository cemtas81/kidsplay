import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom Bottom Navigation Bar implementing adaptive navigation
/// with contextual badge indicators for child-focused mobile applications.
class CustomBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when tab is tapped
  final ValueChanged<int> onTap;

  /// Type of bottom bar
  final CustomBottomBarType type;

  /// Whether to show badges on items
  final Map<int, int>? badges;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom selected item color
  final Color? selectedItemColor;

  /// Custom unselected item color
  final Color? unselectedItemColor;

  /// Elevation of the bottom bar
  final double elevation;

  /// Whether to show labels
  final bool showLabels;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.type = CustomBottomBarType.parent,
    this.badges,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 8.0,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on theme
    final bgColor = backgroundColor ??
        (isDark ? const Color(0xFF212621) : const Color(0xFFF5F7F5));
    final selectedColor = selectedItemColor ??
        (isDark ? const Color(0xFF8BAA8B) : const Color(0xFF6B8E6B));
    final unselectedColor = unselectedItemColor ??
        (isDark ? const Color(0xFFB8C5B8) : const Color(0xFF6B7B6B));

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x0AFFFFFF) : const Color(0x0A000000),
            offset: const Offset(0, -2),
            blurRadius: elevation,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(
              context,
              selectedColor,
              unselectedColor,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavigationItems(
    BuildContext context,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final items = _getNavigationItems();

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = currentIndex == index;
      final badgeCount = badges?[index];

      return Expanded(
        child: _NavigationItem(
          icon: item.icon,
          selectedIcon: item.selectedIcon,
          label: item.label,
          isSelected: isSelected,
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          badgeCount: badgeCount,
          showLabel: showLabels,
          onTap: () {
            onTap(index);
            _handleNavigation(context, index);
          },
        ),
      );
    }).toList();
  }

  List<_NavigationItemData> _getNavigationItems() {
    switch (type) {
      case CustomBottomBarType.parent:
        return [
          _NavigationItemData(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Home',
          ),
          _NavigationItemData(
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore_rounded,
            label: 'Activities',
          ),
          _NavigationItemData(
            icon: Icons.camera_alt_outlined,
            selectedIcon: Icons.camera_alt_rounded,
            label: 'Capture',
          ),
          _NavigationItemData(
            icon: Icons.analytics_outlined,
            selectedIcon: Icons.analytics_rounded,
            label: 'Progress',
          ),
          _NavigationItemData(
            icon: Icons.person_outline,
            selectedIcon: Icons.person_rounded,
            label: 'Profile',
          ),
        ];
      case CustomBottomBarType.child:
        return [
          _NavigationItemData(
            icon: Icons.play_circle_outline,
            selectedIcon: Icons.play_circle_rounded,
            label: 'Play',
          ),
          _NavigationItemData(
            icon: Icons.favorite_outline,
            selectedIcon: Icons.favorite_rounded,
            label: 'Favorites',
          ),
          _NavigationItemData(
            icon: Icons.star_outline,
            selectedIcon: Icons.star_rounded,
            label: 'Rewards',
          ),
        ];
      case CustomBottomBarType.caregiver:
        return [
          _NavigationItemData(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: 'Dashboard',
          ),
          _NavigationItemData(
            icon: Icons.schedule_outlined,
            selectedIcon: Icons.schedule_rounded,
            label: 'Schedule',
          ),
          _NavigationItemData(
            icon: Icons.child_care_outlined,
            selectedIcon: Icons.child_care_rounded,
            label: 'Children',
          ),
          _NavigationItemData(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            label: 'Settings',
          ),
        ];
    }
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (type) {
      case CustomBottomBarType.parent:
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
        }
        break;
      case CustomBottomBarType.child:
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/child-selection-dashboard');
            break;
          case 1:
            Navigator.pushNamed(context, '/parent-onboarding');
            break;
          case 2:
            Navigator.pushNamed(context, '/child-profile-creation');
            break;
        }
        break;
      case CustomBottomBarType.caregiver:
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/child-selection-dashboard');
            break;
          case 1:
            Navigator.pushNamed(context, '/parent-onboarding');
            break;
          case 2:
            Navigator.pushNamed(context, '/child-profile-creation');
            break;
          case 3:
            Navigator.pushNamed(context, '/parent-login');
            break;
        }
        break;
    }
  }
}

/// Individual navigation item widget
class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final int? badgeCount;
  final bool showLabel;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    this.badgeCount,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentColor = isSelected ? selectedColor : unselectedColor;
    final currentIcon =
        isSelected && selectedIcon != null ? selectedIcon! : icon;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedColor.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    currentIcon,
                    size: 24,
                    color: currentColor,
                  ),
                ),
                // Badge
                if (badgeCount != null && badgeCount! > 0)
                  Positioned(
                    right: 4,
                    top: 4,
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
                        badgeCount! > 99 ? '99+' : badgeCount.toString(),
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
            ),
            // Label
            if (showLabel) ...[
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: currentColor,
                  height: 1.0,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Data class for navigation items
class _NavigationItemData {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;

  const _NavigationItemData({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// Enum defining different types of bottom navigation bars
enum CustomBottomBarType {
  /// Navigation for parents with full feature access
  parent,

  /// Simplified navigation for children with large touch targets
  child,

  /// Navigation for extended caregivers with essential features
  caregiver,
}
