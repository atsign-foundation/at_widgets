import 'dart:math';

import 'package:flutter/material.dart';
import 'package:radial_gauges/utils/constants.dart';
import 'package:radial_gauges/utils/utils.dart';

import '../utils/enums.dart';

class RangeGauge extends StatefulWidget {
  /// Creates a Range Pointer Gauge.
  ///
  /// The [minValue], [maxValue] and [ranges] must not be null.
  const RangeGauge({
    this.minValue = 0,
    required this.maxValue,
    required this.actualValue,
    required this.ranges,
    this.size = 200,
    this.title,
    this.titlePosition = TitlePosition.top,
    this.pointerColor,
    this.decimalPlaces = 0,
    this.isAnimate = true,
    this.milliseconds = kDefaultAnimationDuration,
    this.strokeWidth = 70,
    this.actualValueTextStyle,
    this.maxDegree = kDefaultRangeGaugeMaxDegree,
    this.startDegree = kDefaultRangeGaugeStartDegree,
    this.isLegend = false,
    Key? key,
  })  : assert(actualValue <= maxValue,
            'actualValue must be less than or equal to maxValue'),
        assert(startDegree <= 360, 'startDegree must be less than 360'),
        super(key: key);

  /// Sets the minimum value of the gauge.
  final double minValue;

  /// Sets the maximum value of the gauge.
  final double maxValue;

  /// Sets the pointer value of the gauge.
  final double actualValue;

  /// Sets the ranges for the gauge.
  final List<Range> ranges;

  /// Sets the height and width of the gauge.
  ///
  /// If the parent widget has unconstrained height like a [ListView], wrap the gauge in a [SizedBox] to better control it's size.
  final double size;

  /// Sets the title of the gauge.
  final Text? title;

  /// Sets the position of the title.
  final TitlePosition titlePosition;

  /// Sets the pointer color of the gauge.
  final Color? pointerColor;

  /// Controls how much decimal places will be shown for the [minValue],[maxValue] and [actualValue].
  final int decimalPlaces;

  /// Toggle on and off animation.
  final bool isAnimate;

  /// Sets a duration in milliseconds to control the speed of the animation.
  final int milliseconds;

  /// Sets the stroke width of the ranges.
  final double strokeWidth;

  /// Sets the [TextStyle] for the actualValue.
  final TextStyle? actualValueTextStyle;

  /// Sets the [maxDegree] for the gauge.
  final double maxDegree;

  /// Sets the [startDegree] of the gauge.
  final double startDegree;

  /// Toggle on and off legend.
  final bool isLegend;

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

