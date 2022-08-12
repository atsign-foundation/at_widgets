import 'dart:math' as math;

class Utils {
  static double degreesToRadians(double degrees) {
    return (degrees * math.pi) / 180;
  }

  static double minValueToSweepAngle(
      {required double minValue, required double maxValue}) {
    final ratio = minValue / maxValue;
    return ratio * 360;
  }

  // static   double valueToDecimalPlaces(double value) {
  //   num mod = math.pow(10.0, widget.decimalPlaces);
  //   return ((value * mod).round().toDouble() / mod);
  // }
}
