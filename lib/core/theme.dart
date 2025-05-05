import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color secondaryColor = Color(0xFF64B5F6);
  static const Color backgroundColor = Colors.white;
  static const Color backgroundColorDark = Colors.black;
  static const Color success = Colors.green;
  static const Color dangerColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color disable = Color.fromARGB(255, 72, 72, 72);

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
        error: dangerColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: Colors.black,
        displayColor: Colors.black,
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.black,
        error: dangerColor,
      ),
      scaffoldBackgroundColor: Colors.black,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }
}
