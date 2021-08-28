import 'dart:math' as math;

import 'package:at_location_flutter/map_content/flutter_map/src/core/bounds.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/core/point.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';
import 'package:meta/meta.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;
import 'package:tuple/tuple.dart';

/// An abstract representation of a
/// [Coordinate Reference System](https://docs.qgis.org/testing/en/docs/gentle_gis_introduction/coordinate_reference_systems.html).
///
/// The main objective of a CRS is to handle the conversion between surface
/// points of objects of different dimensions. In our case 3D and 2D objects.
abstract class Crs {
  String get code;

  Projection get projection;

  Transformation get transformation;

  const Crs();

  /// Converts a point on the sphere surface (with a certain zoom) in a
  /// map point.
  CustomPoint<num> latLngToPoint(LatLng? latlng, double zoom) {
    try {
      CustomPoint<num> projectedPoint = projection.project(latlng);
      num scale = this.scale(zoom)!;
      return transformation.transform(projectedPoint, scale.toDouble());
    } catch (e) {
      return const CustomPoint<num>(0.0, 0.0);
    }
  }

  /// Converts a map point to the sphere coordinate (at a certain zoom).
  LatLng? pointToLatLng(CustomPoint<num> point, double zoom) {
    num scale = this.scale(zoom)!;
    CustomPoint<num> untransformedPoint =
        transformation.untransform(point, scale.toDouble());
    try {
      return projection.unproject(untransformedPoint);
    } catch (e) {
      return null;
    }
  }

  /// Zoom to Scale function.
  num? scale(double zoom) {
    return 256 * math.pow(2, zoom);
  }

  /// Scale to Zoom function.
  num zoom(double scale) {
    return math.log(scale / 256) / math.ln2;
  }

  /// Rescales the bounds to a given zoom value.
  Bounds<num>? getProjectedBounds(double zoom) {
    if (infinite) return null;

    Bounds<double> b = projection.bounds!;
    num s = scale(zoom)!;
    CustomPoint<num> min = transformation.transform(b.min, s.toDouble());
    CustomPoint<num> max = transformation.transform(b.max, s.toDouble());
    return Bounds<num>(min, max);
  }

  bool get infinite;

  Tuple2<double, double>? get wrapLng;

  Tuple2<double, double>? get wrapLat;
}

// Custom CRS for non geographical maps
class CrsSimple extends Crs {
  @override
  final String code = 'CRS.SIMPLE';

  @override
  final Projection projection;

  @override
  final Transformation transformation;

  CrsSimple()
      : projection = const _LonLat(),
        transformation = const Transformation(1, 0, -1, 0),
        super();

  @override
  bool get infinite => false;

  @override
  Tuple2<double, double>? get wrapLat => null;

  @override
  Tuple2<double, double>? get wrapLng => null;
}

abstract class Earth extends Crs {
  @override
  bool get infinite => false;

  @override
  final Tuple2<double, double> wrapLng = const Tuple2<double, double>(-180.0, 180.0);

  @override
  final Tuple2<double, double>? wrapLat = null;

  const Earth() : super();
}

/// The most common CRS used for rendering maps.
class Epsg3857 extends Earth {
  @override
  final String code = 'EPSG:3857';

  @override
  final Projection projection;

  @override
  final Transformation transformation;

  static const num _scale = 0.5 / (math.pi * SphericalMercator.r);

  const Epsg3857()
      : projection = const SphericalMercator(),
        transformation = const Transformation(_scale, 0.5, -_scale, 0.5),
        super();

//@override
//Tuple2<double, double> get wrapLat => const Tuple2(-85.06, 85.06);
}

/// A common CRS among GIS enthusiasts. Uses simple Equirectangular projection.
class Epsg4326 extends Earth {
  @override
  final String code = 'EPSG:4326';

  @override
  final Projection projection;

  @override
  final Transformation transformation;

  const Epsg4326()
      : projection = const _LonLat(),
        transformation = const Transformation(1 / 180, 0.5, -1 / 180, 0.5),
        super();
}

/// Custom CRS
class Proj4Crs extends Crs {
  @override
  final String code;

  @override
  final Projection projection;

  @override
  final Transformation transformation;

  @override
  final bool infinite;

  @override
  final Tuple2<double, double>? wrapLat = null;

  @override
  final Tuple2<double, double>? wrapLng = null;

  final List<Transformation>? _transformations;

  final List<double?> _scales;

