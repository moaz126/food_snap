import 'package:flutter/material.dart';
import 'package:food_snap/core/constants/app_colors.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color text;
  final Color textSub;
  final Color textMuted;
  final Color border;
  final Color surface;
  final Color surface2;
  final Color primary;
  final Color primaryBg;
  final Color amber;
  final Color amberBg;
  final Color coral;
  final Color coralBg;
  final Color green;
  final Color greenBg;

  const AppPalette({
    required this.text,
    required this.textSub,
    required this.textMuted,
    required this.border,
    required this.surface,
    required this.surface2,
    required this.primary,
    required this.primaryBg,
    required this.amber,
    required this.amberBg,
    required this.coral,
    required this.coralBg,
    required this.green,
    required this.greenBg,
  });

  static const light = AppPalette(
    text: AppColors.lightText,
    textSub: AppColors.lightTextSub,
    textMuted: AppColors.lightTextMuted,
    border: AppColors.lightBorder,
    surface: AppColors.lightSurface,
    surface2: AppColors.lightBorder,
    primary: AppColors.lightPrimary,
    primaryBg: AppColors.lightPrimaryBg,
    amber: AppColors.lightAmber,
    amberBg: AppColors.lightAmberBg,
    coral: AppColors.lightCoral,
    coralBg: AppColors.lightCoralBg,
    green: AppColors.lightGreen,
    greenBg: AppColors.lightGreenBg,
  );

  static const dark = AppPalette(
    text: AppColors.darkText,
    textSub: AppColors.darkTextSub,
    textMuted: AppColors.darkTextMuted,
    border: AppColors.darkBorder,
    surface: AppColors.darkSurface,
    surface2: AppColors.darkSurface2,
    primary: AppColors.darkPrimary,
    primaryBg: AppColors.darkPrimaryBg,
    amber: AppColors.darkAmber,
    amberBg: AppColors.darkAmberBg,
    coral: AppColors.darkCoral,
    coralBg: AppColors.darkCoralBg,
    green: AppColors.darkGreen,
    greenBg: AppColors.darkGreenBg,
  );

  @override
  AppPalette copyWith({
    Color? text,
    Color? textSub,
    Color? textMuted,
    Color? border,
    Color? surface,
    Color? surface2,
    Color? primary,
    Color? primaryBg,
    Color? amber,
    Color? amberBg,
    Color? coral,
    Color? coralBg,
    Color? green,
    Color? greenBg,
  }) {
    return AppPalette(
      text: text ?? this.text,
      textSub: textSub ?? this.textSub,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      primary: primary ?? this.primary,
      primaryBg: primaryBg ?? this.primaryBg,
      amber: amber ?? this.amber,
      amberBg: amberBg ?? this.amberBg,
      coral: coral ?? this.coral,
      coralBg: coralBg ?? this.coralBg,
      green: green ?? this.green,
      greenBg: greenBg ?? this.greenBg,
    );
  }

  @override
  AppPalette lerp(covariant ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }

    return AppPalette(
      text: Color.lerp(text, other.text, t) ?? text,
      textSub: Color.lerp(textSub, other.textSub, t) ?? textSub,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      border: Color.lerp(border, other.border, t) ?? border,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surface2: Color.lerp(surface2, other.surface2, t) ?? surface2,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryBg: Color.lerp(primaryBg, other.primaryBg, t) ?? primaryBg,
      amber: Color.lerp(amber, other.amber, t) ?? amber,
      amberBg: Color.lerp(amberBg, other.amberBg, t) ?? amberBg,
      coral: Color.lerp(coral, other.coral, t) ?? coral,
      coralBg: Color.lerp(coralBg, other.coralBg, t) ?? coralBg,
      green: Color.lerp(green, other.green, t) ?? green,
      greenBg: Color.lerp(greenBg, other.greenBg, t) ?? greenBg,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get appPalette => Theme.of(this).extension<AppPalette>()!;
}
