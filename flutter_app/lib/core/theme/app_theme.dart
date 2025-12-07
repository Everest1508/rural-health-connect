import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette - matching the React app's design system
  static const Color primaryColor = Color(0xFF1FA89E); // hsl(174 72% 40%)
  static const Color primaryLight = Color(0xFF2BB8AD); // hsl(180 65% 45%)
  static const Color accentColor = Color(0xFFFF6B35); // hsl(25 95% 55%)
  static const Color accentLight = Color(0xFFFF8A4D); // hsl(35 95% 60%)
  
  static const Color successColor = Color(0xFF10B981); // hsl(152 69% 40%)
  static const Color warningColor = Color(0xFFFBBF24); // hsl(38 92% 50%)
  static const Color infoColor = Color(0xFF0EA5E9); // hsl(199 89% 48%)
  static const Color destructiveColor = Color(0xFFEF4444); // hsl(0 72% 51%)
  
  static const Color backgroundColor = Color(0xFFF0F9F8); // hsl(180 20% 98%)
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color foregroundColor = Color(0xFF1E3A3A); // hsl(200 25% 15%)
  static const Color mutedForeground = Color(0xFF6B8E8E); // hsl(200 15% 45%)
  static const Color borderColor = Color(0xFFE0EDED); // hsl(180 15% 90%)
  
  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF0F1D1D); // hsl(200 25% 8%)
  static const Color darkCardColor = Color(0xFF172626); // hsl(200 25% 12%)
  static const Color darkForegroundColor = Color(0xFFECF5F5); // hsl(180 20% 95%)
  static const Color darkMutedForeground = Color(0xFF8FA9A9); // hsl(200 15% 60%)
  static const Color darkBorderColor = Color(0xFF243636); // hsl(200 20% 20%)

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, accentLight],
  );

  // Text Styles
  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    return base.copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: mutedForeground,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: cardColor,
      error: destructiveColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: foregroundColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    textTheme: _buildTextTheme(ThemeData.light().textTheme, foregroundColor),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: foregroundColor,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 2,
      shadowColor: foregroundColor.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: mutedForeground,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      secondary: accentLight,
      surface: darkCardColor,
      error: destructiveColor,
      onPrimary: darkBackgroundColor,
      onSecondary: darkBackgroundColor,
      onSurface: darkForegroundColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: darkCardColor,
    textTheme: _buildTextTheme(ThemeData.dark().textTheme, darkForegroundColor),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackgroundColor,
      foregroundColor: darkForegroundColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: darkForegroundColor,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkCardColor,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLight,
        foregroundColor: darkBackgroundColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: darkBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkCardColor,
      selectedItemColor: primaryLight,
      unselectedItemColor: darkMutedForeground,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
