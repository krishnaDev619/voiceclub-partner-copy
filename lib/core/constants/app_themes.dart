import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class AppThemes {
  static ThemeData get main {
    return ThemeData(
      useMaterial3: false,
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: systemOverlayStyle,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      textTheme: GoogleFonts.mulishTextTheme(),
      primarySwatch:
          MaterialColor(ApplicationColors.primaryRed.toARGB32(), const {
            50: Color(0xFFFFFFFF),
            100: Color(0xFFFFFFFF),
            200: Color(0xFFFFFFFF),
            300: Color(0xFFFFFFFF),
            400: Color(0xFFFFFFFF),
            500: Color(0xFFFFFFFF),
            600: Color(0xFFFFFFFF),
            700: Color(0xFFFFFFFF),
            800: Color(0xFFFFFFFF),
            900: Color(0xFFFFFFFF),
          }),
      primaryColor: ApplicationColors.primaryRed,
      scaffoldBackgroundColor: Colors.white,
      splashFactory: NoSplash.splashFactory,
      colorScheme: const ColorScheme.light(
        primary: ApplicationColors.primaryRed,
        secondary: ApplicationColors.primaryRed,
        surface: Colors.white,
      ),
    );
  }

  static ThemeData get gossip {
    return ThemeData(
      useMaterial3: false,
      appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(color: Colors.black),
      ),
      textTheme: GoogleFonts.mulishTextTheme(),
      primarySwatch: MaterialColor(ApplicationColors.gossip.toARGB32(), const {
        50: Color(0xFFFFFFFF),
        100: Color(0xFFFFFFFF),
        200: Color(0xFFFFFFFF),
        300: Color(0xFFFFFFFF),
        400: Color(0xFFFFFFFF),
        500: Color(0xFFFFFFFF),
        600: Color(0xFFFFFFFF),
        700: Color(0xFFFFFFFF),
        800: Color(0xFFFFFFFF),
        900: Color(0xFFFFFFFF),
      }),
      primaryColor: ApplicationColors.gossip,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: ApplicationColors.gossip,
        secondary: ApplicationColors.gossip,
        surface: Colors.white,
      ),
    );
  }

  static ThemeData get astro {
    return ThemeData(
      useMaterial3: false,
      appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(color: Colors.black),
      ),
      textTheme: GoogleFonts.mulishTextTheme(),
      primarySwatch: MaterialColor(ApplicationColors.astro.toARGB32(), const {
        50: Color(0xFFFFFFFF),
        100: Color(0xFFFFFFFF),
        200: Color(0xFFFFFFFF),
        300: Color(0xFFFFFFFF),
        400: Color(0xFFFFFFFF),
        500: Color(0xFFFFFFFF),
        600: Color(0xFFFFFFFF),
        700: Color(0xFFFFFFFF),
        800: Color(0xFFFFFFFF),
        900: Color(0xFFFFFFFF),
      }),
      primaryColor: ApplicationColors.astro,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: ApplicationColors.astro,
        secondary: ApplicationColors.astro,
        surface: Colors.white,
      ),
    );
  }

  static ThemeData get love {
    return ThemeData(
      useMaterial3: false,
      appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(color: Colors.black),
      ),
      textTheme: GoogleFonts.mulishTextTheme(),
      primarySwatch: MaterialColor(ApplicationColors.love.toARGB32(), const {
        50: Color(0xFFFFFFFF),
        100: Color(0xFFFFFFFF),
        200: Color(0xFFFFFFFF),
        300: Color(0xFFFFFFFF),
        400: Color(0xFFFFFFFF),
        500: Color(0xFFFFFFFF),
        600: Color(0xFFFFFFFF),
        700: Color(0xFFFFFFFF),
        800: Color(0xFFFFFFFF),
        900: Color(0xFFFFFFFF),
      }),
      primaryColor: ApplicationColors.love,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: ApplicationColors.love,
        secondary: ApplicationColors.love,
        surface: Colors.white,
      ),
    );
  }
}
