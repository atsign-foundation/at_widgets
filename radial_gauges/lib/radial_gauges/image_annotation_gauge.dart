import 'package:flutter/material.dart';
import 'package:radial_gauges/utils/utils.dart';

class ImageAnnotationGauge extends StatefulWidget {
  /// Creates a Range Pointer Gauge.
  ///
  /// The [actualValue] and [maxValue] must not be null.
  ImageAnnotationGauge({
    required this.actualValue,
    required this.maxValue,
    this.unit,
    this.image,
    this.minValue = 0,
    this.pointerColor = Colors.blue,
    this.decimalPlaces = 0,
    this.animate = true,
    Key? key,
  }) : super(key: key);

  /// Sets the actual value of the gauge.
  double actualValue;

  /// Sets the maximum value of the gauge.
  double maxValue;

  /// Sets the unit of the [actualValue]
  String? unit;

  Widget? image;

  /// Sets the minimum value of the gauge.
  double minValue;

  /// Sets the pointer color of the gauge.
  final Color pointerColor;

  /// Controls how much decimal places will be shown for the [actualValue] and [maxValue].
  final int decimalPlaces;

  /// Toggle on and off animation.
  final bool animate;

  @override
  State<ImageAnnotationGauge> createState() => _ImageAnnotationGaugeState();
}

class _ImageAnnotationGaugeState extends State<ImageAnnotationGauge>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    double sweepAngleRadian = Utils.actualValueToSweepAngleRadian(
        actualValue: widget.actualValue, maxValue: widget.maxValue);

    double upperBound = Utils.degreesToRadians(360);

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
            actualValue: widget.actualValue, maxValue: widget.maxValue)) {
      animationController.animateTo(
          Utils.actualValueToSweepAngleRadian(
              actualValue: widget.actualValue, maxValue: widget.maxValue),
          duration: Duration(seconds: widget.animate ? 1 : 0));
    }

    return CustomPaint(
      painter: RangePointerGaugePainter(
        sweepAngle: animationController.value,
        pointerColor: widget.pointerColor,
      ),
      child: Center(
          child: ListTile(
        title: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 50, maxWidth: 50),
          child: widget.image,
        ),
        subtitle: Text(
          '${Utils.sweepAngleRadianToActualValue(sweepAngle: animationController.value, maxValue: widget.maxValue).toStringAsFixed(widget.decimalPlaces)} ${widget.unit ?? ''}',
          style: const TextStyle(fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      )),
    );
  }
}

class RangePointerGaugePainter extends CustomPainter {
  RangePointerGaugePainter({
    required this.sweepAngle,
    required this.pointerColor,
    Key? key,
  });
  final double sweepAngle;

  final Color pointerColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Circle
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 1 / 2;
    final circlePaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, circlePaint);

    // Arc
    var arcPaint = Paint()
      ..color = pointerColor
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    var arcRect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = Utils.degreesToRadians(-90);

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
