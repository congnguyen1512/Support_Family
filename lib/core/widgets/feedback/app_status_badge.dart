import 'package:family_guard/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppStatusBadgeType { neutral, success, warning, error, info }

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.type = AppStatusBadgeType.neutral,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.borderRadius = 999,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.textStyle,
  });

  final String label;
  final AppStatusBadgeType type;
  final Widget? icon;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final Color resolvedBackground = backgroundColor ?? _defaults.background;
    final Color resolvedForeground = foregroundColor ?? _defaults.foreground;
    final Color? resolvedBorder = borderColor ?? _defaults.border;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: resolvedBorder == null ? null : Border.all(color: resolvedBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: resolvedForeground, size: 14),
              child: icon!,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: textStyle ??
                GoogleFonts.publicSans(
                  color: resolvedForeground,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  _BadgeColors get _defaults {
    switch (type) {
      case AppStatusBadgeType.success:
        return const _BadgeColors(
          background: Color(0xFFE8F8EE),
          foreground: Color(0xFF15803D),
          border: Color(0xFF86EFAC),
        );
      case AppStatusBadgeType.warning:
        return const _BadgeColors(
          background: Color(0xFFFFF7E6),
          foreground: Color(0xFFB45309),
          border: Color(0xFFFCD34D),
        );
      case AppStatusBadgeType.error:
        return const _BadgeColors(
          background: Color(0xFFFEECEC),
          foreground: AppColors.danger,
          border: Color(0xFFFCA5A5),
        );
      case AppStatusBadgeType.info:
        return const _BadgeColors(
          background: Color(0xFFEAF6FF),
          foreground: AppColors.primary,
          border: Color(0xFF93C5FD),
        );
      case AppStatusBadgeType.neutral:
        return const _BadgeColors(
          background: Color(0xFFF1F5F9),
          foreground: AppColors.textMuted,
          border: Color(0xFFE2E8F0),
        );
    }
  }
}

class _BadgeColors {
  const _BadgeColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color? border;
}
