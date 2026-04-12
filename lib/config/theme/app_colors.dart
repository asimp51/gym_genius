import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark Theme
  static const bgPrimary = Color(0xFF0A0E1A);
  static const bgSecondary = Color(0xFF111827);
  static const bgTertiary = Color(0xFF1E2636);

  static const accent = Color(0xFF3B82F6);
  static const accentSecondary = Color(0xFF22D3EE);

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFF43F5E);

  static const text1 = Color(0xFFF2F2F2);
  static const text2 = Color(0xFF94A3B8);
  static const text3 = Color(0xFF64748B);

  static const border = Color(0x14FFFFFF);
  static const borderFocus = Color(0x803B82F6);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentSecondary],
  );

  static const gradientHorizontal = LinearGradient(
    colors: [accent, accentSecondary],
  );

  // Light Theme
  static const lightBgPrimary = Color(0xFFF8FAFC);
  static const lightBgSecondary = Color(0xFFFFFFFF);
  static const lightBgTertiary = Color(0xFFF1F5F9);
  static const lightText1 = Color(0xFF0F172A);
  static const lightText2 = Color(0xFF475569);
  static const lightText3 = Color(0xFF94A3B8);
  static const lightBorder = Color(0x1A000000);
}
