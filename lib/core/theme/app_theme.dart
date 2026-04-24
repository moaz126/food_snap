import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_colors.dart';
import 'package:food_snap/core/constants/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    const scheme = ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightText,
      outline: AppColors.lightBorder,
      error: AppColors.lightCoral,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.lightText),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.lightText,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
      ),
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.label,
      ),
    );
  }

  static ThemeData get darkTheme {
    const scheme = ColorScheme.dark(
      primary: AppColors.darkPrimary,
      onPrimary: Colors.black,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      outline: AppColors.darkBorder,
      error: AppColors.darkCoral,
      onError: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.darkText),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkSurface2,
        contentTextStyle:
            AppTextStyles.body.copyWith(color: AppColors.darkText),
      ),
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.label,
      ),
    );
  }
}