    double upperBound = Utils.degreesToRadians(widget.maxDegree);

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
            maxDegrees: widget.maxDegree)) {
      animationController.animateTo(
          Utils.actualValueToSweepAngleRadian(
              actualValue: widget.actualValue,
              maxValue: widget.maxValue,
              maxDegrees: widget.maxDegree),
          duration: Utils.getDuration(
              isAnimate: widget.isAnimate,
              userMilliseconds: widget.milliseconds));
    }

    return FittedBox(
      child: Column(
        children: [
          widget.titlePosition == TitlePosition.top
              ? SizedBox(
                  height: widget.strokeWidth - 10,
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
                painter: RangeGaugePainter(
                    sweepAngle: animationController.value,
                    pointerColor: widget.pointerColor,
                    maxValue:
                        widget.maxValue.toStringAsFixed(widget.decimalPlaces),
                    minValue:
                        widget.minValue.toStringAsFixed(widget.decimalPlaces),
                    ranges: widget.ranges,
                    actualValue: widget.actualValue,
                    decimalPlaces: widget.decimalPlaces,
                    strokeWidth: widget.strokeWidth,
                    actualValueTextStyle: widget.actualValueTextStyle,
                    maxDegree: widget.maxDegree,
                    startDegree: widget.startDegree,
                    isLegend: widget.isLegend),
              ),
            ),
          ),
          SizedBox(
            height: widget.titlePosition == TitlePosition.bottom
                ? widget.strokeWidth - 10
                : 0,
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
    required this.isLegend,
    required this.strokeWidth,
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
  final double strokeWidth;

  /// Sets the [TextStyle] for the actualValue.
  final TextStyle? actualValueTextStyle;

  /// Sets the [maxDegree] of the gauge
  final double maxDegree;

  /// Sets the [startDegree] of the gauge
  final double startDegree;

  /// Toggle on and off legend.
  final bool isLegend;

  @override
  void paint(Canvas canvas, Size size) {
    final startAngle = Utils.degreesToRadians(startDegree);
    final backgroundSweepAngle = Utils.degreesToRadians(maxDegree);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 1 / 2;
    var arcRect = Rect.fromCircle(center: center, radius: radius);

    // Create range arc first.
    double labelHeight = size.height / 2;
    for (final range in ranges) {
      final rangeArcPaint = Paint()
        ..color = range.backgroundColor
        ..strokeWidth = strokeWidth
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

      if (range.label != null && isLegend) {
        final TextPainter rangeLabelTextPainter = TextPainter(
            textAlign: TextAlign.start,
            text: TextSpan(
              style: range.legendTextStyle ??
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

        final rangeLabelOffset = Offset(size.width / 0.7, labelHeight);
        rangeLabelTextPainter.paint(canvas, rangeLabelOffset);

        final rangeLegendPaint = Paint()
          ..color = range.backgroundColor
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.butt
          ..style = PaintingStyle.stroke;
        // increase line height so label and color aligns
        labelHeight += 10;

        final rangeLineLabelOffsetStart =
            Offset(size.width / 0.72, labelHeight);
        final rangeLineLabelOffsetEnd = Offset(size.width / 0.78, labelHeight);
        if (startDegree >= 180) {
          labelHeight -= 27;
        } else {
          labelHeight += 10;
        }

        canvas.drawLine(rangeLineLabelOffsetStart, rangeLineLabelOffsetEnd,
            rangeLegendPaint);
      }
    }

    // Create range labels
    // for (var range in ranges) {
    //   if (range.label != null) {
    //     final TextPainter rangeLabelTextPainter = TextPainter(
    //         textAlign: TextAlign.left,
    //         text: TextSpan(
    //           style: range.labelTextStyle ??
    //               const TextStyle(
    //                 color: Colors.black,
    //               ),
    //           text: range.label,
    //         ),
    //         textDirection: TextDirection.ltr)
    //       ..layout(
    //         minWidth: size.width / 2,
    //         maxWidth: size.width / 2,
    //       );

    //     // apply sweep angle to arc angle formula

    //     final labelRadian = Utils.actualValueToSweepAngleRadian(
    //             actualValue: ((range.lowerLimit + range.upperLimit) / 2),
    //             maxValue: double.parse(maxValue),
    //             maxDegrees: maxDegree) +
    //         (startAngle - Utils.degreesToRadians(120));
    //     final rangeLabelOffset = Offset(
    //       (center.dx) + (radius) * cos(pi / 1.5 + (labelRadian)),
    //       (center.dx) + (radius) * sin(pi / 1.5 + (labelRadian)),
    //     );

    //     final rangeLabelOffset = Offset(size.width / 0.7, labelHeight);
    //     labelHeight += 16;

    //     rangeLabelTextPainter.paint(canvas, rangeLabelOffset);
    //   }
    // }

    // Arc Needle
    var needlePaint = Paint()
      ..color = pointerColor ?? Colors.black
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;
    const needleLengthConstraints = 15;

    // The sweepAngle start at 120 degrees from the start of a circle.
    var adjustedSweepAngle =
        sweepAngle + (startAngle - Utils.degreesToRadians(120));
    var needleEndPointOffset = Offset(
        (center.dx) +
            (radius - needleLengthConstraints) *
                cos(pi / 1.5 + (adjustedSweepAngle)),
        (center.dx) +
            (radius - needleLengthConstraints) *
                sin(pi / 1.5 + (adjustedSweepAngle)));

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
    var actualValueOffset = Offset(size.width / 2.2, size.height / 1.8);
    // adjust formula to be below arc

    // return offset of value

    // paint value to canvas
    valueTextPainter.paint(canvas, actualValueOffset);

    // canvas.save();
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
      this.legendTextStyle})
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
  final TextStyle? legendTextStyle;
}
