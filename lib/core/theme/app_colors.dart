import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF5B5BD6);
  static const primaryDark = Color(0xFF4343B5);
  static const primaryLight = Color(0xFFEEF0FF);
  static const accent = Color(0xFF06B6D4);

  static const background = Color(0xFFF4F6FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceElevated = Color(0xFFFAFBFF);

  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const border = Color(0xFFE8ECF4);

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  static const gradientStart = Color(0xFF5B5BD6);
  static const gradientEnd = Color(0xFF06B6D4);

  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkSurfaceElevated = Color(0xFF334155);
  static const darkTextPrimary = Color(0xFFF1F5F9);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkTextMuted = Color(0xFF64748B);
  static const darkBorder = Color(0xFF334155);
  static const darkPrimary = Color(0xFF818CF8);
  static const darkPrimaryLight = Color(0xFF312E81);

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x050F172A),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
}
