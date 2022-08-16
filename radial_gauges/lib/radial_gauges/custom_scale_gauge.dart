import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:radial_gauges/utils/utils.dart';

class CustomScaleGauge extends StatefulWidget {
  /// Creates a Range Pointer Gauge.
  ///
  /// The [minValue] and [maxValue] must not be null.
  CustomScaleGauge({
    this.minValue = 0,
    required this.maxValue,
    required this.actualValue,
    this.label = '',
    this.pointerColor = Colors.blue,
    this.decimalPlaces = 0,
    this.animate = true,
    Key? key,
  }) : super(key: key);

  /// Sets the minimum value of the gauge.
  double minValue;

  /// Sets the maximum value of the gauge.
  double maxValue;

  /// Sets the pointer value of the gauge.
  double actualValue;

  /// Set the label of the gauge.
  String label;

  /// Sets the pointer color of the gauge.
  final Color pointerColor;

  /// Controls how much decimal places will be shown for the [minValue],[maxValue] and [actualValue].
  final int decimalPlaces;

  /// Toggle on and off animation.
  final bool animate;

  @override
  State<CustomScaleGauge> createState() => _CustomScaleGaugeState();
}

class _CustomScaleGaugeState extends State<CustomScaleGauge>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    double sweepAngleRadian = Utils.actualValueToSweepAngleRadian(
        actualValue: widget.actualValue,
        maxValue: widget.maxValue,
        maxDegrees: 300);

    double upperBound = Utils.degreesToRadians(300);

    animationController = AnimationController(
        duration: Duration(seconds: widget.animate ? 1 : 0),
        vsync: this,
        upperBound: upperBound);

    animation = Tween<double>().animate(animationController)
      ..addListener(() {
        if (animationController.value == sweepAngleRadian) {
          animationController.stop();
        }

        setState(() {});
      });

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (animationController.value !=
        Utils.actualValueToSweepAngleRadian(
            actualValue: widget.actualValue,
            maxValue: widget.maxValue,
            maxDegrees: 300)) {
      animationController.animateTo(
          Utils.actualValueToSweepAngleRadian(
              actualValue: widget.actualValue,
              maxValue: widget.maxValue,
              maxDegrees: 300),
          duration: Duration(seconds: widget.animate ? 1 : 0));
    }

    return CustomPaint(
      painter: RangePointerGaugePainter(
          sweepAngle: animationController.value,
          pointerColor: widget.pointerColor,
          maxValue: widget.maxValue.toStringAsFixed(widget.decimalPlaces),
          minValue: widget.minValue.toStringAsFixed(widget.decimalPlaces),
          actualValue: widget.actualValue),
    );
  }
}

class RangePointerGaugePainter extends CustomPainter {
  RangePointerGaugePainter({
    required this.sweepAngle,
    required this.pointerColor,
    required this.minValue,
    required this.maxValue,
    required this.actualValue,
    Key? key,
  });
  final double sweepAngle;
  final Color pointerColor;
  final String minValue;
  final String maxValue;
  final double actualValue;

  dynamic getScale() {
    List<double> scaleLabel = [];
    final double interval = double.parse(maxValue) / 9;
    for (var i = 0; i < 9; i++) {
      scaleLabel.add((i * interval).roundToDouble());
      print(scaleLabel);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final startAngle = Utils.degreesToRadians(120);
    final backgroundSweepAngle = Utils.degreesToRadians(300);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 1 / 2;
    var arcRect = Rect.fromCircle(center: center, radius: radius);
    getScale();
    // Background Arc
    final backgroundArcPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
        arcRect, startAngle, backgroundSweepAngle, false, backgroundArcPaint);

    // Arc Pointer
    var pointerArcPaint = Paint()
      ..color = pointerColor
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, pointerArcPaint);

    // Arc Needle
    var needlePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.fill;

    var needle = Path();
    needle.moveTo(size.width / 2, size.height / 2);
    needle.relativeLineTo(10, 0);
    needle.lineTo((center.dx) + (radius - 15) * cos(pi / 1.5 + sweepAngle),
        (center.dx) + (radius - 15) * sin(pi / 1.5 + sweepAngle));
    needle.lineTo((center.dx) + radius * cos(pi / 1.5 + sweepAngle),
        (center.dx) + radius * sin(pi / 1.5 + sweepAngle));

    needle.close();

    canvas.drawPath(needle, needlePaint);

    final TextPainter maxValueTextPainter = TextPainter(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          text: maxValue,
        ),
        textDirection: TextDirection.ltr)
      ..layout(
        minWidth: size.width / 2,
        maxWidth: size.width / 2,
      );

    final minValueOffset = Offset(size.width / 4, size.height / 1);
    final maxValueOffset = Offset(size.width / 1.5, size.height / 1);

    maxValueTextPainter.paint(canvas, maxValueOffset);
  }

  @override
  bool shouldRepaint(RangePointerGaugePainter oldDelegate) {
    return true;
  }
}
