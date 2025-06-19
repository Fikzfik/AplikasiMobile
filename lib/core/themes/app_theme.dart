import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Color(0xFFF9FAFE),
      colorScheme: ColorScheme.light(
        primary: Color(0xFF3B82F6),
        secondary: Color(0xFF7C3AED),
        background: Color(0xFFF9FAFE),
        surface: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
            fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(
            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(
            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 14),
          textStyle: TextStyle(
              fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF1F2937),
      scaffoldBackgroundColor: Color(0xFF111827),
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF3B82F6),
        secondary: Color(0xFF7C3AED),
        background: Color(0xFF111827),
        surface: Color(0xFF1F2937),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
            fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(
            fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(
            fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: EdgeInsets.symmetric(vertical: 14),
          textStyle: TextStyle(
              fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}