  Proj4Crs._({
    required this.code,
    required this.projection,
    required this.transformation,
    required this.infinite,
    required List<Transformation>? transformations,
    required List<double?> scales,
    // ignore: unnecessary_null_comparison
  })  : assert(null != code),
        // ignore: unnecessary_null_comparison
        assert(null != projection),
        // ignore: unnecessary_null_comparison
        assert(null != transformation || null != transformations),
        // ignore: unnecessary_null_comparison
        assert(null != infinite),
        // ignore: unnecessary_null_comparison
        assert(null != scales),
        _transformations = transformations,
        _scales = scales;

  factory Proj4Crs.fromFactory({
    required String code,
    required proj4.Projection proj4Projection,
    Transformation? transformation,
    List<CustomPoint<num>>? origins,
    Bounds<double>? bounds,
    List<double?>? scales,
    List<double>? resolutions,
  }) {
    _Proj4Projection projection =
        _Proj4Projection(proj4Projection: proj4Projection, bounds: bounds);
    List<Transformation>? transformations;
    bool infinite = null == bounds;
    List<double?> finalScales;

    if (null != scales && scales.isNotEmpty) {
      finalScales = scales;
    } else if (null != resolutions && resolutions.isNotEmpty) {
      finalScales = resolutions.map((double r) => 1 / r).toList(growable: false);
    } else {
      throw Exception(
          'Please provide scales or resolutions to determine scales');
    }

    if (null == origins || origins.isEmpty) {
      transformation ??= const Transformation(1, 0, -1, 0);
    } else {
      if (origins.length == 1) {
        CustomPoint<num> origin = origins[0];
        transformation = Transformation(1, -origin.x, -1, origin.y);
      } else {
        transformations =
            origins.map((CustomPoint<num> p) => Transformation(1, -p.x, -1, p.y)).toList();
        transformation = null;
      }
    }

    return Proj4Crs._(
      code: code,
      projection: projection,
      transformation: transformation!,
      infinite: infinite,
      transformations: transformations,
      scales: finalScales,
    );
  }

  /// Converts a point on the sphere surface (with a certain zoom) in a
  /// map point.
  @override
  CustomPoint<num> latLngToPoint(LatLng? latlng, double zoom) {
    try {
      CustomPoint<num> projectedPoint = projection.project(latlng);
      num scale = this.scale(zoom)!;
      Transformation transformation = _getTransformationByZoom(zoom);

      return transformation.transform(projectedPoint, scale.toDouble());
    } catch (e) {
      return const CustomPoint<num>(0.0, 0.0);
    }
  }

  /// Converts a map point to the sphere coordinate (at a certain zoom).
  @override
  LatLng? pointToLatLng(CustomPoint<num> point, double zoom) {
    num scale = this.scale(zoom)!;
    Transformation transformation = _getTransformationByZoom(zoom);

    CustomPoint<num> untransformedPoint =
        transformation.untransform(point, scale.toDouble());
    try {
      return projection.unproject(untransformedPoint);
    } catch (e) {
      return null;
    }
  }

  /// Rescales the bounds to a given zoom value.
  @override
  Bounds<num>? getProjectedBounds(double zoom) {
    if (infinite) return null;

    Bounds<double> b = projection.bounds!;
    num s = scale(zoom)!;

    Transformation transformation = _getTransformationByZoom(zoom);

    CustomPoint<num> min = transformation.transform(b.min, s.toDouble());
    CustomPoint<num> max = transformation.transform(b.max, s.toDouble());
    return Bounds<num>(min, max);
  }

  /// Zoom to Scale function.
  @override
  num? scale(double zoom) {
    int iZoom = zoom.floor();
    if (zoom == iZoom) {
      return _scales[iZoom];
    } else {
      // Non-integer zoom, interpolate
      double baseScale = _scales[iZoom]!;
      double nextScale = _scales[iZoom + 1]!;
      double scaleDiff = nextScale - baseScale;
      double zDiff = (zoom - iZoom);
      return baseScale + scaleDiff * zDiff;
    }
  }

  /// Scale to Zoom function.
  @override
  num zoom(double scale) {
    // Find closest number in _scales, down
    double? downScale = _closestElement(_scales, scale);
    int downZoom = _scales.indexOf(downScale);
    // Check if scale is downScale => return array index
    if (scale == downScale) {
      return downZoom;
    }
    if (downScale == null) {
      return double.negativeInfinity;
    }
    // Interpolate
    int nextZoom = downZoom + 1;
    double? nextScale = _scales[nextZoom];
    if (nextScale == null) {
      return double.infinity;
    }
    double scaleDiff = nextScale - downScale;
    return (scale - downScale) / scaleDiff + downZoom;
  }

