import 'dart:math';

import 'package:flutter/material.dart';
import 'package:radial_gauges/utils/constants.dart';
import 'package:radial_gauges/utils/utils.dart';

class RangeGauge extends StatefulWidget {
  /// Creates a Range Pointer Gauge.
  ///
  /// The [minValue], [maxValue] and [ranges] must not be null.
  const RangeGauge({
    this.minValue = 0,
    required this.maxValue,
    required this.actualValue,
    required this.ranges,
    this.pointerColor,
    this.decimalPlaces = 0,
    this.isAnimate = true,
    this.milliseconds = kDefaultAnimationDuration,
    this.strokeWidth,
    this.actualValueTextStyle,
    this.maxDegree = kDefaultRangeGaugeMaxDegree,
    this.startDegree = kDefaultRangeGaugeStartDegree,
    Key? key,
  }) : super(key: key);

  /// Sets the minimum value of the gauge.
  final double minValue;

  /// Sets the maximum value of the gauge.
  final double maxValue;

  /// Sets the pointer value of the gauge.
  final double actualValue;

  /// Sets the ranges for the gauge.
  final List<Range> ranges;

  /// Sets the pointer color of the gauge.
  final Color? pointerColor;

  /// Controls how much decimal places will be shown for the [minValue],[maxValue] and [actualValue].
  final int decimalPlaces;

  /// Toggle on and off animation.
  final bool isAnimate;

  /// Sets a duration in milliseconds to control the speed of the animation.
  final int milliseconds;

  /// Sets the stroke width of the ranges.
  final double? strokeWidth;

  /// Sets the [TextStyle] for the actualValue.
  final TextStyle? actualValueTextStyle;

  /// Sets the [maxDegree] for the gauge.
  final double maxDegree;

  /// Sets the [startDegree] of the gauge
  final double startDegree;

  @override
  State<RangeGauge> createState() => _RangeGaugeState();
}

class _RangeGaugeState extends State<RangeGauge>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    double sweepAngleRadian = Utils.actualValueToSweepAngleRadian(
        actualValue: widget.actualValue,
        maxValue: widget.maxValue,
        maxDegrees: widget.maxDegree);

    double upperBound = Utils.degreesToRadians(kDefaultRangeGaugeMaxDegree);

    animationController = AnimationController(
        duration: Utils.getDuration(
            isAnimate: widget.isAnimate, userMilliseconds: widget.milliseconds),
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
            maxDegrees: kDefaultRangeGaugeMaxDegree)) {
      animationController.animateTo(
          Utils.actualValueToSweepAngleRadian(
              actualValue: widget.actualValue,
              maxValue: widget.maxValue,
              maxDegrees: kDefaultRangeGaugeMaxDegree),
          duration: Utils.getDuration(
              isAnimate: widget.isAnimate,
              userMilliseconds: widget.milliseconds));
    }

    return CustomPaint(
      painter: RangeGaugePainter(
        sweepAngle: animationController.value,
        pointerColor: widget.pointerColor,
        maxValue: widget.maxValue.toStringAsFixed(widget.decimalPlaces),
        minValue: widget.minValue.toStringAsFixed(widget.decimalPlaces),
        ranges: widget.ranges,
        actualValue: widget.actualValue,
        decimalPlaces: widget.decimalPlaces,
        strokeWidth: widget.strokeWidth,
        actualValueTextStyle: widget.actualValueTextStyle,
        maxDegree: widget.maxDegree,
        startDegree: widget.startDegree,
      ),
    );
  }
}

class RangeGaugePainter extends CustomPainter {
  RangeGaugePainter({
    required this.sweepAngle,
    required this.pointerColor,
    required this.minValue,
    required this.maxValue,
    required this.actualValue,
    required this.decimalPlaces,
    required this.ranges,
    required this.maxDegree,
    required this.startDegree,
    this.strokeWidth,
    this.actualValueTextStyle,
    Key? key,
  });
  final double sweepAngle;
  final Color? pointerColor;
  final String minValue;
  final String maxValue;
  final double actualValue;
  final int decimalPlaces;

  /// Sets the ranges for the gauge.
  List<Range> ranges;

  /// Sets the [strokeWidth] of the ranges.
  final double? strokeWidth;

  /// Sets the [TextStyle] for the actualValue.
  final TextStyle? actualValueTextStyle;

  /// Sets the [maxDegree] of the gauge
  final double maxDegree;

  /// Sets the [startDegree] of the gauge
  final double startDegree;

