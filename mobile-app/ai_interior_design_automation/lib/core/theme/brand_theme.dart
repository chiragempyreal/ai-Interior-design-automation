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
      iconTheme: const IconThemeData(color: BrandColors.textBody, size: 24),

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

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: BrandColors.primaryLight, // Lighter for dark mode
        secondary: BrandColors.accent,
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        error: BrandColors.errorBright,
        onPrimary: BrandColors.textDark,
        onSecondary: BrandColors.textDark,
        onSurface: const Color(0xFFE0E0E0),
        onBackground: const Color(0xFFE0E0E0),
        onError: Colors.black,
      ),

      // Scaffold
      scaffoldBackgroundColor: const Color(0xFF121212),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: BrandTypography.h5.copyWith(color: Colors.white),
      ),

      // Card
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: BrandConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrandRadius.lg),
        ),
        shadowColor: Colors.black.withOpacity(0.3),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BrandColors.primaryLight,
          foregroundColor: BrandColors.textDark,
          elevation: 2,
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
          foregroundColor: BrandColors.primaryLight,
          side: const BorderSide(color: BrandColors.primaryLight, width: 2),
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
          foregroundColor: BrandColors.primaryLight,
          textStyle: BrandTypography.bodyRegular.copyWith(
            fontWeight: BrandTypography.semiBold,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandRadius.md),
          borderSide: const BorderSide(color: Color(0xFF444444)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandRadius.md),
          borderSide: const BorderSide(color: Color(0xFF444444)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BrandRadius.md),
          borderSide: const BorderSide(
            color: BrandColors.primaryLight,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BrandSpacing.lg,
          vertical: BrandSpacing.md,
        ),
        hintStyle: BrandTypography.bodyRegular.copyWith(
          color: Colors.grey[500],
        ),
      ),

      // Text Theme - Override colors for dark mode
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: BrandTypography.h1.copyWith(color: Colors.white),
          displayMedium: BrandTypography.h2.copyWith(color: Colors.white),
          displaySmall: BrandTypography.h3.copyWith(color: Colors.white),
          headlineMedium: BrandTypography.h4.copyWith(color: Colors.white),
          headlineSmall: BrandTypography.h5.copyWith(color: Colors.white),
          titleLarge: BrandTypography.h4.copyWith(color: Colors.white),
          titleMedium: BrandTypography.h5.copyWith(color: Colors.white),
          bodyLarge: BrandTypography.bodyLarge.copyWith(
            color: const Color(0xFFE0E0E0),
          ),
          bodyMedium: BrandTypography.bodyRegular.copyWith(
            color: const Color(0xFFE0E0E0),
          ),
          bodySmall: BrandTypography.bodySmall.copyWith(
            color: Colors.grey[400],
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF2C2C2C),
        thickness: 1,
      ),

      iconTheme: const IconThemeData(color: Color(0xFFE0E0E0), size: 24),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: BrandColors.primaryLight,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2C2C2C),
        contentTextStyle: BrandTypography.bodyRegular.copyWith(
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrandRadius.lg),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BrandRadius.xl),
        ),
        titleTextStyle: BrandTypography.h4.copyWith(color: Colors.white),
        contentTextStyle: BrandTypography.bodyRegular.copyWith(
          color: const Color(0xFFE0E0E0),
        ),
      ),
    );
  }
}
