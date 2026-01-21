import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/brand_colors.dart';

/// DesignQuote AI Brand Theme
/// Implements the complete brand guidelines
class BrandTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: BrandColors.primary,
        secondary: BrandColors.accent,
        surface: BrandColors.surface,
        background: BrandColors.background,
        error: BrandColors.error,
        onPrimary: Colors.white,
        onSecondary: BrandColors.textDark,
        onSurface: BrandColors.textDark,
        onBackground: BrandColors.textDark,
        onError: Colors.white,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: BrandColors.background,
      
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: BrandColors.textDark),
        titleTextStyle: BrandTypography.h5.copyWith(
          color: BrandColors.textDark,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: BrandColors.surface,
        elevation: BrandConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrandRadius.lg),
        ),
        shadowColor: BrandColors.shadowLight,
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BrandColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: BrandColors.shadowMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BrandRadius.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: BrandSpacing.xxl,
            vertical: BrandSpacing.md,
          ),
          textStyle: BrandTypography.bodyRegular.copyWith(
            fontWeight: BrandTypography.semiBold,
          ),
        ),
      ),
      
      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BrandColors.primary,
          side: const BorderSide(color: BrandColors.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BrandRadius.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: BrandSpacing.xxl,
            vertical: BrandSpacing.md,
          ),
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BrandColors.primary,
          textStyle: BrandTypography.bodyRegular.copyWith(
            fontWeight: BrandTypography.semiBold,
          ),
        ),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BrandColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandRadius.md),
          borderSide: const BorderSide(color: BrandColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandRadius.md),
          borderSide: const BorderSide(color: BrandColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandRadius.md),
          borderSide: const BorderSide(color: BrandColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandRadius.md),
          borderSide: const BorderSide(color: BrandColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BrandSpacing.lg,
          vertical: BrandSpacing.md,
        ),
        hintStyle: BrandTypography.bodyRegular.copyWith(
          color: BrandColors.textHint,
        ),
        labelStyle: BrandTypography.bodySmall.copyWith(
          color: BrandColors.textBody,
          fontWeight: BrandTypography.semiBold,
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: BrandTypography.h1,
          displayMedium: BrandTypography.h2,
          displaySmall: BrandTypography.h3,
          headlineMedium: BrandTypography.h4,
          headlineSmall: BrandTypography.h5,
          titleLarge: BrandTypography.h4,
          titleMedium: BrandTypography.h5,
          bodyLarge: BrandTypography.bodyLarge,
          bodyMedium: BrandTypography.bodyRegular,
          bodySmall: BrandTypography.bodySmall,
          labelLarge: BrandTypography.bodyRegular.copyWith(
            fontWeight: BrandTypography.semiBold,
          ),
          labelMedium: BrandTypography.bodySmall.copyWith(
            fontWeight: BrandTypography.semiBold,
          ),
          labelSmall: BrandTypography.caption,
        ),
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: BrandColors.divider,
        thickness: 1,
        space: BrandSpacing.lg,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: BrandColors.textBody,
        size: 24,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: BrandColors.accent,
        foregroundColor: BrandColors.textDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrandRadius.xxxl),
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: BrandColors.surface,
        selectedItemColor: BrandColors.primary,
        unselectedItemColor: BrandColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: BrandTypography.caption.copyWith(
          fontWeight: BrandTypography.semiBold,
        ),
        unselectedLabelStyle: BrandTypography.caption,
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BrandColors.textDark,
        contentTextStyle: BrandTypography.bodyRegular.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrandRadius.lg),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: BrandColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrandRadius.xl),
        ),
        titleTextStyle: BrandTypography.h4,
        contentTextStyle: BrandTypography.bodyRegular,
      ),
    );
  }
}
