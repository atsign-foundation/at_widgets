// import 'dart:math';
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:radial_gauges/utils/utils.dart';

// class RangeLabelGauge extends StatefulWidget {
//   /// Creates a Range Pointer Gauge.
//   ///
//   /// The [minValue], [maxValue] and [ranges] must not be null.
//   RangeLabelGauge({
//     this.minValue = 0,
//     required this.maxValue,
//     required this.actualValue,
//     required this.ranges,
//     this.pointerColor = Colors.blue,
//     this.decimalPlaces = 0,
//     this.animate = true,
//     Key? key,
//   }) : super(key: key);

//   /// Sets the minimum value of the gauge.
//   double minValue;

//   /// Sets the maximum value of the gauge.
//   double maxValue;

//   /// Sets the pointer value of the gauge.
//   double actualValue;

//   /// Sets the range parameters.
//   List<Range> ranges;

//   /// Sets the pointer color of the gauge.
//   final Color pointerColor;

//   /// Controls how much decimal places will be shown for the [minValue],[maxValue] and [actualValue].
//   final int decimalPlaces;

//   /// Toggle on and off animation.
//   final bool animate;

//   @override
//   State<RangeLabelGauge> createState() => _RangeLabelGaugeState();
// }

// class _RangeLabelGaugeState extends State<RangeLabelGauge>
//     with SingleTickerProviderStateMixin {
//   late Animation<double> animation;
//   late AnimationController animationController;

//   @override
//   void initState() {
//     super.initState();
//     double sweepAngleRadian = Utils.actualValueToSweepAngleRadian(
//         actualValue: widget.actualValue,
//         maxValue: widget.maxValue,
//         maxDegrees: 300);

//     double upperBound = Utils.degreesToRadians(300);

//     animationController = AnimationController(
//         duration: Duration(seconds: widget.animate ? 1 : 0),
//         vsync: this,
//         upperBound: upperBound);

//     animation = Tween<double>().animate(animationController)
//       ..addListener(() {
//         if (animationController.value == sweepAngleRadian) {
//           animationController.stop();
//         }

//         setState(() {});
//       });

//     animationController.forward();
//   }

//   @override
//   void dispose() {
//     animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (animationController.value !=
//         Utils.actualValueToSweepAngleRadian(
//             actualValue: widget.actualValue,
//             maxValue: widget.maxValue,
//             maxDegrees: 300)) {
//       animationController.animateTo(
//           Utils.actualValueToSweepAngleRadian(
//               actualValue: widget.actualValue,
//               maxValue: widget.maxValue,
//               maxDegrees: 300),
//           duration: Duration(seconds: widget.animate ? 1 : 0));
//     }

//     return CustomPaint(
//       painter: RangePointerGaugePainter(
//         sweepAngle: animationController.value,
//         pointerColor: widget.pointerColor,
//         maxValue: widget.maxValue.toStringAsFixed(widget.decimalPlaces),
//         minValue: widget.minValue.toStringAsFixed(widget.decimalPlaces),
//         ranges: widget.ranges,
//         actualValue: widget.actualValue,
//         decimalPlaces: widget.decimalPlaces,
//       ),
//     );
//   }
// }

// class RangePointerGaugePainter extends CustomPainter {
//   RangePointerGaugePainter({
//     required this.sweepAngle,
//     required this.pointerColor,
//     required this.minValue,
//     required this.maxValue,
//     required this.actualValue,
//     required this.decimalPlaces,
//     required this.ranges,
//     Key? key,
//   });
//   final double sweepAngle;
//   final Color pointerColor;
//   final String minValue;
//   final String maxValue;
//   final double actualValue;
//   final int decimalPlaces;
//   List<Range> ranges;

//   List<double> getScale(double divider) {
//     List<double> scale = [];
//     final double interval = double.parse(maxValue) / (divider - 1);
//     for (var i = 0; i < divider; i++) {
//       scale.add((i * interval).roundToDouble());
//     }
//     return scale;
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     final startAngle = Utils.degreesToRadians(120);
//     final backgroundSweepAngle = Utils.degreesToRadians(300);
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width * 1 / 2;
//     var arcRect = Rect.fromCircle(center: center, radius: radius);

