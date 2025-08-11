import 'package:flutter/material.dart';

ThemeData buildTheme(bool dark) {
  final base = dark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: base.colorScheme.primary,
      secondary: base.colorScheme.secondary,
    ),
    textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
    visualDensity: VisualDensity.comfortable,
    cardTheme: const CardTheme(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}
