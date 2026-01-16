import 'package:flutter/material.dart';

/// Uygulama renk paleti - buradan tüm renkleri kolayca değiştirebilirsiniz
class AppColors {
  // Açık Mod Renkleri - Mor/Pembe Palet
  static const lightPrimary = Color(0xFF9E6B99); // Orta Mor-Pembe
  static const lightSecondary = Color(0xFFBA8BAE); // Açık Mor-Pembe
  static const lightBackground = Color(0xFFF3CCDE); // Açık Pembe
  static const lightSurface = Color(0xFFFFFFFF); // Beyaz
  static const lightError = Color(0xFFE53935); // Kırmızı
  static const lightOnPrimary = Color(0xFFFFFFFF); // Beyaz
  static const lightOnBackground = Color(0xFF5B3765); // Koyu Mor
  static const lightOnSurface = Color(0xFF5B3765); // Koyu Mor
  
  // Koyu Mod Renkleri - Mor/Pembe Palet
  static const darkPrimary = Color(0xFFD6ABC4); // Açık Pembe-Mor
  static const darkSecondary = Color(0xFFBA8BAE); // Orta Mor-Pembe
  static const darkBackground = Color(0xFF5B3765); // Koyu Mor
  static const darkSurface = Color(0xFF775380); // Orta Koyu Mor
  static const darkError = Color(0xFFEF5350); // Açık Kırmızı
  static const darkOnPrimary = Color(0xFF5B3765); // Koyu Mor
  static const darkOnBackground = Color(0xFFF3CCDE); // Açık Pembe
  static const darkOnSurface = Color(0xFFF3CCDE); // Açık Pembe

  // Özel Renkler (Her iki temada aynı)
  static const success = Color(0xFF4CAF50); // Yeşil
  static const warning = Color(0xFFFF9800); // Turuncu
  static const info = Color(0xFF9E6B99); // Mor-Pembe
}

/// Uygulama tema yapılandırması
class AppTheme {
  // Açık Mod Teması
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightSurface,
      error: AppColors.lightError,
      onPrimary: AppColors.lightOnPrimary,
      onSecondary: AppColors.lightOnPrimary,
      onSurface: AppColors.lightOnSurface,
      onError: AppColors.lightOnPrimary,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    
    // AppBar Teması
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: AppColors.lightOnPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    
    // Kart Teması
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Buton Teması
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // Input Decoration Teması
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightPrimary.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightPrimary.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
      ),
    ),
  );

  // Koyu Mod Teması
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
      error: AppColors.darkError,
      onPrimary: AppColors.darkOnPrimary,
      onSecondary: AppColors.darkOnPrimary,
      onSurface: AppColors.darkOnSurface,
      onError: AppColors.darkOnPrimary,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    
    // AppBar Teması
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkOnSurface,
      elevation: 0,
      centerTitle: true,
    ),
    
    // Kart Teması
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Buton Teması
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkOnPrimary,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // Input Decoration Teması
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkPrimary.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkPrimary.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
    ),
  );
}
