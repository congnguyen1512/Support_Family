import 'package:family_guard/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextInput extends StatelessWidget {
  const AppTextInput({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefix,
    this.suffix,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.autovalidateMode,
    this.maxLines = 1,
    this.minLines,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.borderRadius = 12,
    this.filled = true,
    this.fillColor,
    this.backgroundColor,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.textStyle,
    this.hintStyle,
    this.errorStyle,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefix;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onTap;
  final bool enabled;
  final bool readOnly;
  final AutovalidateMode? autovalidateMode;
  final int maxLines;
  final int? minLines;
  final EdgeInsetsGeometry contentPadding;
  final double borderRadius;
  final bool filled;
  final Color? fillColor;
  final Color? backgroundColor;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;

  @override
  Widget build(BuildContext context) {
    final Color resolvedFillColor =
        fillColor ?? backgroundColor ?? Theme.of(context).inputDecorationTheme.fillColor ?? const Color(0xFFF8FBFC);

    final Color resolvedEnabledBorderColor = enabledBorderColor ?? AppColors.divider;
    final Color resolvedFocusedBorderColor = focusedBorderColor ?? AppColors.primary;
    final Color resolvedErrorBorderColor = errorBorderColor ?? const Color(0xFFFF2D2D);

    final OutlineInputBorder enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: resolvedEnabledBorderColor),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: resolvedFocusedBorderColor),
    );

    final OutlineInputBorder errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(color: resolvedErrorBorderColor),
    );

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      enabled: enabled,
      readOnly: readOnly,
      autovalidateMode: autovalidateMode,
      maxLines: obscureText ? 1 : maxLines,
      minLines: obscureText ? null : minLines,
      style: textStyle ??
          GoogleFonts.publicSans(
            color: AppColors.borderDark,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefix,
        suffixIcon: suffix,
        filled: filled,
        fillColor: resolvedFillColor,
        contentPadding: contentPadding,
        hintStyle: hintStyle ??
            GoogleFonts.publicSans(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
        errorStyle: errorStyle ??
            GoogleFonts.publicSans(
              color: resolvedErrorBorderColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
        border: enabledBorder,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
      ),
    );
  }
}
