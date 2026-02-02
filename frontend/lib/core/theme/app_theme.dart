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
    colorSchemeSeed: Colors.indigo,
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
