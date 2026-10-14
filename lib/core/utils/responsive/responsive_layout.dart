import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// ============================================================
/// RESPONSIVE LAYOUT WIDGET
/// Hiển thị layout khác nhau tùy theo breakpoint
/// ============================================================
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }
    if (ResponsiveHelper.isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}

/// Wrapper giới hạn content width — dùng cho tablet/desktop centering
class ResponsiveConstraint extends StatelessWidget {
  final Widget child;

  const ResponsiveConstraint({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveHelper.contentMaxWidth(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Responsive padding wrapper
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? overridePadding;

  const ResponsivePadding({super.key, required this.child, this.overridePadding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: overridePadding ?? ResponsiveHelper.pagePadding(context),
      child: child,
    );
  }
}
