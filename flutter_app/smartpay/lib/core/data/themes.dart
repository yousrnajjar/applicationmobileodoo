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

const menuText = TextStyle(
  fontSize: 14,
  letterSpacing: 0,
  fontWeight: FontWeight.w400,
  color: Colors.black,
);
Color hoverMenuColor = const Color.fromARGB(255, 67, 160, 71);
const normalText =
    TextStyle(fontSize: 13, color: Color.fromARGB(255, 88, 88, 88));
final smartpayTheme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme: kColorSchema,
  textTheme: GoogleFonts.robotoTextTheme().copyWith(
      titleLarge: menuText,
      titleSmall: menuText.copyWith(fontSize: 12),
      bodyLarge: menuText,
      bodyMedium: normalText,
      bodySmall: normalText.copyWith(fontSize: 12)),
  iconTheme: const IconThemeData().copyWith(
    size: 26,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kColorSchema.primary,
      foregroundColor: kColorSchema.onPrimary,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
    selectedLabelStyle: menuText,
    unselectedLabelStyle: menuText,
    selectedItemColor: hoverMenuColor,
  )
);
