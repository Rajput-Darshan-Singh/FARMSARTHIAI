import 'package:flutter/material.dart';

class AppTheme {
  // Nature-inspired color palette
  static const Color lightGreen = Color(0xFFA8D5BA); // Soft light green
  static const Color mediumGreen = Color(0xFF6B9F78); // Medium green
  static const Color darkGreen = Color(0xFF4A7C59); // Dark green
  static const Color earthyBrown = Color(0xFF8B6F47); // Earthy brown
  static const Color lightBrown = Color(0xFFD4C4A8); // Light brown
  static const Color softYellow = Color(0xFFF5E6D3); // Soft yellow/cream
  static const Color warmYellow = Color(0xFFE8C99B); // Warm yellow
  static const Color background = Color(0xFFF9F7F4); // Off-white background
  static const Color surface = Color(0xFFFFFFFF); // White surface
  static const Color error = Color(0xFFD32F2F); // Error red

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: mediumGreen,
        secondary: earthyBrown,
        tertiary: warmYellow,
        surface: surface,
        background: background,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkGreen,
        onBackground: darkGreen,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: mediumGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mediumGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: mediumGreen,
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightGreen, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightGreen, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mediumGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: TextStyle(color: darkGreen),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: mediumGreen,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkGreen,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkGreen,
          letterSpacing: 0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkGreen,
          letterSpacing: 0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkGreen,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkGreen,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: darkGreen,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: darkGreen,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: darkGreen,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: darkGreen.withOpacity(0.7),
        ),
      ),
      iconTheme: IconThemeData(
        color: mediumGreen,
        size: 24,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: mediumGreen,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}

