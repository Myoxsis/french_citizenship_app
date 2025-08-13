import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme_extensions.dart';

ThemeData buildTheme(bool dark) {
  // Brand colors
  const primary = Color(0xFF003A70);
  const secondary = Color(0xFFE64545);
  const neutral = Color(0xFF64748B);

  Color onColor(Color color) =>
      color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    secondary: secondary,
    tertiary: neutral,
    brightness: dark ? Brightness.dark : Brightness.light,
  ).copyWith(
    onPrimary: onColor(primary),
    onSecondary: onColor(secondary),
    onTertiary: onColor(neutral),
  );

  final statusColors = StatusColors(
    success: const Color(0xFF4CAF50),
    warning: const Color(0xFFFFC107),
    error: scheme.error,
  );

  final baseTextTheme =
      (dark ? ThemeData.dark() : ThemeData.light()).textTheme;
  final textTheme = GoogleFonts.montserratTextTheme(baseTextTheme).copyWith(
    headlineMedium: GoogleFonts.montserrat(
      textStyle: baseTextTheme.headlineMedium,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.montserrat(
      textStyle: baseTextTheme.titleLarge,
      fontWeight: FontWeight.w600,
    ),
    bodyMedium: GoogleFonts.montserrat(
      textStyle: baseTextTheme.bodyMedium,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: textTheme,
    visualDensity: VisualDensity.comfortable,
    extensions: [statusColors],
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
