import 'package:flutter/material.dart';

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var path_0 = Path();
    path_0.moveTo(size.width * 0.4984829, size.height * 0.5929065);
    path_0.arcToPoint(Offset(size.width * 0.7102083, size.height * 0.4184499),
        radius:
            Radius.elliptical(size.width * 0.2113654, size.height * 0.1741599),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.arcToPoint(Offset(size.width * 0.4984829, size.height * 0.2377643),
        radius:
            Radius.elliptical(size.width * 0.2178452, size.height * 0.1794991),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.arcToPoint(Offset(size.width * 0.2867575, size.height * 0.4122209),
        radius:
            Radius.elliptical(size.width * 0.2113654, size.height * 0.1741599),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.arcToPoint(Offset(size.width * 0.4984829, size.height * 0.5929065),
        radius:
            Radius.elliptical(size.width * 0.2231936, size.height * 0.1839061),
        rotation: 0,
        largeArc: false,
        clockwise: false);
    path_0.close();
    path_0.moveTo(size.width * 0.1430702, size.height * 0.1193695);
    path_0.arcToPoint(Offset(size.width * 0.8536899, size.height * 0.7050299),
        radius:
            Radius.elliptical(size.width * 0.5025971, size.height * 0.4141277),
        rotation: 0,
        largeArc: true,
        clockwise: true);
    path_0.lineTo(size.width * 0.4984829, size.height * 0.9978813);
    path_0.lineTo(size.width * 0.1430702, size.height * 0.7050299);
    path_0.arcToPoint(Offset(size.width * 0.1430702, size.height * 0.1193695),
        radius:
            Radius.elliptical(size.width * 0.5163281, size.height * 0.4254418),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.close();

    var paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xfffc7a30).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