  List<double> getScale(double divider) {
    List<double> scale = [];
    final double interval = double.parse(maxValue) / (divider - 1);
    for (var i = 0; i < divider; i++) {
      scale.add((i * interval).roundToDouble());
    }
    return scale;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const double kDefaultStrokeWidth = 70;
    final startAngle = Utils.degreesToRadians(startDegree);
    final backgroundSweepAngle = Utils.degreesToRadians(maxDegree);
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

    for (var range in ranges) {
      var rangeArcPaint = Paint()
        ..color = range.backgroundColor
        ..strokeWidth = strokeWidth ?? kDefaultStrokeWidth
        ..strokeCap = StrokeCap.butt
        ..style = PaintingStyle.stroke;
      final rangeStartAngle = Utils.actualValueToSweepAngleRadian(
              actualValue: range.lowerLimit,
              maxValue: double.parse(maxValue),
              maxDegrees: maxDegree) +
          startAngle;
      // Because the sweep angle is calculated from 0 the lowerlimit is subtracted from upperlimit to end the sweep angle at the correct degree on the arc.
      final rangeSweepAngle = Utils.actualValueToSweepAngleRadian(
          actualValue: range.upperLimit - range.lowerLimit,
          maxValue: double.parse(maxValue),
          maxDegrees: maxDegree);
      canvas.drawArc(
          arcRect, rangeStartAngle, rangeSweepAngle, false, rangeArcPaint);
    }

    for (var range in ranges) {
      if (range.label != null) {
        final TextPainter rangeLabelTextPainter = TextPainter(
            textAlign: TextAlign.left,
            text: TextSpan(
              style: range.labelTextStyle ??
                  const TextStyle(
                    color: Colors.black,
                  ),
              text: range.label,
            ),
            textDirection: TextDirection.ltr)
          ..layout(
            minWidth: size.width / 2,
            maxWidth: size.width / 2,
          );

        // apply sweep angle to arc angle formula

        final labelRadian = Utils.actualValueToSweepAngleRadian(
            actualValue: ((range.lowerLimit + range.upperLimit) / 2),
            maxValue: double.parse(maxValue),
            maxDegrees: maxDegree);
        final rangeLabelOffset = Offset(
          (center.dx) + (radius) * cos(pi / 1.5 + (labelRadian)),
          (center.dx) + (radius) * sin(pi / 1.5 + (labelRadian)),
        );

        rangeLabelTextPainter.paint(canvas, rangeLabelOffset);
      }
    }

    // Arc Needle
    var needlePaint = Paint()
      ..color = pointerColor ?? Colors.black
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;
    const needleLengthConstraints = 15;
    var needleEndPointOffset = Offset(
      (center.dx) +
          (radius - needleLengthConstraints) * cos(pi / 1.5 + sweepAngle),
      (center.dx) +
          (radius - needleLengthConstraints) * sin(pi / 1.5 + sweepAngle),
    );

    canvas.drawLine(center, needleEndPointOffset, needlePaint);
    canvas.drawCircle(center, 5, needlePaint);

    // paint scale increments

    final TextPainter valueTextPainter = TextPainter(
        text: TextSpan(
          style: actualValueTextStyle ??
              const TextStyle(
                color: Colors.black,
              ),
          text: Utils.sweepAngleRadianToActualValue(
                  sweepAngle: sweepAngle,
                  maxValue: double.parse(maxValue),
                  maxDegrees: maxDegree)
              .toStringAsFixed(decimalPlaces),
        ),
        textDirection: TextDirection.ltr)
      ..layout(
        minWidth: size.width / 2,
        maxWidth: size.width / 2,
      );

    // apply sweep angle to arc angle formula
    var actualValueOffset = Offset(size.width / 2, size.height / 1);
    // adjust formula to be below arc

    // return offset of value

    // paint value to canvas
    valueTextPainter.paint(canvas, actualValueOffset);
  }

  @override
  bool shouldRepaint(RangeGaugePainter oldDelegate) {
    return true;
  }
}

class Range {
  Range(
      {this.label,
      required this.lowerLimit,
      required this.upperLimit,
      required this.backgroundColor,
      this.labelTextStyle})
      : assert(lowerLimit <= upperLimit,
            'lowerLimit must be less than or equal to upperLimit');

  /// Sets the label of the range.
  final String? label;

  /// Sets the [lowerLimit] of the range.
  final double lowerLimit;

  /// Sets the [upperLimit] of the range.
  final double upperLimit;

  /// Sets the color of the range.
  final Color backgroundColor;

  /// Sets the TextStyle for the [label].
  final TextStyle? labelTextStyle;
}
