import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final kColorSchema = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: const Color.fromRGBO(67, 160, 78, 1),
);
final kColorDarkSchema = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromRGBO(2, 5, 2, 1),
);
final smartpayTheme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme: kColorSchema,
  textTheme: GoogleFonts.latoTextTheme(),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kColorSchema.primary,
      foregroundColor: kColorSchema.onPrimary,
    ),
  ),
);
