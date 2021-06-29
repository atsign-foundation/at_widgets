import 'package:flutter/material.dart';

class AllColors {
  AllColors._();
  static final AllColors _instance = AllColors._();
  factory AllColors() => _instance;
  // ignore: non_constant_identifier_names
  Color WHITE = Color(0xFFFFFFFF);
  // ignore: non_constant_identifier_names
  Color INPUT_GREY_BACKGROUND = Color(0xFFF7F7FF);
  // ignore: non_constant_identifier_names
  Color LIGHT_GREY = Color(0xFFBEC0C8);
  // ignore: non_constant_identifier_names
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
  Color DARK_BLUE = Color(0xFF036ffc);
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
  Color LIGHT_GREY_LABEL = Color(0xFFB3B6BE);
  // ignore: non_constant_identifier_names
  Color RED = Color(0xFFe34040);
}

class ContactInitialsColors {
  static final color = {
    'A': Color(0xFFAA0DFE),
    'B': Color(0xFF3283FE),
    'C': Color(0xFF85660D),
    'D': Color(0xFF782AB6),
    'E': Color(0xFF565656),
    'F': Color(0xFF1C8356),
    'G': Color(0xFF16FF32),
    'H': Color(0xFFF7E1A0),
    'I': Color(0xFFE2E2E2),
    'J': Color(0xFF1CBE4F),
    'K': Color(0xFFC4451C),
    'L': Color(0xFFDEA0FD),
    'M': Color(0xFFFE00FA),
    'N': Color(0xFF325A9B),
    'O': Color(0xFFFEAF16),
    'P': Color(0xFFF8A19F),
    'Q': Color(0xFF90AD1C),
    'R': Color(0xFFF6222E),
    'S': Color(0xFF1CFFCE),
    'T': Color(0xFF2ED9FF),
    'U': Color(0xFFB10DA1),
    'V': Color(0xFFC075A6),
    'W': Color(0xFFFC1CBF),
    'X': Color(0xFFB00068),
    'Y': Color(0xFFFBE426),
    'Z': Color(0xFFFA0087),
  };

  static Color? getColor(String atsign) {
    if (atsign[0] == '@') {
      return color['${atsign[1].toUpperCase()}'];
    }

    return color['${atsign[0].toUpperCase()}'];
  }
}
