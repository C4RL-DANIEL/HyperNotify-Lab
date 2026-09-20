// HyperNotify Lab - Tablet Layout Utilities
// Responsive layout helpers for tablet/phone adaptation

import 'package:flutter/material.dart';

class TabletLayout {
  /// Breakpoint for tablet layout (width >= 600dp)
  static const double tabletBreakpoint = 600;
  
  /// Breakpoint for desktop layout (width >= 840dp)
  static const double desktopBreakpoint = 840;
  
  /// Breakpoint for large desktop (width >= 1200dp)
  static const double largeDesktopBreakpoint = 1200;

  /// Check if current layout should use tablet UI
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    
    // Use shortest side for orientation-independent check
    return shortestSide >= tabletBreakpoint;
  }

  /// Check if current layout should use desktop UI
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktopBreakpoint;
  }

  /// Check if current layout should use large desktop UI
  static bool isLargeDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= largeDesktopBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isLargeDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 32);
    } else if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  /// Get responsive horizontal padding
  static double getHorizontalPadding(BuildContext context) {
    if (isLargeDesktop(context)) return 48;
    if (isDesktop(context)) return 32;
    if (isTablet(context)) return 24;
    return 16;
  }

  /// Get max content width for centered layouts
  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isLargeDesktop(context)) return 1000;
    if (isDesktop(context)) return 800;
    if (isTablet(context)) return 600;
    return width;
  }

  /// Get responsive grid cross-axis count
  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  /// Get responsive list item height
  static double getListItemHeight(BuildContext context) {
    if (isTablet(context)) return 80;
    return 72;
  }

  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    if (isLargeDesktop(context)) return 1.15;
    if (isDesktop(context)) return 1.1;
    if (isTablet(context)) return 1.05;
    return 1.0;
  }

  /// Get adaptive column count for master-detail
  static int getMasterDetailColumns(BuildContext context) {
    if (isLargeDesktop(context)) return 3; // Master + Detail + Sidebar
    if (isDesktop(context)) return 2; // Master + Detail
    if (isTablet(context)) return 2; // Master + Detail (collapsed master)
    return 1; // Phone: only one visible at a time
  }

  /// Check if master-detail should show both panes
  static bool shouldShowDetailPane(BuildContext context) {
    return isTablet(context);
  }

  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isLargeDesktop(context)) return 600;
    if (isDesktop(context)) return 500;
    if (isTablet(context)) return 450;
    return width * 0.9;
  }

  /// Get responsive bottom sheet height
  static double getBottomSheetHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    if (isTablet(context)) return height * 0.6;
    return height * 0.75;
  }

  /// Build responsive layout with sidebar
  static Widget buildResponsiveLayout({
    required BuildContext context,
    required Widget child,
    Widget? sidebar,
    double sidebarWidth = 280,
  }) {
    if (isTablet(context) && sidebar != null) {
      return Row(
        children: [
          SizedBox(
            width: sidebarWidth,
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: sidebar,
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: child),
        ],
      );
    }
    return child;
  }

  /// Build responsive two-pane layout
  static Widget buildTwoPaneLayout({
    required BuildContext context,
    required Widget primary,
    required Widget secondary,
    double primaryWidth = 320,
  }) {
    if (isTablet(context)) {
      return Row(
        children: [
          SizedBox(
            width: primaryWidth,
            child: primary,
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: secondary),
        ],
      );
    }
    // On phone, we'd typically use navigation to switch between panes
    // This is a simplified version - in practice you'd use a navigator
    return primary;
  }
}

/// Extension for easier access to tablet layout info
extension TabletLayoutExtension on BuildContext {
  bool get isTablet => TabletLayout.isTablet(this);
  bool get isDesktop => TabletLayout.isDesktop(this);
  bool get isLargeDesktop => TabletLayout.isLargeDesktop(this);
  EdgeInsets get responsivePadding => TabletLayout.getResponsivePadding(this);
  double get horizontalPadding => TabletLayout.getHorizontalPadding(this);
  double get maxContentWidth => TabletLayout.getMaxContentWidth(this);
  int get gridCrossAxisCount => TabletLayout.getGridCrossAxisCount(this);
}