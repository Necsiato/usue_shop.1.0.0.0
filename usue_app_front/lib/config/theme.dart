import 'package:flutter/material.dart';

import 'app_config.dart';

ThemeData buildAppTheme() {
  final primary = const Color(0xFFA4FF4A); // салатовый акцент
  final accent = const Color(0xFF5CFF93);
  final background = const Color(0xFF0F1115);
  final surface = const Color(0xFF1A1C21);

  final textTheme = Typography.englishLike2021.apply(
    displayColor: Colors.white,
    bodyColor: Colors.white,
    fontSizeFactor: AppConfig.baseFontSize / 14,
  );

  return ThemeData(
    colorScheme: ColorScheme.dark(
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
        color: Colors.white,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(
        fontSize: AppConfig.baseFontSize + 1,
        color: Colors.white,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontSize: AppConfig.baseFontSize + 6,
        fontWeight: FontWeight.bold,
      ),
      labelLarge: textTheme.labelLarge?.copyWith(color: Colors.white),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shadowColor: primary.withValues(alpha: 0.12),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF16181E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primary, width: 1.4),
      ),
      labelStyle: const TextStyle(color: Colors.white),
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
        side: BorderSide(color: primary.withValues(alpha: 0.6)),
        textStyle: textTheme.labelLarge?.copyWith(fontSize: AppConfig.baseFontSize),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.black,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF1F2229),
      selectedColor: primary.withValues(alpha: 0.18),
      labelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1C1F26),
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
