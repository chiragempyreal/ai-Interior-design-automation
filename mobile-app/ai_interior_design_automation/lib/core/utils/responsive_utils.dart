import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
class ResponsiveUtils {
  /// Get responsive padding based on screen width
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return const EdgeInsets.all(16); // Small phones
    } else if (width < 400) {
      return const EdgeInsets.all(20); // Medium phones
    } else {
      return const EdgeInsets.all(24); // Large phones & tablets
    }
  }

  /// Get responsive horizontal padding
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (width < 400) {
      return const EdgeInsets.symmetric(horizontal: 20);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return baseSize * 0.9; // Slightly smaller on small screens
    } else if (width > 600) {
      return baseSize * 1.1; // Slightly larger on tablets
    }
    return baseSize;
  }

  /// Check if screen is small
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Check if screen is tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  /// Get responsive spacing
  static double getSpacing(BuildContext context, double baseSpacing) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return baseSpacing * 0.75;
    }
    return baseSpacing;
  }

  /// Get safe max width for content
  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) {
      return 600; // Max width for tablets
    }
    return width;
  }

  /// Get responsive card width for horizontal lists
  static double getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return 140; // Smaller cards on small screens
    } else if (width < 400) {
      return 150;
    } else {
      return 160;
    }
  }

  /// Get responsive icon size
  static double getIconSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) {
      return baseSize * 0.9;
    }
    return baseSize;
  }
}

/// Extension on BuildContext for easy access
extension ResponsiveExtension on BuildContext {
  bool get isSmallScreen => MediaQuery.of(this).size.width < 360;
  bool get isTablet => MediaQuery.of(this).size.width >= 600;
  
  EdgeInsets get responsivePadding => ResponsiveUtils.getResponsivePadding(this);
  EdgeInsets get responsiveHorizontalPadding => ResponsiveUtils.getHorizontalPadding(this);
  
  double responsiveFontSize(double baseSize) => ResponsiveUtils.getResponsiveFontSize(this, baseSize);
  double responsiveSpacing(double baseSpacing) => ResponsiveUtils.getSpacing(this, baseSpacing);
  double get maxContentWidth => ResponsiveUtils.getMaxContentWidth(this);
}
