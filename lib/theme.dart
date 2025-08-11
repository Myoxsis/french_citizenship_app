import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme(bool dark) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0055A4),
    secondary: const Color(0xFFEF4135),
    brightness: dark ? Brightness.dark : Brightness.light,
  );
  final baseTextTheme =
      (dark ? ThemeData.dark() : ThemeData.light()).textTheme;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: GoogleFonts.montserratTextTheme(baseTextTheme),
    visualDensity: VisualDensity.comfortable,
    cardTheme: const CardThemeData(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
