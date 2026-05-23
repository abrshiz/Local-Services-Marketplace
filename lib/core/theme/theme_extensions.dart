import 'package:flutter/material.dart';

/// Theme-aware colors — use instead of hardcoded [AppColors] for text and surfaces.
extension AppThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;

  TextStyle get bodyOnSurface => Theme.of(this).textTheme.bodyMedium!.copyWith(
        color: colors.onSurface,
      );

  TextStyle get titleOnSurface => Theme.of(this).textTheme.titleMedium!.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w700,
      );

  TextStyle get headlineOnSurface =>
      Theme.of(this).textTheme.titleLarge!.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          );
}
