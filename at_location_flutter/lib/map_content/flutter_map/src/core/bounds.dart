import 'dart:math' as math;
import 'package:at_location_flutter/map_content/flutter_map/src/core/point.dart';

/// Rectangular bound delimited by orthogonal lines passing through two
/// points.
class Bounds<T extends num> {
  final CustomPoint<T> min;
  final CustomPoint<T> max;

  factory Bounds(CustomPoint<T> a, CustomPoint<T> b) {
    Bounds<T> bounds1 = Bounds<T>._(a, b);
    Bounds<T> bounds2 = bounds1.extend(a);
    return bounds2.extend(b);
  }

  const Bounds._(this.min, this.max);

  /// Creates a new [Bounds] obtained by expanding the current ones with a new
  /// point.
  Bounds<T> extend(CustomPoint<T> point) {
    CustomPoint<T> newMin;
    CustomPoint<T> newMax;
    // ignore: unnecessary_null_comparison
    if (min == null && max == null) {
      newMin = point;
      newMax = point;
    } else {
      T minX = math.min(point.x, min.x);
      T maxX = math.max(point.x, max.x);
      T minY = math.min(point.y, min.y);
      T maxY = math.max(point.y, max.y);
      newMin = CustomPoint<T>(minX, minY);
      newMax = CustomPoint<T>(maxX, maxY);
    }
    return Bounds<T>._(newMin, newMax);
  }

  /// This [Bounds] cental point.
  CustomPoint<double> getCenter() {
    return CustomPoint<double>(
      (min.x + max.x) / 2,
      (min.y + max.y) / 2,
    );
  }

  /// Bottom-Left corner's point.
  CustomPoint<T> get bottomLeft => CustomPoint<T>(min.x, max.y);

  /// Top-Right corner's point.
  CustomPoint<T> get topRight => CustomPoint<T>(max.x, min.y);

  /// Top-Left corner's point.
  CustomPoint<T> get topLeft => min;

  /// Bottom-Right corner's point.
  CustomPoint<T> get bottomRight => max;

  /// A point that contains the difference between the point's axis projections.
  CustomPoint<T> get size {
    return max - min;
  }

  bool contains(CustomPoint<T> point) {
    CustomPoint<T> min = point;
    CustomPoint<T> max = point;
    return containsBounds(Bounds<T>(min, max));
  }

  bool containsBounds(Bounds<T> b) {
    return (b.min.x >= min.x) &&
        (b.max.x <= max.x) &&
        (b.min.y >= min.y) &&
        (b.max.y <= max.y);
  }

  bool containsPartialBounds(Bounds<T> b) {
    return (b.min.x <= max.x) &&
        (b.max.x >= min.x) &&
        (b.min.y <= max.y) &&
        (b.max.y >= min.y);
  }

  @override
  String toString() => 'Bounds($min, $max)';
}
