import 'package:flutter/material.dart';

class AllColors {
  AllColors._();
  static final AllColors _instance = AllColors._();
  factory AllColors() => _instance;
  // Color LIGHT_GREY = Color(0xFFF7F7FF);
  // Color DARK_GREY = Color(0xFF868A92);
  Color WHITE = const Color(0xFFFFFFFF);
  Color INPUT_GREY_BACKGROUND = const Color(0xFFF7F7FF);
  Color LIGHT_GREY = const Color(0xFFBEC0C8);
  Color DARK_GREY = const Color(0xFF6D6D79);
  Color ORANGE = const Color(0xFFFC7A30);
  Color PURPLE = const Color(0xFFD9D9FF);
  Color LIGHT_BLUE = const Color(0xFFCFFFFF);
  Color BLUE = const Color(0xFFC1D9E9);
  Color LIGHT_PINK = const Color(0xFFFED2CF);
  Color GREY = const Color(0xFF868A92);
  Color Black = const Color(0xFF000000);
  Color GREY_LABEL = const Color(0xFF747481);
  Color EVENT_MEMBERS = const Color(0xFFC1D9E9);
  Color MILD_GREY = const Color(0xFFE4E4E4);
  Color RED = const Color(0xFFe34040);
  Color LIGHT_GREY_LABEL = const Color(0xFFB3B6BE);
}

class ContactInitialsColors {
  static final Map<String, Color> color = const <String, Color>{
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
      return color[atsign[1].toUpperCase()];
    }

    return color[atsign[0].toUpperCase()];
  }
}
