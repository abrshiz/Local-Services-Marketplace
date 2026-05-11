// THEME LOCK: light — source: domain signal (consumer marketplace, outdoor use, trust/clarity)
// Scaffold.backgroundColor = AppTheme.backgroundLight — ALL screens

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary brand colors
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryContainer = Color(0xFFD6E4FF);
  static const Color secondary = Color(0xFFFF6F00);
  static const Color secondaryContainer = Color(0xFFFFE0B2);

  // Semantic colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFE65100);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFC62828);
  static const Color errorContainer = Color(0xFFFFEBEE);

  // Light theme surfaces
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F7FA);
  static const Color backgroundLight = Color(0xFFF0F4F8);
  static const Color outlineLight = Color(0xFFCFD8DC);
  static const Color outlineVariantLight = Color(0xFFECEFF1);

  // Dark theme surfaces
  static const Color surfaceDark = Color(0xFF1E2A3A);
  static const Color backgroundDark = Color(0xFF0F1923);
  static const Color outlineDark = Color(0xFF37474F);

  // Text colors
  static const Color textPrimary = Color(0xFF1A237E);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color textMuted = Color(0xFF90A4AE);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Color(0xFF0D2B6B),
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: Color(0xFF6D2800),
      surface: surfaceLight,
      onSurface: Color(0xFF1A1A2E),
      surfaceContainerHighest: surfaceVariantLight,
      onSurfaceVariant: Color(0xFF546E7A),
      error: error,
      onError: Colors.white,
      errorContainer: errorContainer,
      outline: outlineLight,
      outlineVariant: outlineVariantLight,
      inverseSurface: Color(0xFF1E2A3A),
      onInverseSurface: Color(0xFFECEFF1),
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceLight,
      foregroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: outlineLight,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1A1A2E),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceVariantLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: outlineLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: outlineLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: const TextStyle(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      errorStyle: const TextStyle(color: error, fontSize: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceVariantLight,
      selectedColor: primaryContainer,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceLight,
      indicatorColor: primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primary,
          );
        }
        return GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primary, size: 22);
        }
        return const IconThemeData(color: textSecondary, size: 22);
      }),
      elevation: 3,
      shadowColor: outlineLight,
    ),
    dividerTheme: const DividerThemeData(
      color: outlineVariantLight,
      thickness: 1,
      space: 0,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF1A3A6B),
      onPrimaryContainer: Color(0xFFD6E4FF),
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF6D2800),
      onSecondaryContainer: Color(0xFFFFE0B2),
      surface: surfaceDark,
      onSurface: Color(0xFFE6EEF8),
      surfaceContainerHighest: Color(0xFF243447),
      onSurfaceVariant: Color(0xFF90A4AE),
      error: Color(0xFFEF9A9A),
      onError: Color(0xFF6D0000),
      outline: outlineDark,
      outlineVariant: Color(0xFF263238),
      inverseSurface: Color(0xFFE6EEF8),
      onInverseSurface: Color(0xFF1E2A3A),
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE6EEF8),
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE6EEF8),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFB0BEC5),
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF90A4AE),
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: const Color(0xFFE6EEF8),
      elevation: 0,
      scrolledUnderElevation: 1,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFE6EEF8),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceDark,
      indicatorColor: const Color(0xFF1A3A6B),
      elevation: 3,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryLight,
          );
        }
        return GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF90A4AE),
        );
      }),
    ),
  );
}