import 'package:flutter/material.dart';

class CivicPulseTheme {
  static const Color primary = Color(0xFF001E40);
  static const Color primaryContainer = Color(0xFF003366);
  static const Color secondary = Color(0xFF8F4E00);
  static const Color secondaryContainer = Color(0xFFFE9832);
  static const Color tertiary = Color(0xFF012500);
  static const Color tertiaryContainer = Color(0xFF138808); // Ashoka Green
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color outline = Color(0xFF737780);

  static ThemeData get themeData {
    return ThemeData(
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryContainer,
        onPrimaryContainer: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: Colors.black,
        tertiary: tertiary,
        onTertiary: Colors.white,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: Colors.white,
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        surface: surface,
        onSurface: onSurface,
        outline: outline,
      ),
      scaffoldBackgroundColor: background,
      useMaterial3: true,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Public Sans', fontSize: 57, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(fontFamily: 'Public Sans', fontSize: 32, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontFamily: 'Public Sans', fontSize: 28, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontFamily: 'Public Sans', fontSize: 22, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontFamily: 'Public Sans', fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontFamily: 'Public Sans', fontSize: 14, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)), // Pill shape
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 1,
        shadowColor: const Color(0x14003366), // rgba(0,51,102,0.08)
      ),
    );
  }
}
