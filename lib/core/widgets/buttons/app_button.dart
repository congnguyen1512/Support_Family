import 'package:family_guard/core/constants/app_colors.dart';
import 'package:family_guard/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.width = double.infinity,
    this.height = 48,
    this.borderRadius = 12,
    this.padding,
    this.margin,
    this.leading,
    this.trailing,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.elevation = 0,
    this.shadowColor,
    this.isLoading = false,
    this.loadingIndicator,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? leading;
  final Widget? trailing;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double elevation;
  final Color? shadowColor;
  final bool isLoading;
  final Widget? loadingIndicator;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final Color resolvedBackgroundColor = backgroundColor ?? _resolveBackgroundColor();
    final Color resolvedForegroundColor = foregroundColor ?? _resolveForegroundColor();
    final Color? resolvedBorderColor = borderColor ?? _resolveBorderColor();

    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: resolvedBackgroundColor,
      foregroundColor: resolvedForegroundColor,
      disabledBackgroundColor: resolvedBackgroundColor.withAlpha(120),
      disabledForegroundColor: resolvedForegroundColor.withAlpha(160),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: resolvedBorderColor == null
            ? BorderSide.none
            : BorderSide(color: resolvedBorderColor),
      ),
      elevation: elevation,
      shadowColor: shadowColor ?? const Color(0x3300ADB2),
      padding: padding,
    );

    final Widget content = isLoading
        ? loadingIndicator ??
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(resolvedForegroundColor),
              ),
            )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle ?? AppTextStyles.button().copyWith(color: resolvedForegroundColor),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          );

    final Widget button = SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: style,
        child: content,
      ),
    );

    if (margin == null) {
      return button;
    }

    return Padding(
      padding: margin!,
      child: button,
    );
  }

  Color _resolveBackgroundColor() {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.secondary:
        return Colors.white;
      case AppButtonVariant.danger:
        return AppColors.danger;
      case AppButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  Color _resolveForegroundColor() {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.secondary:
      case AppButtonVariant.ghost:
        return AppColors.borderDark;
    }
  }

  Color? _resolveBorderColor() {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return null;
      case AppButtonVariant.secondary:
        return AppColors.divider;
      case AppButtonVariant.ghost:
        return Colors.transparent;
    }
  }
}

class AppPrimaryButton extends AppButton {
  const AppPrimaryButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.width,
    super.height,
    super.borderRadius,
    super.padding,
    super.margin,
    super.leading,
    super.trailing,
    super.textStyle,
    super.backgroundColor,
    super.foregroundColor,
    super.borderColor,
    super.elevation,
    super.shadowColor,
    super.isLoading,
    super.loadingIndicator,
  }) : super(variant: AppButtonVariant.primary);
}
