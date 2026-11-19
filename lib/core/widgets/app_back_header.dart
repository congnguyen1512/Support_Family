import 'dart:math' as math;

import 'package:family_guard/core/constants/app_colors.dart';
import 'package:family_guard/core/widgets/buttons/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

export 'buttons/app_back_button.dart';

class AppHeaderTheme {
  const AppHeaderTheme._();

  static const background = Colors.transparent;
  static const title = AppColors.primary;
  static const backButton = Colors.transparent;
  static const backIcon = Color(0xFF1E293B);
  static const border = Color(0x14000000);
}

class AppBackLabel extends StatelessWidget {
  const AppBackLabel({
    super.key,
    required this.label,
    required this.onTap,
    this.color = AppHeaderTheme.title,
    this.iconSize = 18,
    this.fontSize = 17,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBackButton(onPressed: onTap, size: 36, iconSize: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.lexend(
                color: color,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBackHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const AppBackHeaderBar({
    super.key,
    required this.title,
    this.onBack,
    this.showLeading = true,
    this.backgroundColor = AppHeaderTheme.background,
    this.titleColor = AppHeaderTheme.title,
    this.padding = EdgeInsets.zero,
    this.trailing,
    this.height = 72,
    this.titleFontSize = 18,
    this.leadingSize = 42,
    this.contentPadding = EdgeInsets.zero,
    this.leadingAreaWidth = 40,
    this.trailingAreaWidth = 40,
    this.leadingInset = 8,
    this.titleTextAlign = TextAlign.center,
    this.showBottomBorder = true,
  });

  final String title;
  final VoidCallback? onBack;
  final bool showLeading;
  final Color backgroundColor;
  final Color titleColor;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;
  final double height;
  final double titleFontSize;
  final double leadingSize;
  final EdgeInsetsGeometry contentPadding;
  final double leadingAreaWidth;
  final double trailingAreaWidth;
  final double leadingInset;
  final TextAlign titleTextAlign;
  final bool showBottomBorder;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final effectiveLeadingWidth = showLeading ? (leadingAreaWidth + leadingInset) : 0.0;
    final effectiveTrailingWidth = trailing != null
        ? trailingAreaWidth
        : effectiveLeadingWidth;
    final titleHorizontalInset = math.max(
      effectiveLeadingWidth,
      effectiveTrailingWidth,
    );

    return Material(
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: showBottomBorder
                ? const Border(
                    bottom: BorderSide(color: AppHeaderTheme.border),
                  )
                : null,
          ),
          child: Padding(
            padding: padding,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: titleHorizontalInset,
                    ),
                    child: Padding(
                      padding: contentPadding,
                      child: SizedBox(
                        height: titleFontSize * 1.9,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              title,
                              maxLines: 1,
                              softWrap: false,
                              textAlign: titleTextAlign,
                              style: GoogleFonts.lexend(
                                color: titleColor,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: effectiveLeadingWidth,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: showLeading
                            ? Padding(
                                padding: EdgeInsets.only(left: leadingInset),
                                child: AppBackButton(
                                  onPressed: onBack,
                                  size: 40,
                                  iconSize: 18,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: effectiveTrailingWidth,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: trailing ?? const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
