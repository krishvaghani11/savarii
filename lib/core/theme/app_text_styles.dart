import 'package:flutter/material.dart';
import 'package:savarii/core/theme/app_colors.dart';

class AppTextStyles {
  // ---------------------------------------------------------------------------
  // Headings
  // Use for major screen titles, prominent numbers (like wallet balance)
  // ---------------------------------------------------------------------------
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryDark,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryDark,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryDark,
  );

  // ---------------------------------------------------------------------------
  // Body Text
  // Use for standard paragraphs, list tile titles, form inputs
  // ---------------------------------------------------------------------------
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryDark,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryDark,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryGreyBlue,
  );

  // ---------------------------------------------------------------------------
  // Specialized Styles
  // Specific use cases like buttons, error messages, and tiny captions
  // ---------------------------------------------------------------------------
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryGreyBlue,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.dangerRed,
  );

  // ---------------------------------------------------------------------------
  // Helper methods for quick variations without rewriting the whole style
  // ---------------------------------------------------------------------------

  /// Returns a style with the Primary Accent color (Red)
  static TextStyle get textAccent =>
      bodyMedium.copyWith(color: AppColors.primaryAccent);

  /// Returns a style with White color (useful for text on dark backgrounds)
  static TextStyle get textWhite => bodyMedium.copyWith(color: AppColors.white);
}
