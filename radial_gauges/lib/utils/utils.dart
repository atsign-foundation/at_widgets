import 'dart:math' as math;

class Utils {
  static double degreesToRadians(double degrees) {
    return (degrees * math.pi) / 180;
  }

  static double minValueToSweepAngle({
    required double minValue,
    required double maxValue,
    required double maxDegrees,
  }) {
    final ratio = minValue / maxValue;
    return ratio * maxDegrees;
  }

  static double minValueToSweepAngleRadian(
      {required double minValue,
      required double maxValue,
      double maxDegrees = 360}) {
    return degreesToRadians(Utils.minValueToSweepAngle(
        minValue: minValue, maxValue: maxValue, maxDegrees: maxDegrees));
  }

  // static   double valueToDecimalPlaces(double value) {
  //   num mod = math.pow(10.0, widget.decimalPlaces);
  //   return ((value * mod).round().toDouble() / mod);
  // }
}
