import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DesignQuote AI Brand Colors
/// Brand Guide: "Design with Confidence. Quote in Minutes."
/// Last Updated: January 21, 2026

class BrandColors {
  // Primary Brand Color - Deep Forest Green
  static const Color primary = Color(0xFF4A6C5D); // #4A6C5D
  static const Color primaryDark = Color(0xFF3D5A4F);
  static const Color primaryLight = Color(0xFF7A9A8C); // Sage Green
  
  // Accent Color - Warm Beige/Tan
  static const Color accent = Color(0xFFD4A574); // #D4A574
  static const Color accentDark = Color(0xFFC89968);
  static const Color accentLight = Color(0xFFE6C9A0);
  
  // Background Colors
  static const Color background = Color(0xFFF8F6F1); // Cream/Off-White
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceVariant = Color(0xFFF5F3F0);
  
  // Text Colors
  static const Color textDark = Color(0xFF2B3E3A); // Charcoal Gray
  static const Color textBody = Color(0xFF5A5A5A); // Medium Gray
  static const Color textLight = Color(0xFFA0A0A0); // Light Gray
  static const Color textHint = Color(0xFFD9D6D1);
  
  // Border & Divider Colors
  static const Color border = Color(0xFFD9D6D1); // Light Gray
  static const Color divider = Color(0xFFE5E3E0);
  
  // State Colors
  static const Color success = Color(0xFF7A9A8C); // Sage Green
  static const Color warning = Color(0xFFE6A757); // Warm Orange
  static const Color error = Color(0xFFC08080); // Dusty Rose
  static const Color errorBright = Color(0xFFFF6B6B); // Soft Red
  static const Color info = Color(0xFF6B9AC4); // Soft Blue
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warmGradient = LinearGradient(
    colors: [accent, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.05);
  static Color shadowMedium = Colors.black.withOpacity(0.08);
  static Color shadowDark = Colors.black.withOpacity(0.12);
  
  // Overlay Colors
  static Color overlayLight = Colors.black.withOpacity(0.1);
  static Color overlayMedium = Colors.black.withOpacity(0.4);
  static Color overlayDark = Colors.black.withOpacity(0.6);
}

/// Brand Typography
class BrandTypography {
  // Font Family
  static String get primaryFont => GoogleFonts.inter().fontFamily!;
  static String get accentFont => GoogleFonts.lora().fontFamily!;
  
  // Font Weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  
  // Text Styles
  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 56,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.02,
    color: BrandColors.textDark,
  );
  
  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.01,
    color: BrandColors.textDark,
  );
  
  static TextStyle get h3 => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: BrandColors.textDark,
  );
  
  static TextStyle get h4 => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: BrandColors.textDark,
  );
  
  static TextStyle get h5 => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.01,
    color: BrandColors.textDark,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: BrandColors.textBody,
  );
  
  static TextStyle get bodyRegular => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: BrandColors.textBody,
  );
  
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: BrandColors.textBody,
  );
  
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.01,
    color: BrandColors.textLight,
  );
  
  static TextStyle get overline => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0.1,
    color: BrandColors.textBody,
  );
}

/// Brand Spacing (8px base)
class BrandSpacing {
  static const double xs = 4.0;   // space-1
  static const double sm = 8.0;   // space-2
  static const double md = 12.0;  // space-3
  static const double lg = 16.0;  // space-4
  static const double xl = 20.0;  // space-5
  static const double xxl = 24.0; // space-6
  static const double xxxl = 32.0; // space-7
  static const double huge = 40.0; // space-8
  static const double massive = 48.0; // space-9
  static const double giant = 64.0; // space-12
}

/// Brand Border Radius
class BrandRadius {
  static const double sm = 4.0;
  static const double md = 6.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double xxl = 16.0;
  static const double xxxl = 20.0;
  static const double full = 999.0; // Circular
}

/// Brand Shadows
class BrandShadows {
  static List<BoxShadow> get light => [
    BoxShadow(
      color: BrandColors.shadowLight,
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: BrandColors.shadowMedium,
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get heavy => [
    BoxShadow(
      color: BrandColors.shadowDark,
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];
}

/// Brand Constants
class BrandConstants {
  static const String brandName = "DesignQuote AI";
  static const String tagline = "Design with Confidence. Quote in Minutes.";
  static const double maxContentWidth = 1200.0;
  static const double cardElevation = 2.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
}
