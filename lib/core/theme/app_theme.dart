import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkOnPrimaryContainer,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkOnSecondary,
      secondaryContainer: AppColors.darkSecondaryContainer,
      onSecondaryContainer: AppColors.darkOnSecondaryContainer,
      tertiary: AppColors.darkTertiary,
      onTertiary: const Color(0xFF064E3B),
      tertiaryContainer: const Color(0xFF065F46),
      onTertiaryContainer: const Color(0xFFA7F3D0),
      error: const Color(0xFFF87171),
      onError: const Color(0xFF450A0A),
      errorContainer: const Color(0xFF7F1D1D),
      onErrorContainer: const Color(0xFFFEE2E2),
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      surfaceContainer: AppColors.darkSurfaceContainer,
      surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w700,
          color: AppColors.darkOnSurface,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(
            color: AppColors.darkOutlineVariant,
            width: 1.0,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedIconTheme: const IconThemeData(color: AppColors.darkPrimary),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.darkOnSurfaceVariant,
        ),
        indicatorColor: AppColors.darkPrimaryContainer,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkOutlineVariant,
        thickness: 1.0,
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightOnPrimaryContainer,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.lightOnSecondary,
      secondaryContainer: AppColors.lightSecondaryContainer,
      onSecondaryContainer: AppColors.lightOnSecondaryContainer,
      tertiary: AppColors.lightTertiary,
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFFD1FAE5),
      onTertiaryContainer: const Color(0xFF047857),
      error: const Color(0xFFDC2626),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFFEE2E2),
      onErrorContainer: const Color(0xFF991B1B),
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      surfaceContainer: AppColors.lightSurfaceContainer,
      surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w700,
          color: AppColors.lightOnSurface,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(
            color: AppColors.lightOutlineVariant,
            width: 1.0,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedIconTheme: const IconThemeData(color: AppColors.lightPrimary),
        unselectedIconTheme: const IconThemeData(
          color: AppColors.lightOnSurfaceVariant,
        ),
        indicatorColor: AppColors.lightPrimaryContainer,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.lightOnSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightOutlineVariant,
        thickness: 1.0,
      ),
    );
  }
}
