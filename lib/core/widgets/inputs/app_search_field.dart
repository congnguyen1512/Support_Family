import 'package:family_guard/core/widgets/inputs/app_text_input.dart';
import 'package:flutter/material.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hintText = 'Tìm kiếm',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.showClearButton = false,
    this.onClear,
    this.borderRadius = 14,
    this.fillColor,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.contentPadding,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool showClearButton;
  final VoidCallback? onClear;
  final double borderRadius;
  final Color? fillColor;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return AppTextInput(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
      borderRadius: borderRadius,
      fillColor: fillColor,
      enabledBorderColor: enabledBorderColor,
      focusedBorderColor: focusedBorderColor,
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      prefix: const Icon(Icons.search_rounded),
      suffix: showClearButton
          ? IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: onClear ?? () => controller?.clear(),
            )
          : null,
    );
  }
}
