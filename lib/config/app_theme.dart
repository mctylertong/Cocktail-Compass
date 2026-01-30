import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ============================================================
  // UPSCALE BAR COLOR PALETTE
  // ============================================================

  // Primary - Rich amber/gold (like aged whiskey)
  static const Color primaryGold = Color(0xFFD4A84B);
  static const Color primaryGoldLight = Color(0xFFE8C778);
  static const Color primaryGoldDark = Color(0xFFB8892E);

  // Background - Deep, sophisticated darks
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color backgroundMedium = Color(0xFF1A1A1A);
  static const Color surfaceDark = Color(0xFF242424);
  static const Color surfaceLight = Color(0xFF2E2E2E);

  // Accent colors
  static const Color accentCopper = Color(0xFFB87333);
  static const Color accentBurgundy = Color(0xFF722F37);
  static const Color accentEmerald = Color(0xFF2E8B57);
  static const Color accentCream = Color(0xFFF5F5DC);

  // Text colors
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF707070);
  static const Color textGold = Color(0xFFD4A84B);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFCF6679);
  static const Color warning = Color(0xFFFFB74D);

  // Light theme colors (elegant light mode)
  static const Color lightBackground = Color(0xFFF8F6F3);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0EDE8);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF5C5C5C);

  // ============================================================
  // TYPOGRAPHY
  // ============================================================

  static const String _fontFamily = 'Roboto'; // Will use system default

  static const TextStyle _headingStyle = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w300,
    letterSpacing: 1.5,
  );

  static const TextStyle _bodyStyle = TextStyle(
    fontFamily: _fontFamily,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
  );

  // ============================================================
  // DARK THEME (Primary - Upscale Bar)
  // ============================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGold,
      scaffoldBackgroundColor: backgroundDark,

      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        primaryContainer: primaryGoldDark,
        secondary: accentCopper,
        secondaryContainer: accentBurgundy,
        surface: surfaceDark,
        error: error,
        onPrimary: backgroundDark,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onError: backgroundDark,
        outline: textMuted,
        surfaceContainerHighest: surfaceLight,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
        ),
        iconTheme: IconThemeData(color: primaryGold),
      ),

      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: textMuted.withValues(alpha: 0.2)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: backgroundDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGold,
          side: const BorderSide(color: primaryGold, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGold,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textMuted.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textMuted.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGold, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      textTheme: TextTheme(
        displayLarge: _headingStyle.copyWith(
          fontSize: 32,
          color: textPrimary,
        ),
        displayMedium: _headingStyle.copyWith(
          fontSize: 28,
          color: textPrimary,
        ),
        displaySmall: _headingStyle.copyWith(
          fontSize: 24,
          color: textPrimary,
        ),
        headlineLarge: _headingStyle.copyWith(
          fontSize: 22,
          color: textPrimary,
        ),
        headlineMedium: _headingStyle.copyWith(
          fontSize: 20,
          color: textPrimary,
        ),
        headlineSmall: _headingStyle.copyWith(
          fontSize: 18,
          color: textPrimary,
        ),
        titleLarge: _bodyStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleMedium: _bodyStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: _bodyStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: _bodyStyle.copyWith(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: _bodyStyle.copyWith(
          fontSize: 14,
          color: textPrimary,
        ),
        bodySmall: _bodyStyle.copyWith(
          fontSize: 12,
          color: textSecondary,
        ),
        labelLarge: _bodyStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
          color: textPrimary,
        ),
        labelMedium: _bodyStyle.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
        labelSmall: _bodyStyle.copyWith(
          fontSize: 10,
          color: textMuted,
        ),
      ),

      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),

      dividerTheme: DividerThemeData(
        color: textMuted.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: primaryGold,
        textColor: textPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundMedium,
        selectedItemColor: primaryGold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: primaryGold.withValues(alpha: 0.2),
        disabledColor: surfaceDark,
        labelStyle: const TextStyle(
          color: textPrimary,
          fontSize: 13,
        ),
        secondaryLabelStyle: const TextStyle(
          color: primaryGold,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: textMuted.withValues(alpha: 0.3)),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGold,
        foregroundColor: backgroundDark,
        elevation: 4,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceLight,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: _headingStyle.copyWith(
          fontSize: 20,
          color: textPrimary,
        ),
        contentTextStyle: _bodyStyle.copyWith(
          fontSize: 14,
          color: textSecondary,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: primaryGold,
        unselectedLabelColor: textMuted,
        indicatorColor: primaryGold,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGold,
        circularTrackColor: surfaceLight,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: primaryGold,
        inactiveTrackColor: surfaceLight,
        thumbColor: primaryGold,
        overlayColor: primaryGold.withValues(alpha: 0.2),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryGold;
          return textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGold.withValues(alpha: 0.4);
          }
          return surfaceLight;
        }),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryGold;
          return textMuted;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryGold;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(backgroundDark),
        side: BorderSide(color: textMuted.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(color: textPrimary),
      ),
    );
  }

  // ============================================================
  // LIGHT THEME (Elegant Light Mode)
  // ============================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGoldDark,
      scaffoldBackgroundColor: lightBackground,

      colorScheme: const ColorScheme.light(
        primary: primaryGoldDark,
        primaryContainer: primaryGold,
        secondary: accentCopper,
        secondaryContainer: accentBurgundy,
        surface: lightSurface,
        error: Color(0xFFB00020),
        onPrimary: lightSurface,
        onSecondary: lightSurface,
        onSurface: lightTextPrimary,
        outline: lightTextSecondary,
        surfaceContainerHighest: lightSurfaceVariant,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
        ),
        iconTheme: IconThemeData(color: primaryGoldDark),
      ),

      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGoldDark,
          foregroundColor: lightSurface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGoldDark,
          side: const BorderSide(color: primaryGoldDark, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGoldDark,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        hintStyle: TextStyle(color: lightTextSecondary.withValues(alpha: 0.7)),
        labelStyle: const TextStyle(color: lightTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightTextSecondary.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightTextSecondary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGoldDark, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      textTheme: TextTheme(
        displayLarge: _headingStyle.copyWith(fontSize: 32, color: lightTextPrimary),
        displayMedium: _headingStyle.copyWith(fontSize: 28, color: lightTextPrimary),
        displaySmall: _headingStyle.copyWith(fontSize: 24, color: lightTextPrimary),
        headlineLarge: _headingStyle.copyWith(fontSize: 22, color: lightTextPrimary),
        headlineMedium: _headingStyle.copyWith(fontSize: 20, color: lightTextPrimary),
        headlineSmall: _headingStyle.copyWith(fontSize: 18, color: lightTextPrimary),
        titleLarge: _bodyStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w500, color: lightTextPrimary),
        titleMedium: _bodyStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500, color: lightTextPrimary),
        titleSmall: _bodyStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: lightTextPrimary),
        bodyLarge: _bodyStyle.copyWith(fontSize: 16, color: lightTextPrimary),
        bodyMedium: _bodyStyle.copyWith(fontSize: 14, color: lightTextPrimary),
        bodySmall: _bodyStyle.copyWith(fontSize: 12, color: lightTextSecondary),
        labelLarge: _bodyStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1, color: lightTextPrimary),
        labelMedium: _bodyStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: lightTextSecondary),
        labelSmall: _bodyStyle.copyWith(fontSize: 10, color: lightTextSecondary),
      ),

      iconTheme: const IconThemeData(color: lightTextSecondary, size: 24),

      dividerTheme: DividerThemeData(
        color: lightTextSecondary.withValues(alpha: 0.2),
        thickness: 1,
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: primaryGoldDark,
        textColor: lightTextPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primaryGoldDark,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: lightSurfaceVariant,
        selectedColor: primaryGold.withValues(alpha: 0.3),
        labelStyle: const TextStyle(color: lightTextPrimary, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGoldDark,
        foregroundColor: lightSurface,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: primaryGoldDark,
        unselectedLabelColor: lightTextSecondary,
        indicatorColor: primaryGoldDark,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryGoldDark,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryGoldDark;
          return lightTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryGold.withValues(alpha: 0.4);
          }
          return lightSurfaceVariant;
        }),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryGoldDark;
          return lightTextSecondary;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryGoldDark;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(lightSurface),
        side: BorderSide(color: lightTextSecondary.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ============================================================
  // CUSTOM DECORATIONS
  // ============================================================

  static BoxDecoration get gradientBackground => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        backgroundDark,
        Color(0xFF151515),
        backgroundMedium,
      ],
    ),
  );

  static BoxDecoration get cardGradient => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        surfaceDark,
        surfaceLight.withValues(alpha: 0.8),
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: textMuted.withValues(alpha: 0.2)),
  );

  static BoxDecoration goldAccentBorder({double radius = 16}) => BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: primaryGold.withValues(alpha: 0.3)),
  );
}
