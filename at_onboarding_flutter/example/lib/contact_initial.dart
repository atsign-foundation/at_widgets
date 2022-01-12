import 'package:flutter/material.dart';

class ContactInitial extends StatelessWidget {
  final double size;
  final String initials;
  int index;

  ContactInitial(
      {Key key = const Key('contact_initial'),
      this.size = 40,
      @required this.initials = 'AT',
      this.index = 2})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (initials.length < 3) {
      index = initials.length;
    } else {
      index = 3;
    }

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: ContactInitialsColors.getColor(initials),
        borderRadius: BorderRadius.circular(size),
      ),
      child: Center(
        child:
            Text(initials.substring((index == 1) ? 0 : 1, index).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.w700,
                )),
      ),
    );
  }
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
