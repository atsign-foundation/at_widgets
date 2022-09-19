import 'dart:math';

import 'package:flutter/material.dart';
import 'package:radial_gauges/utils/constants.dart';
import 'package:radial_gauges/utils/utils.dart';

import '../utils/enums.dart';

class ScaleGauge extends StatefulWidget {
  /// Creates a scale Gauge.
  ///
  /// The [minValue] and [maxValue] must not be null.
  const ScaleGauge({
    this.minValue = 0,
    required this.maxValue,
    required this.actualValue,
    this.size = 200,
    this.title,
    this.titlePosition = TitlePosition.top,
    this.arcColor = Colors.blue,
    this.needleColor = Colors.blue,
    this.decimalPlaces = 0,
    this.isAnimate = true,
    this.duration = kDefaultAnimationDuration,
    Key? key,
  })  : assert(actualValue <= maxValue,
            'actualValue must be less than or equal to maxValue'),
        assert(size >= 140, 'size must be greater than 75'),
        assert(actualValue >= minValue,
            'actualValue must be greater than minValue'),
        super(key: key);

  /// Sets the minimum value of the gauge.
  final double minValue;

  /// Sets the max value of the gauge.
  final double maxValue;

  /// Sets the actual value of the gauge.
  final double actualValue;

  /// Sets the width and height of the gauge.
  ///
  /// If the parent widget has unconstrained height like a [ListView], wrap the gauge in a [SizedBox] to better control it's size
  final double size;

  /// Sets the title of the gauge.
  final Text? title;

  /// Sets the position of the title.
  final TitlePosition titlePosition;

  /// Sets the arc color of the gauge.
  final Color arcColor;

  /// Sets the needle color of the gauge.
  final Color needleColor;

  /// Controls how much decimal places will be shown for the [minValue],[maxValue] and [actualValue].
  final int decimalPlaces;

  /// Toggle on and off animation.
  final bool isAnimate;

  /// Sets a duration in milliseconds to control the speed of the animation.
  final int duration;

  @override
  State<ScaleGauge> createState() => _ScaleGaugeState();
}

class _ScaleGaugeState extends State<ScaleGauge>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    double sweepAngleRadian = Utils.actualValueToSweepAngleRadian(
        actualValue: widget.actualValue,
        maxValue: widget.maxValue,
        minValue: widget.minValue,
        maxDegrees: 300);

    double upperBound = Utils.degreesToRadians(300);

    animationController = AnimationController(
        duration: Utils.getDuration(
            isAnimate: widget.isAnimate, userMilliseconds: widget.duration),
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
            minValue: widget.minValue,
            maxDegrees: 300)) {
      animationController.animateTo(
          Utils.actualValueToSweepAngleRadian(
              actualValue: widget.actualValue,
              maxValue: widget.maxValue,
              minValue: widget.minValue,
              maxDegrees: 300),
          duration: Utils.getDuration(
              isAnimate: widget.isAnimate, userMilliseconds: widget.duration));
    }

    return FittedBox(
      child: SizedBox(
        child: Column(
          children: [
            widget.titlePosition == TitlePosition.top
                ? SizedBox(
                    height: 20,
                    child: widget.title,
                  )
                : const SizedBox(
                    height: 20,
                  ),
            SizedBox(
              height: widget.size,
              width: widget.size,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomPaint(
                  painter: ScaleGaugeGaugePainter(
                    sweepAngle: animationController.value,
                    pointerColor: widget.arcColor,
                    needleColor: widget.needleColor,
                    minValue: widget.minValue,
                    maxValue: widget.maxValue,
                    actualValue: widget.actualValue,
                    decimalPlaces: widget.decimalPlaces,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            widget.titlePosition == TitlePosition.bottom
                ? SizedBox(
                    height: 30,
                    child: widget.title,
                  )
                : const SizedBox(
                    height: 20,
                  )
          ],
        ),
      ),
    );
  }
}

class ScaleGaugeGaugePainter extends CustomPainter {
  ScaleGaugeGaugePainter({
    required this.sweepAngle,
    required this.pointerColor,
    required this.minValue,
    required this.maxValue,
    required this.actualValue,
    required this.needleColor,
    required this.decimalPlaces,
    Key? key,
  });
  final double sweepAngle;
  final Color pointerColor;
  final double minValue;
  final double maxValue;
  final double actualValue;
  final Color needleColor;
  final int decimalPlaces;

  List<double> getScale(double divider) {
    List<double> scale = [];
    final double interval = maxValue / (divider - 1);
    for (var i = 0; i < divider; i++) {
      scale.add((i * interval).roundToDouble());
    }
    scale.removeWhere((element) => element < minValue);
    return scale;
  }

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
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, pointerArcPaint);

    // Arc Needle
    var needlePaint = Paint()
      ..color = needleColor
      ..strokeWidth = 5
      ..style = PaintingStyle.fill;

    var needleEndPointOffset = Offset(
      (center.dx) + (radius - 15) * cos(pi / 1.5 + sweepAngle),
      (center.dx) + (radius - 15) * sin(pi / 1.5 + sweepAngle),
    );

    canvas.drawLine(center, needleEndPointOffset, needlePaint);
    canvas.drawCircle(center, 5, needlePaint);

    // paint scale increments
    for (var value in getScale(10)) {
      final TextPainter valueTextPainter = TextPainter(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
          ),
          text: value.toStringAsFixed(0),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      // get sweep angle for every value
      var scaleSweepAngle = Utils.actualValueToSweepAngleRadian(
          actualValue: value,
          maxValue: maxValue,
          maxDegrees: 300,
          minValue: minValue);
      // apply sweep angle to arc angle formula
      var scaleOffset = Offset(
          (center.dx) +
              (radius - scaleSweepAngle - 20) * cos(pi / 1.5 + scaleSweepAngle),
          (center.dx) +
              (radius - scaleSweepAngle - 15) *
                  sin(pi / 1.5 + scaleSweepAngle));
      // adjust formula to be below arc

      // return offset of value

      // paint value to canvas

      valueTextPainter.paint(canvas, scaleOffset);
      // Stroke Cap Circle
      var strokeCapCirclePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 5
        ..style = PaintingStyle.fill;

      var strokeCapCircleOffset = Offset(
        (center.dx) + radius * cos(pi / 1.5 + scaleSweepAngle + 0),
        (center.dx) + radius * sin(pi / 1.5 + scaleSweepAngle + 0),
      );
      var strokeCapCircleRadius = 3.0;

      canvas.drawCircle(
          strokeCapCircleOffset, strokeCapCircleRadius, strokeCapCirclePaint);
    }

    // If minimum value greater than zero turn off animation.
    final TextPainter actualValueTextPainter = TextPainter(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          text: minValue == 0
              ? Utils.sweepAngleRadianToActualValue(
                      sweepAngle: sweepAngle,
                      maxValue: maxValue,
                      maxDegrees: 300)
                  .toStringAsFixed(decimalPlaces)
              : actualValue.toStringAsFixed(decimalPlaces),
        ),
        textDirection: TextDirection.ltr)
      ..layout(
        minWidth: size.width / 2,
        maxWidth: size.width / 2,
      );

    final actualValueOffset = Offset(size.width / 2.2, size.height / 1.6);

    actualValueTextPainter.paint(canvas, actualValueOffset);
  }

  @override
  bool shouldRepaint(ScaleGaugeGaugePainter oldDelegate) {
    return true;
  }
}
