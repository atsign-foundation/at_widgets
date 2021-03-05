import 'package:flutter/material.dart';

//Copy this CustomPainter code to the Bottom of the File
class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
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

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xfffc7a30).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CircleCustomPainter extends CustomPainter {
  Color color;
  CircleCustomPainter({this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * -36.54597, size.height * -34.36532);
    path_0.arcToPoint(Offset(size.width * -36.56518, size.height * -34.38568),
        radius:
            Radius.elliptical(size.width * 0.2039749, size.height * 0.1793256),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.arcToPoint(Offset(size.width * -36.89506, size.height * -34.79917),
        radius:
            Radius.elliptical(size.width * 0.5002187, size.height * 0.4397700),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.arcToPoint(Offset(size.width * -36.39508, size.height * -35.23874),
        radius:
            Radius.elliptical(size.width * 0.4999896, size.height * 0.4395685),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.arcToPoint(Offset(size.width * -35.89509, size.height * -34.79917),
        radius:
            Radius.elliptical(size.width * 0.4999896, size.height * 0.4395685),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.arcToPoint(Offset(size.width * -36.24270, size.height * -34.38039),
        radius:
            Radius.elliptical(size.width * 0.5002396, size.height * 0.4397883),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.arcToPoint(Offset(size.width * -36.25804, size.height * -34.36532),
        radius:
            Radius.elliptical(size.width * 0.2068499, size.height * 0.1818531),
        rotation: 0,
        largeArc: false,
        clockwise: true);
    path_0.lineTo(size.width * -36.40199, size.height * -34.23874);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = color ?? Color(0xfffc7a30).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = color ?? Color(0xff000000).withOpacity(1.0);
    canvas.drawCircle(Offset(size.width * 0.4166580, size.height * 0.3663071),
        size.width * 0.4166580, paint_1_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
