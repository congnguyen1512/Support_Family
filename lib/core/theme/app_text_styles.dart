import 'package:family_guard/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle heading1() => GoogleFonts.beVietnamPro(
        color: AppColors.brand,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.75,
        height: 1.2,
      );

  static TextStyle title() => GoogleFonts.beVietnamPro(
        color: AppColors.brand,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.75,
        height: 1.2,
      );

  static TextStyle label() => GoogleFonts.publicSans(
        color: AppColors.borderDark,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle button() => GoogleFonts.publicSans(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.5,
      );

  static TextStyle body() => GoogleFonts.publicSans(
        color: AppColors.textMuted,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
      );
}
