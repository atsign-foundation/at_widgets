import 'dart:math' as math;

class CustomPoint<T extends num> extends math.Point<T> {
  const CustomPoint(num x, num y) : super((x as T), (y as T));

  CustomPoint<T> operator /(num /*T|int*/ factor) {
    return CustomPoint<T>(x / factor, y / factor);
  }

  CustomPoint<T> ceil() {
    return CustomPoint<T>(x.ceil(), y.ceil());
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

  CustomPoint<num> scaleBy(CustomPoint<num> point) {
    return CustomPoint<num>(x * point.x, y * point.y);
  }

  CustomPoint<num> round() {
    num x = this.x is double ? this.x.round() : this.x;
    num y = this.y is double ? this.y.round() : this.y;
    return CustomPoint<num>(x, y);
  }

  CustomPoint<num> multiplyBy(num n) {
    return CustomPoint<num>(x * n, y * n);
  }

  @override
  String toString() => 'CustomPoint ($x, $y)';
}
