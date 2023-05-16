import 'dart:math' as math;

class CustomPoint<T extends num> extends math.Point<T> {
  const CustomPoint(num x, num y) : super((x as T), (y as T));

  CustomPoint<T> operator /(num /*T|int*/ factor) {
    return CustomPoint<T>(x / factor, y / factor);
  }

  CustomPoint<T> ceil() {
    return CustomPoint(x.ceil(), y.ceil());
  }

  CustomPoint<T> floor() {
    return CustomPoint<T>(x.floor(), y.floor());
  }

  CustomPoint<T> unscaleBy(CustomPoint<T> point) {
    return CustomPoint<T>(x / point.x, y / point.y);
  }

  @override
  CustomPoint<T> operator +(math.Point<T> other) {
    return CustomPoint<T>(x + other.x, y + other.y);
  }

  @override
  CustomPoint<T> operator -(math.Point<T> other) {
    return CustomPoint<T>(x - other.x, y - other.y);
  }

  @override
  CustomPoint<T> operator *(num /*T|int*/ factor) {
    return CustomPoint<T>((x * factor), (y * factor));
  }

  CustomPoint scaleBy(CustomPoint point) {
    return CustomPoint(x * point.x, y * point.y);
  }

  CustomPoint round() {
    var x = this.x is double ? this.x.round() : this.x;
    var y = this.y is double ? this.y.round() : this.y;
    return CustomPoint(x, y);
  }

  CustomPoint multiplyBy(num n) {
    return CustomPoint(x * n, y * n);
  }

  @override
  String toString() => 'CustomPoint ($x, $y)';
}
