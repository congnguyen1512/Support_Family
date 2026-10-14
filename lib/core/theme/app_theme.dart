import 'package:family_guard/core/constants/app_colors.dart';
import 'package:family_guard/core/widgets/app_back_header.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      textTheme: GoogleFonts.publicSansTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppHeaderTheme.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppHeaderTheme.title,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 72,
        titleTextStyle: GoogleFonts.lexend(
          color: AppHeaderTheme.title,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        toolbarTextStyle: GoogleFonts.lexend(
          color: AppHeaderTheme.title,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(
          color: AppHeaderTheme.backIcon,
          size: 18,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppHeaderTheme.title,
          size: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
      ),
    );
  }
}
