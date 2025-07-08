import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color forestGreen = Color(0xFF007A4D);
  static const Color darkGray = Color(0xFF333333);
  static const Color white = Colors.white;
}

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.white,
        primaryColor: AppColors.forestGreen,
        colorScheme: ColorScheme.light(
          primary: AppColors.forestGreen,
          secondary: AppColors.darkGray,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            color: AppColors.forestGreen,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          iconTheme: IconThemeData(color: AppColors.forestGreen),
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.poppins(
            color: AppColors.darkGray,
            fontSize: 16,
          ),
          bodyMedium: GoogleFonts.poppins(
            color: AppColors.darkGray,
            fontSize: 14,
          ),
          titleLarge: GoogleFonts.notoNaskhArabic(
            color: AppColors.forestGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: GoogleFonts.notoNaskhArabic(
            color: AppColors.forestGreen,
            fontSize: 18,
          ),
        ),
      );
} 