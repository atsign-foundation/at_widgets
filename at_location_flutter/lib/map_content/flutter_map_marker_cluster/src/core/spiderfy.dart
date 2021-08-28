import 'dart:math';

import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';

class Spiderfy {
  static final double pi2 = pi * 2;
  static const int spiralFootSeparation =
      28; //related to size of spiral (experiment!)
  static const int spiralLengthStart = 11;
  static const int spiralLengthFactor = 5;

  static const int circleStartAngle = 0;

  static List<Point<num>> spiral(int distanceMultiplier, int count, Point<num> center) {
    num legLength = distanceMultiplier * spiralLengthStart;
    int separation = distanceMultiplier * spiralFootSeparation;
    double lengthFactor = distanceMultiplier * spiralLengthFactor * pi2;
    num angle = 0;

    List<Point<num>> result = <Point<num>>[];
    // Higher index, closer position to cluster center.
    for (int i = count; i >= 0; i--) {
      // Skip the first position, so that we are already farther from center and we avoid
      // being under the default cluster icon (especially important for Circle Markers).
      if (i < count) {
        result[i] = Point<num>(center.x + legLength * cos(angle),
            center.y + legLength * sin(angle));
      }
      angle += separation / legLength + i * 0.0005;
      legLength += lengthFactor / angle;
    }
    return result;
  }

  static List<Point<num>> circle(int radius, int count, Point<num> center) {
    double angleStep = pi2 / count;
    List<Point<num>> result = <Point<num>>[];

    for (int i = 0; i < count; i++) {
      double angle = circleStartAngle + i * angleStep;

      result[i] = CustomPoint<double>(
          center.x + radius * cos(angle), center.y + radius * sin(angle));
    }
    return result;
  }
}
