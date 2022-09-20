import 'dart:math' as math;

import 'package:radial_gauges/utils/constants.dart';

class Utils {
  /// Convert [degrees] to radians.
  static double degreesToRadians(double degrees) {
    return (degrees * math.pi) / 180;
  }

  /// Convert [radians] to degrees.
  static double radiansToDegrees(double radians) {
    return (radians * 180) / math.pi;
  }

  /// Convert the [actualValue] to sweepAngle.
  static double actualValueToSweepAngle({
    required double actualValue,
    required double maxValue,
    required double maxDegrees,
    double minValue = 0,
  }) {
    final ratio = (actualValue - minValue) / (maxValue - minValue);
    return ratio * maxDegrees;
  }

  /// Convert [actualValue] to sweepAngleRadian.
  static double actualValueToSweepAngleRadian({
    required double actualValue,
    required double maxValue,
    required double minValue,
    double maxDegrees = 360,
  }) {
    return degreesToRadians(Utils.actualValueToSweepAngle(
        actualValue: actualValue,
        maxValue: maxValue,
        maxDegrees: maxDegrees,
        minValue: minValue));
  }

  /// Convert the [sweepAngle] to ActualValue.
  static double sweepAngleToActualValue(
      {required double sweepAngle,
      required double maxValue,
      required double maxDegrees,
      required double minValue}) {
    // final ratio = sweepAngle / maxDegrees;
    // return ratio * maxValue;

    return radiansToDegrees(sweepAngle) * ((maxValue - minValue) / maxDegrees) +
        minValue;
  }

  /// Convert sweepAngleRadian to [actualValue].
  static double sweepAngleRadianToActualValue(
      {required double sweepAngle,
      required double maxValue,
      required double minValue,
      double maxDegrees = 360}) {
    // return Utils.sweepAngleToActualValue(
    //     sweepAngle: sweepAngle, maxValue: maxValue, maxDegrees: maxDegrees);
    return Utils.sweepAngleToActualValue(
        sweepAngle: sweepAngle,
        maxValue: maxValue,
        maxDegrees: maxDegrees,
        minValue: minValue);
  }

  // static   double valueToDecimalPlaces(double value) {
  //   num mod = math.pow(10.0, widget.decimalPlaces);
  //   return ((value * mod).round().toDouble() / mod);
  // }

  static Duration getDuration(
      {required bool isAnimate, required int userMilliseconds}) {
    if (isAnimate) {
      return Duration(milliseconds: userMilliseconds);
    } else {
      return const Duration(milliseconds: kNoAnimationDuration);
    }
  }
}
