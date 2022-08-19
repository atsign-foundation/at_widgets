import 'package:flutter/material.dart';
import 'package:radial_gauges/utils/utils.dart';

class SimpleGauge extends StatefulWidget {
  /// Creates a Range Pointer Gauge.
  ///
  /// The [actualValue] and [maxValue] must not be null.
  const SimpleGauge({
    required this.actualValue,
    required this.maxValue,
    this.unit,
    this.icon,
    this.minValue = 0,
    this.pointerColor = Colors.blue,
    this.decimalPlaces = 0,
    this.isAnimate = true,
    this.duration,
    Key? key,
  })  : assert(actualValue <= maxValue,
            'actualValue must be less than or equal to maxValue'),
        super(key: key);

  /// Sets the actual value of the gauge.
  final double actualValue;

  /// Sets the maximum value of the gauge.
  final double maxValue;

  /// Sets the unit of the [actualValue]. If no [icon] is selected this value will be ignored.
  final String? unit;

  /// Sets the icon in the center of the gauge.
  /// Typically an [Icon] widget.
  final Widget? icon;

  /// Sets the minimum value of the gauge.
  final double minValue;

  /// Sets the pointer color of the gauge.
  final Color pointerColor;

  /// Controls how much decimal places will be shown for the [actualValue] and [maxValue].
  final int decimalPlaces;

  /// Toggle on and off animation.
  final bool isAnimate;

  /// Sets a duration to control the speed of the animation.
  final Duration? duration;

  @override
  State<SimpleGauge> createState() => _SimpleGaugeState();
}

class _SimpleGaugeState extends State<SimpleGauge>
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
      duration: Utils.getDuration(
          isAnimate: widget.isAnimate, userDuration: widget.duration),
      vsync: this,
      upperBound: upperBound,
    );

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
          duration: Utils.getDuration(
              isAnimate: widget.isAnimate, userDuration: widget.duration));
    }
    return CustomPaint(
      painter: SimpleGaugePainter(
        sweepAngle: animationController.value,
        pointerColor: widget.pointerColor,
      ),
      child: Center(
          child: ListTile(
        title: widget.icon ??
            Text(
              '${Utils.sweepAngleRadianToActualValue(sweepAngle: animationController.value, maxValue: widget.maxValue).toStringAsFixed(widget.decimalPlaces)} ${widget.unit ?? ''} / ${widget.maxValue.toStringAsFixed(widget.decimalPlaces)} ${widget.unit ?? ''}',
              style: const TextStyle(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
        subtitle: widget.icon != null
            ? Text(
                '${Utils.sweepAngleRadianToActualValue(sweepAngle: animationController.value, maxValue: widget.maxValue).toStringAsFixed(widget.decimalPlaces)} ${widget.unit ?? ''}',
                style: const TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              )
            : null,
      )),
    );
  }
}

class SimpleGaugePainter extends CustomPainter {
  SimpleGaugePainter({
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
