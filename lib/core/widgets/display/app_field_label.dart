import 'package:family_guard/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel({
    super.key,
    required this.text,
    this.margin,
    this.color = AppColors.borderDark,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.textAlign,
  });

  final String text;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final Widget label = Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.publicSans(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: 1.4,
      ),
    );

    if (margin == null) {
      return label;
    }

    return Padding(
      padding: margin!,
      child: label,
    );
  }
}
