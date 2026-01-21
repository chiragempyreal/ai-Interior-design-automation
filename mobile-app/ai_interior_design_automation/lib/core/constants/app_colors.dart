import 'package:flutter/material.dart';
import 'brand_colors.dart';

/// App Colors - Mapped to DesignQuote AI Brand Guidelines
class AppColors {
  // Primary Colors (Forest Green)
  static const Color primary = BrandColors.primary; // #4A6C5D
  static const Color primaryDark = BrandColors.primaryDark;
  static const Color primaryLight = BrandColors.primaryLight;
  
  // Secondary/Accent Colors (Warm Beige)
  static const Color secondary = BrandColors.accent; // #D4A574
  static const Color accent = BrandColors.accent;
  
  // Background Colors
  static const Color background = BrandColors.background; // #F8F6F1
  static const Color surface = BrandColors.surface;
  static const Color surfaceVariant = BrandColors.surfaceVariant;
  
  // Text Colors
  static const Color textPrimary = BrandColors.textDark; // #2B3E3A
  static const Color textSecondary = BrandColors.textBody; // #5A5A5A
  static const Color textTertiary = BrandColors.textLight;
  static const Color textHint = BrandColors.textHint;
  
  // Border & Divider
  static const Color border = BrandColors.border;
  static const Color divider = BrandColors.divider;
  
  // State Colors
  static const Color success = BrandColors.success;
  static const Color warning = BrandColors.warning;
  static const Color error = BrandColors.error;
  static const Color info = BrandColors.info;
  
  // Gradients
  static const LinearGradient primaryGradient = BrandColors.primaryGradient;
  static const LinearGradient accentGradient = BrandColors.accentGradient;
}
