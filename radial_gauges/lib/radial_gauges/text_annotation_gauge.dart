import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:radial_gauges/utils/utils.dart';

class TextAnnotationGauge extends StatefulWidget {
  /// Creates a Range Pointer Gauge.
  ///
  /// The [minValue] and [maxValue] must not be null.
  TextAnnotationGauge({
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
  State<TextAnnotationGauge> createState() => _TextAnnotationGaugeState();
}

class _TextAnnotationGaugeState extends State<TextAnnotationGauge>
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
      child: SizedBox(
        height: 200,
        width: 200,
        child: Center(
          child: ListTile(
            title: Text(
              Utils.sweepAngleRadianToActualValue(
                      sweepAngle: animationController.value,
                      maxValue: widget.maxValue,
                      maxDegrees: 300)
                  .toStringAsFixed(widget.decimalPlaces),
              textAlign: TextAlign.center,
            ),
            subtitle: Text(
              widget.label,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
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

  @override
  void paint(Canvas canvas, Size size) {
    final startAngle = Utils.degreesToRadians(120);
    final backgroundSweepAngle = Utils.degreesToRadians(300);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 1 / 2;
    var arcRect = Rect.fromCircle(center: center, radius: radius);

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
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, pointerArcPaint);

    // Stroke Cap Circle
    var strokeCapCirclePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.fill;

    var strokeCapCircleOffset = Offset(
        (center.dx) + radius * cos(pi / 1.5 + sweepAngle),
        (center.dx) + radius * sin(pi / 1.5 + sweepAngle));
    var strokeCapCircleRadius = 3.0;

    canvas.drawCircle(
        strokeCapCircleOffset, strokeCapCircleRadius, strokeCapCirclePaint);

    // Labels
    final TextPainter minValueTextPainter = TextPainter(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          text: minValue,
        ),
        textDirection: TextDirection.ltr)
      ..layout(
        minWidth: size.width / 2,
        maxWidth: size.width / 2,
      );

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
    minValueTextPainter.paint(canvas, minValueOffset);
    maxValueTextPainter.paint(canvas, maxValueOffset);
    print('relative width is: ${size.width}');
  }

  @override
  bool shouldRepaint(RangePointerGaugePainter oldDelegate) {
    return true;
  }
}
