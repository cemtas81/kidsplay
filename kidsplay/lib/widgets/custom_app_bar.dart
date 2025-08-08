import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget implementing Mindful Minimalism design philosophy
/// with adaptive behavior for child-focused mobile applications.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The type of app bar to display
  final CustomAppBarType type;

  /// The title text to display
  final String? title;

  /// Custom title widget (overrides title text)
  final Widget? titleWidget;

  /// Leading widget (usually back button or menu)
  final Widget? leading;

  /// List of action widgets
  final List<Widget>? actions;

  /// Whether to show the back button automatically
  final bool automaticallyImplyLeading;

  /// Background color override
  final Color? backgroundColor;

  /// Foreground color override
  final Color? foregroundColor;

  /// Elevation override
  final double? elevation;

  /// Whether to center the title
  final bool centerTitle;

  /// Bottom widget (usually TabBar)
  final PreferredSizeWidget? bottom;

  /// Callback for back button press
  final VoidCallback? onBackPressed;

  /// Badge count for notification indicator
  final int? badgeCount;

  /// Whether to show search action
  final bool showSearch;

  /// Search callback
  final VoidCallback? onSearchPressed;

  /// Profile image URL for profile type
  final String? profileImageUrl;

  /// Profile name for profile type
  final String? profileName;

  const CustomAppBar({
    super.key,
    this.type = CustomAppBarType.basic,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.bottom,
    this.onBackPressed,
    this.badgeCount,
    this.showSearch = false,
    this.onSearchPressed,
    this.profileImageUrl,
    this.profileName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on theme
    final bgColor = backgroundColor ??
        (isDark ? const Color(0xFF1A1F1A) : const Color(0xFFFAFBFA));
    final fgColor = foregroundColor ??
        (isDark ? const Color(0xFFFAFBFA) : const Color(0xFF2D3A2D));

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation ?? 0,
      scrolledUnderElevation: 2,
      shadowColor: isDark ? const Color(0x0AFFFFFF) : const Color(0x0A000000),
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      leading: _buildLeading(context, fgColor),
      title: _buildTitle(context, fgColor),
      actions: _buildActions(context, fgColor),
      bottom: bottom,
    );
  }

  Widget? _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) return leading;

    switch (type) {
      case CustomAppBarType.basic:
      case CustomAppBarType.search:
      case CustomAppBarType.profile:
        if (automaticallyImplyLeading && Navigator.of(context).canPop()) {
          return IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: foregroundColor,
              size: 20,
            ),
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            tooltip: 'Back',
            splashRadius: 20,
          );
        }
        break;
      case CustomAppBarType.menu:
        return IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: foregroundColor,
            size: 24,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
          tooltip: 'Menu',
          splashRadius: 20,
        );
      case CustomAppBarType.close:
        return IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: foregroundColor,
            size: 24,
          ),
          onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
          tooltip: 'Close',
          splashRadius: 20,
        );
    }
    return null;
  }

  Widget? _buildTitle(BuildContext context, Color foregroundColor) {
    if (titleWidget != null) return titleWidget;

    switch (type) {
      case CustomAppBarType.basic:
      case CustomAppBarType.menu:
      case CustomAppBarType.close:
        if (title != null) {
          return Text(
            title!,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
              letterSpacing: 0.15,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }
        break;
      case CustomAppBarType.search:
        return Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search activities...',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: foregroundColor.withValues(alpha: 0.6),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: foregroundColor.withValues(alpha: 0.6),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: foregroundColor,
            ),
          ),
        );
      case CustomAppBarType.profile:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (profileImageUrl != null) ...[
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(profileImageUrl!),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profileName != null)
                    Text(
                      profileName!,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: foregroundColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (title != null)
                    Text(
                      title!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: foregroundColor.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        );
    }
    return null;
  }

  List<Widget>? _buildActions(BuildContext context, Color foregroundColor) {
    final List<Widget> actionWidgets = [];

    // Add search action if enabled
    if (showSearch && type != CustomAppBarType.search) {
      actionWidgets.add(
        IconButton(
          icon: Icon(
            Icons.search_rounded,
            color: foregroundColor,
            size: 24,
          ),
          onPressed: onSearchPressed,
          tooltip: 'Search',
          splashRadius: 20,
        ),
      );
    }

    // Add notification action with badge
    if (type == CustomAppBarType.basic || type == CustomAppBarType.menu) {
      actionWidgets.add(
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: foregroundColor,
                size: 24,
              ),
              onPressed: () {
                // Navigate to notifications
                Navigator.pushNamed(context, '/parent-onboarding');
              },
              tooltip: 'Notifications',
              splashRadius: 20,
            ),
            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD67B7B), // Error color
                    borderRadius: BorderRadius.circular(10),
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
      );
    }

    // Add profile action
    if (type == CustomAppBarType.basic || type == CustomAppBarType.search) {
      actionWidgets.add(
        IconButton(
          icon: Icon(
            Icons.account_circle_outlined,
            color: foregroundColor,
            size: 24,
          ),
          onPressed: () {
            // Navigate to profile
            Navigator.pushNamed(context, '/child-profile-creation');
          },
          tooltip: 'Profile',
          splashRadius: 20,
        ),
      );
    }

    // Add custom actions
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets.isNotEmpty ? actionWidgets : null;
  }

  @override
  Size get preferredSize {
    double height = kToolbarHeight;
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }
}

/// Enum defining different types of app bars
enum CustomAppBarType {
  /// Basic app bar with title and actions
  basic,

  /// App bar with integrated search field
  search,

  /// App bar with profile information
  profile,

  /// App bar with menu button (for drawer)
  menu,

  /// App bar with close button (for modals)
  close,
}
