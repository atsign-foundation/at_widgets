import 'package:flutter/material.dart';
import 'package:radial_gauges/utils/utils.dart';

class RangePointerGauge extends StatefulWidget {
  /// Creates a Range Pointer Gauge.
  ///
  /// The [minValue] and [maxValue] must not be null.
  RangePointerGauge({
    required this.minValue,
    required this.maxValue,
    this.pointerColor = Colors.blue,
    this.decimalPlaces = 0,
    this.animate = true,
    Key? key,
  }) : super(key: key);

  /// Sets the minimum value of the gauge.
  double minValue;

  /// Sets the maximum value of the gauge.
  double maxValue;

  /// Sets the pointer color of the gauge.
  final Color pointerColor;

  /// Controls how much decimal places will be shown for the [minValue] and [maxValue].
  final int decimalPlaces;

  /// Toggle on and off animation.
  final bool animate;

  @override
  State<RangePointerGauge> createState() => _RangePointerGaugeState();
}

class _RangePointerGaugeState extends State<RangePointerGauge>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    double sweepAngleRadian = Utils.minValueToSweepAngleRadian(
        minValue: widget.minValue, maxValue: widget.maxValue);

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
        Utils.minValueToSweepAngleRadian(
            minValue: widget.minValue, maxValue: widget.maxValue)) {
      animationController.animateTo(
          Utils.minValueToSweepAngleRadian(
              minValue: widget.minValue, maxValue: widget.maxValue),
          duration: Duration(seconds: widget.animate ? 1 : 0));
    }

    return RotatedBox(
      quarterTurns: 3,
      child: CustomPaint(
        painter: RangePointerGaugePainter(
          sweepAngle: animationController.value,
          pointerColor: widget.pointerColor,
        ),
        child: SizedBox(
          height: 200,
          width: 200,
          child: Center(
            child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  '${widget.minValue.toStringAsFixed(widget.decimalPlaces)} / ${widget.maxValue.toStringAsFixed(widget.decimalPlaces)}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                )),
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
    final startAngle = Utils.degreesToRadians(1);

    canvas.drawArc(arcRect, startAngle, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