  /// Get the closest lowest element in an array
  double? _closestElement(List<double?> array, double element) {
    double? low;
    for (int i = array.length - 1; i >= 0; i--) {
      double curr = array[i]!;

      if (curr <= element && (null == low || low < curr)) {
        low = curr;
      }
    }
    return low;
  }

  /// returns Transformation object based on zoom
  Transformation _getTransformationByZoom(double zoom) {
    if (null == _transformations) {
      return transformation;
    }

    int iZoom = zoom.round();
    int lastIdx = _transformations!.length - 1;

    return _transformations![iZoom > lastIdx ? lastIdx : iZoom];
  }
}

abstract class Projection {
  const Projection();

  Bounds<double>? get bounds;

  CustomPoint<num> project(LatLng? latlng);

  LatLng unproject(CustomPoint<num> point);

  double _inclusive(Comparable<dynamic> start, Comparable<dynamic> end, double value) {
    if (value.compareTo(start as num) < 0) return start.toDouble();
    if (value.compareTo(end as num) > 0) return end.toDouble();

    return value;
  }

  @protected
  double inclusiveLat(double value) {
    return _inclusive(-90.0, 90.0, value);
  }

  @protected
  double inclusiveLng(double value) {
    if (value.compareTo(-180) < 0) return -180;
    if (value.compareTo(180) > 0) return 180;

    return value;
  }
}

class _LonLat extends Projection {
  static final Bounds<double> _bounds = Bounds<double>(
      const CustomPoint<double>(-180.0, -90.0), const CustomPoint<double>(180.0, 90.0));

  const _LonLat() : super();

  @override
  Bounds<double> get bounds => _bounds;

  @override
  CustomPoint<num> project(LatLng? latlng) {
    return CustomPoint<num>(latlng!.longitude, latlng.latitude);
  }

  @override
  LatLng unproject(CustomPoint<num> point) {
    return LatLng(
        inclusiveLat(point.y.toDouble()), inclusiveLng(point.x.toDouble()));
  }
}

class SphericalMercator extends Projection {
  static const int r = 6378137;
  static const double maxLatitude = 85.0511287798;
  static const double _boundsD = r * math.pi;
  static final Bounds<double> _bounds = Bounds<double>(
    const CustomPoint<double>(-_boundsD, -_boundsD),
    const CustomPoint<double>(_boundsD, _boundsD),
  );

  const SphericalMercator() : super();

  @override
  Bounds<double> get bounds => _bounds;

  @override
  CustomPoint<num> project(LatLng? latlng) {
    double d = math.pi / 180;
    double max = maxLatitude;
    double lat = math.max(math.min(max, latlng!.latitude), -max);
    double sin = math.sin(lat * d);

    return CustomPoint<num>(
        r * latlng.longitude * d, r * math.log((1 + sin) / (1 - sin)) / 2);
  }

  @override
  LatLng unproject(CustomPoint<num> point) {
    double d = 180 / math.pi;
    return LatLng(
        inclusiveLat(
            (2 * math.atan(math.exp(point.y / r)) - (math.pi / 2)) * d),
        inclusiveLng(point.x * d / r));
  }
}

class _Proj4Projection extends Projection {
  final proj4.Projection epsg4326;

  final proj4.Projection proj4Projection;

  @override
  final Bounds<double>? bounds;

  _Proj4Projection({
    required this.proj4Projection,
    required this.bounds,
  }) : epsg4326 = proj4.Projection.WGS84;

  @override
  CustomPoint<num> project(LatLng? latlng) {
    proj4.Point point = epsg4326.transform(
        proj4Projection, proj4.Point(x: latlng!.longitude, y: latlng.latitude));

    return CustomPoint<num>(point.x, point.y);
  }

  @override
  LatLng unproject(CustomPoint<num> point) {
    proj4.Point point2 = proj4Projection.transform(
        epsg4326, proj4.Point(x: point.x.toDouble(), y: point.y.toDouble()));

    return LatLng(inclusiveLat(point2.y), inclusiveLng(point2.x));
  }
}

class Transformation {
  final num a;
  final num b;
  final num c;
  final num d;

  const Transformation(this.a, this.b, this.c, this.d);

  CustomPoint<num> transform(CustomPoint<num> point, double scale) {
    //// Removed because of nulls safety
    // scale ??= 1.0;
    double x = scale * (a * point.x + b);
    double y = scale * (c * point.y + d);
    return CustomPoint<num>(x, y);
  }

  CustomPoint<num> untransform(CustomPoint<num> point, double scale) {
    //// Removed because of nulls safety
    // scale ??= 1.0;
    double x = (point.x / scale - b) / a;
    double y = (point.y / scale - d) / c;
    return CustomPoint<num>(x, y);
  }
}
