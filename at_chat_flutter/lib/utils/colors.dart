import 'package:flutter/material.dart';

class CustomColors {
  static const Color incomingMessageColor = Color(0xffF1F2F3);
  static const Color outgoingMessageColor = Color(0xffC0D9EA);
  static const Color defaultColor = Color(0xFFF05E3E);
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
