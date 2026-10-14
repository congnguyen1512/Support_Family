import 'package:flutter/material.dart';

/// ============================================================
/// RESPONSIVE HELPER (DISABLED)
///
/// Giữ API cũ để không vỡ import, nhưng toàn bộ xử lý responsive
/// đã bị tắt: trả về giá trị cố định theo base design.
/// ============================================================
class ResponsiveHelper {
  ResponsiveHelper._();

  // ─── Base design dimensions (Figma frame size) ────────────
  static const double _baseWidth  = 402.0;
  static const double _baseHeight = 874.0;

    // ─── Screen dimensions (fixed) ────────────────────────────
  static double screenWidth(BuildContext context) =>
      _baseWidth;
  static double screenHeight(BuildContext context) =>
      _baseHeight;

    // ─── Breakpoints (responsive disabled) ────────────────────
  static bool isMobile(BuildContext context) =>
      true;
  static bool isTablet(BuildContext context) =>
      false;
  static bool isDesktop(BuildContext context) =>
      false;

  /// Màn hình nhỏ (iPhone SE, 320–360px)
  static bool isSmallPhone(BuildContext context) =>
      false;

  /// Màn hình lớn (iPhone 16 Pro Max, >414px)
  static bool isLargePhone(BuildContext context) =>
      false;

  // ─── Font size (fixed) ────────────────────────────────────
  static double sp(BuildContext context, double size) {
    return size;
  }

  // ─── Width / Height percentages (fixed by base design) ────
  /// % của screen width
  static double wp(BuildContext context, double percent) =>
      _baseWidth * percent / 100;

  /// % của screen height
  static double hp(BuildContext context, double percent) =>
      _baseHeight * percent / 100;

  // ─── Padding (fixed) ──────────────────────────────────────
  static EdgeInsets pagePadding(BuildContext context) {
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  static EdgeInsets cardPadding(BuildContext context) {
    return const EdgeInsets.all(16);
  }

  static double horizontalPadding(BuildContext context) {
    return 16;
  }

  // ─── Grid columns (fixed) ─────────────────────────────────
  static int gridColumns(BuildContext context) {
    return 2;
  }

  // ─── Border radius (fixed) ────────────────────────────────
  static double radius(BuildContext context, double base) {
    return base;
  }

  // ─── Icon size (fixed) ────────────────────────────────────
  static double iconSize(BuildContext context, double base) =>
      base;

  // ─── Minimum tap target (accessibility) ──────────────────
  static const double minTapTarget = 48.0;

  // ─── Bottom nav height ────────────────────────────────────
  static double bottomNavHeight(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return 60 + bottomPadding;
  }

  // ─── Content max width (fixed full width) ─────────────────
  static double contentMaxWidth(BuildContext context) {
    return double.infinity;
  }
}
