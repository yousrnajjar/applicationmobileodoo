import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


var baseHeightDesign = 655;
var baseWidthDesign = 325;

/// #d9f6da
const kLightGreen = Color.fromARGB(255, 217, 246, 218);
/// #43a047
const kGreen = Color.fromARGB(255, 67, 160, 71);
/// f6efd9
const kLightOrange = Color.fromARGB(255, 246, 239, 217);
///  #f6d9eb
const kLightPink = Color.fromARGB(255, 246, 217, 235);
/// 
const kPink = Color.fromARGB(255, 160, 71, 160);
/// #f1efef
const kLightGrey = Color.fromARGB(255, 241, 239, 239);
/// #878686
const kGrey = Color.fromARGB(255, 135, 134, 134);



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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kColorSchema.primary,
        backgroundColor: Colors.white,
        side: BorderSide(color: kColorSchema.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData().copyWith(
      selectedLabelStyle: menuText.copyWith(fontSize: 12),
      unselectedLabelStyle: menuText.copyWith(fontSize: 12),
      selectedItemColor: hoverMenuColor,
    ),
    appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: kGreen,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData().copyWith(color: Colors.white),
    ),
);

TextStyle titleLargeBold(ThemeData theme) {
  return theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold);
}
TextStyle smallText100(ThemeData theme){
  return theme.textTheme.titleSmall!
    .copyWith(color: theme.textTheme.titleSmall!.color!.withAlpha(100));
}
TextStyle titleVerySmall(ThemeData theme) {
  return theme.textTheme.titleSmall!.copyWith(fontSize: 10);
}
