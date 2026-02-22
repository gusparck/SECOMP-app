import 'package:flutter/material.dart';
import 'package:frontend/core/theme/extensions/app_spacing.dart';
import 'extensions/app_colors.dart';
// import 'extensions/app_spacing.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.indigo,
    extensions: const [
      AppColors(
        primary: Color(0xFF1E3C72),
        secondary: Color(0xFF2A5298),
        background: Colors.white,
        onBackground: Colors.black,
        accent: Color(0xFF4CAF50),
      ),
      AppSpacing(sm: 8, md: 16, lg: 24),
    ],
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF6366F1), // Indigo 500
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF3730A3),
      onPrimaryContainer: Color(0xFFE0E7FF),
      secondary: Color(0xFF38BDF8),
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF0284C7),
      onSecondaryContainer: Color(0xFFE0F2FE),
      surface: Color(0xFF1E293B), // Slate 800
      onSurface: Color(0xFFF8FAFC), // Slate 50
      error: Color(0xFFEF4444),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
    cardColor: const Color(0xFF1E293B), // Slate 800
    dividerColor: const Color(0xFF334155), // Slate 700
    extensions: const [
      AppColors(
        primary: Color(0xFF90CAF9),
        secondary: Color(0xFF64B5F6),
        background: Color(0xFF121212),
        onBackground: Colors.white,
        accent: Color(0xFF81C784),
      ),
      AppSpacing(sm: 8, md: 16, lg: 24),
    ],
  );
}
