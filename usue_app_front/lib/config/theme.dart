import 'package:flutter/material.dart';

import 'app_config.dart';

ThemeData buildAppTheme() {
  const primary = Color(0xFFA4FF4A);
  const accent = Color(0xFF5CFF93);
  const background = Color(0xFF0F1115);
  const surface = Color(0xFF1A1C21);
  const textColor = Color(0xFFE5E7EB);

  final textTheme = Typography.englishLike2021.apply(
    displayColor: textColor,
    bodyColor: textColor,
    fontSizeFactor: AppConfig.baseFontSize / 14,
  );

  return ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: surface,
      onPrimary: Colors.black,
      onSurface: Colors.white70,
    ),
    scaffoldBackgroundColor: background,
    useMaterial3: true,
    textTheme: textTheme.copyWith(
      bodyMedium: textTheme.bodyMedium?.copyWith(
        fontSize: AppConfig.baseFontSize,
        color: textColor,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        fontSize: AppConfig.baseFontSize + 1,
        color: textColor,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        color: textColor,
        fontSize: AppConfig.baseFontSize + 6,
        fontWeight: FontWeight.bold,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(color: textColor),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shadowColor: primary.withOpacity(0.12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF16181E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: textColor.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primary, width: 1.4),
      ),
      labelStyle: const TextStyle(color: textColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: textTheme.labelLarge?.copyWith(fontSize: AppConfig.baseFontSize),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: textTheme.labelLarge?.copyWith(fontSize: AppConfig.baseFontSize),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: BorderSide(color: primary.withOpacity(0.6)),
        textStyle: textTheme.labelLarge?.copyWith(fontSize: AppConfig.baseFontSize),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.black,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF1F2229),
      selectedColor: primary.withOpacity(0.18),
      labelStyle: const TextStyle(color: textColor),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1C1F26),
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: textColor),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