//     // Background Arc
//     final backgroundArcPaint = Paint()
//       ..color = Colors.black12
//       ..strokeWidth = 5
//       ..style = PaintingStyle.stroke;

//     canvas.drawArc(
//         arcRect, startAngle, backgroundSweepAngle, false, backgroundArcPaint);

//     for (var range in ranges) {
//       var rangeArcPaint = Paint()
//         ..color = range.color
//         ..strokeWidth = 50
//         ..strokeCap = StrokeCap.butt
//         ..style = PaintingStyle.stroke;
//       final rangeStartAngle = Utils.actualValueToSweepAngleRadian(
//               actualValue: range.lowerLimit,
//               maxValue: double.parse(maxValue),
//               maxDegrees: 300) +
//           startAngle;
//       // Because the sweep angle is calculated from 0 the lowerlimit is subtracted from upperlimit to end the sweep angle at the correct degree on the arc.
//       final rangeSweepAngle = Utils.actualValueToSweepAngleRadian(
//           actualValue: range.upperLimit - range.lowerLimit,
//           maxValue: double.parse(maxValue),
//           maxDegrees: 300);
//       canvas.drawArc(
//           arcRect, rangeStartAngle, rangeSweepAngle, false, rangeArcPaint);
//       final TextPainter rangeLabelTextPainter = TextPainter(
//           textAlign: TextAlign.left,
//           text: TextSpan(
//             style: const TextStyle(
//               color: Colors.black,
//               fontSize: 10,
//             ),
//             text: range.label,
//           ),
//           textDirection: TextDirection.ltr)
//         ..layout(
//           minWidth: size.width / 2,
//           maxWidth: size.width / 2,
//         );

//       // apply sweep angle to arc angle formula
//       var rangeLabelOffset = Offset(
//         (center.dx) +
//             (radius - 20) * cos(pi / 1.5 + (rangeSweepAngle - rangeStartAngle)),
//         (center.dx) +
//             (radius - 20) * sin(pi / 1.5 + (rangeSweepAngle - rangeStartAngle)),
//       );

//       rangeLabelTextPainter.paint(canvas, rangeLabelOffset);
//     }
//     // Map of rangeName, upperlimit, lowerlimit, rangeColor

//     // Arc Needle
//     var needlePaint = Paint()
//       ..color = pointerColor
//       ..strokeWidth = 5
//       ..style = PaintingStyle.fill;

//     var needleEndPointOffset = Offset(
//       (center.dx) + (radius - 15) * cos(pi / 1.5 + sweepAngle),
//       (center.dx) + (radius - 15) * sin(pi / 1.5 + sweepAngle),
//     );

//     canvas.drawLine(center, needleEndPointOffset, needlePaint);
//     canvas.drawCircle(center, 5, needlePaint);

//     // paint scale increments

//     final TextPainter valueTextPainter = TextPainter(
//         text: TextSpan(
//           style: const TextStyle(color: Colors.black, fontSize: 10),
//           text: actualValue.toStringAsFixed(decimalPlaces),
//         ),
//         textDirection: TextDirection.ltr)
//       ..layout(
//         minWidth: size.width / 2,
//         maxWidth: size.width / 2,
//       );

//     // apply sweep angle to arc angle formula
//     var actualValueOffset = Offset(size.width / 2, size.height / 1);
//     // adjust formula to be below arc

//     // return offset of value

//     // paint value to canvas
//     valueTextPainter.paint(canvas, actualValueOffset);
//   }

//   @override
//   bool shouldRepaint(RangePointerGaugePainter oldDelegate) {
//     return true;
//   }
// }

// class Range {
//   Range(
//       {required this.label,
//       required this.lowerLimit,
//       required this.upperLimit,
//       required this.color});
//   final String label;
//   final double lowerLimit;
//   final double upperLimit;
//   final Color color;
// }
