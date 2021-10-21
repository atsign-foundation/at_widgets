import 'package:flutter/material.dart';

class AllColors {
  AllColors._();
  static final AllColors _instance = AllColors._();
  factory AllColors() => _instance;
  // ignore: non_constant_identifier_names
  Color WHITE = Color(0xFFFFFFFF);
  // ignore: non_constant_identifier_names
  // Color LIGHT_GREY = Color(0xFFF7F7FF);
  Color INPUT_GREY_BACKGROUND = Color(0xFFF7F7FF);
  Color LIGHT_GREY = Color(0xFFBEC0C8);
  // ignore: non_constant_identifier_names
  // Color DARK_GREY = Color(0xFF868A92);
  Color DARK_GREY = Color(0xFF6D6D79);
  // ignore: non_constant_identifier_names
  Color ORANGE = Color(0xFFFC7A30);
  // ignore: non_constant_identifier_names
  Color PURPLE = Color(0xFFD9D9FF);
  // ignore: non_constant_identifier_names
  Color LIGHT_BLUE = Color(0xFFCFFFFF);
  // ignore: non_constant_identifier_names
  Color BLUE = Color(0xFFC1D9E9);
  // ignore: non_constant_identifier_names
  Color LIGHT_PINK = Color(0xFFFED2CF);
  // ignore: non_constant_identifier_names
  Color GREY = Color(0xFF868A92); // Change it to Hex Later
  // ignore: non_constant_identifier_names
  Color Black = Color(0xFF000000);
  // ignore: non_constant_identifier_names
  Color GREY_LABEL = Color(0xFF747481);
  // ignore: non_constant_identifier_names
  Color EVENT_MEMBERS = Color(0xFFC1D9E9);
  // ignore: non_constant_identifier_names
  Color MILD_GREY = Color(0xFFE4E4E4);

  // ignore: non_constant_identifier_names
  Color RED = Color(0xFFe34040);
  // ignore: non_constant_identifier_names
  Color GREEN = Colors.green;
  // ignore: non_constant_identifier_names
  Color LIGHT_GREY_LABEL = Color(0xFFB3B6BE);
}

class ContactInitialsColors {
  static Color getColor(String atsign) {
    if (atsign.length == 1) {
      atsign = atsign + ' ';
    }
    switch (atsign[1].toUpperCase()) {
      case 'A':
        return Color(0xFFAA0DFE);
      case 'B':
        return Color(0xFF3283FE);
      case 'C':
        return Color(0xFF85660D);
      case 'D':
        return Color(0xFF782AB6);
      case 'E':
        return Color(0xFF565656);
      case 'F':
        return Color(0xFF1C8356);
      case 'G':
        return Color(0xFF16FF32);
      case 'H':
        return Color(0xFFF7E1A0);
      case 'I':
        return Color(0xFFE2E2E2);
      case 'J':
        return Color(0xFF1CBE4F);
      case 'K':
        return Color(0xFFC4451C);
      case 'L':
        return Color(0xFFDEA0FD);
      case 'M':
        return Color(0xFFFE00FA);
      case 'N':
        return Color(0xFF325A9B);
      case 'O':
        return Color(0xFFFEAF16);
      case 'P':
        return Color(0xFFF8A19F);
      case 'Q':
        return Color(0xFF90AD1C);
      case 'R':
        return Color(0xFFF6222E);
      case 'S':
        return Color(0xFF1CFFCE);
      case 'T':
        return Color(0xFF2ED9FF);
      case 'U':
        return Color(0xFFB10DA1);
      case 'V':
        return Color(0xFFC075A6);
      case 'W':
        return Color(0xFFFC1CBF);
      case 'X':
        return Color(0xFFB00068);
      case 'Y':
        return Color(0xFFFBE426);
      case 'Z':
        return Color(0xFFFA0087);
      case '@':
        return Color(0xFFAA0DFE);

      default:
        return Color(0xFFAA0DFE);
    }
  }
}
