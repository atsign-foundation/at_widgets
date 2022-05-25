import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 00b7ff
// ocean horizon: 005477
// tide pool blue: 0a569a

const kCaribbeanShallows = Color(0XFF57cbe7);
const kPrimaryColor = Color(0XFF289ED2);
const kAlternativeColor = Color(0XFF42C1BA);

class DudeTheme {
  // 1
  static TextTheme lightTextTheme = TextTheme(
    bodyText1: GoogleFonts.barlow(
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
    bodyText2: GoogleFonts.barlow(
      fontSize: 16.0,
      color: Colors.black,
    ),
    headline1: GoogleFonts.barlow(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    headline2: GoogleFonts.barlow(
      fontSize: 21.0,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
    headline3: GoogleFonts.barlow(
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
    headline6: GoogleFonts.barlow(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    // subtitle1: GoogleFonts.barlow(
    //   fontSize: 16.0,
    //   color: Colors.white,
    // ),
    // subtitle2: GoogleFonts.barlow(
    //   fontSize: 16.0,
    //   color: Colors.white,
    // ),
  );

  // 2
  static TextTheme darkTextTheme = TextTheme(
    bodyText1: GoogleFonts.barlow(
      fontSize: 14.0,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    headline1: GoogleFonts.barlow(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    headline2: GoogleFonts.barlow(
      fontSize: 21.0,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
    headline3: GoogleFonts.barlow(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    headline6: GoogleFonts.barlow(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );

  // 3
  static ThemeData light() {
    return ThemeData(
        primaryColor: kPrimaryColor,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light().copyWith(
          primary: kPrimaryColor,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateColor.resolveWith(
            (states) {
              return Colors.black;
            },
          ),
        ),
        appBarTheme: AppBarTheme(
            foregroundColor: Colors.white,
            backgroundColor: kPrimaryColor,
            titleTextStyle: lightTextTheme.bodyText1!
                .copyWith(color: Colors.white, fontSize: 17)),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          foregroundColor: Color(0xFFF8C630),
          backgroundColor: Colors.black,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          // backgroundColor: kPrimaryColor,
          selectedItemColor: kAlternativeColor,
        ),
        textTheme: lightTextTheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: kAlternativeColor));
  }

  // 4
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(
        foregroundColor: Colors.white,
        backgroundColor: Colors.grey[900],
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Colors.green,
      ),
      textTheme: darkTextTheme,
    );
  }
}
