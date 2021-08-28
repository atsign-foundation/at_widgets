import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/map/map.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart' hide Path; // conflict with Path from UI

class PolygonLayerOptions extends LayerOptions {
  final List<Polygon> polygons;
  final bool polygonCulling;

  /// screen space culling of polygons based on bounding box
  PolygonLayerOptions({
    Key? key,
    this.polygons = const <Polygon>[],
    this.polygonCulling = false,
    dynamic rebuild,
  }) : super(key: key, rebuild: rebuild) {
    if (polygonCulling) {
      for (Polygon polygon in polygons) {
        polygon.boundingBox = LatLngBounds.fromPoints(polygon.points);
      }
    }
  }
}

class Polygon {
  final List<LatLng?>? points;
  final List<Offset> offsets = <Offset>[];
  final List<List<LatLng>>? holePointsList;
  final List<List<Offset>>? holeOffsetsList;
  final Color color;
  final double borderStrokeWidth;
  final Color borderColor;
  final bool disableHolesBorder;
  final bool isDotted;
  late LatLngBounds boundingBox;

  Polygon({
    this.points,
    this.holePointsList,
    this.color = const Color(0xFF00FF00),
    this.borderStrokeWidth = 0.0,
    this.borderColor = const Color(0xFFFFFF00),
    this.disableHolesBorder = false,
    this.isDotted = false,
  }) : holeOffsetsList = null == holePointsList || holePointsList.isEmpty
            ? null
            : List< List<Offset>>.generate(holePointsList.length, (_) => <Offset>[]);
}

class PolygonLayerWidget extends StatelessWidget {
  final PolygonLayerOptions options;
  PolygonLayerWidget({required this.options}) : super(key: options.key);

  @override
  Widget build(BuildContext context) {
    MapState mapState = MapState.of(context)!;
    return PolygonLayer(options, mapState, mapState.onMoved);
  }
}

class PolygonLayer extends StatelessWidget {
  final PolygonLayerOptions polygonOpts;
  final MapState? map;
  final Stream<void>? stream;

  PolygonLayer(this.polygonOpts, this.map, this.stream)
      : super(key: polygonOpts.key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints bc) {
        Size size = Size(bc.maxWidth, bc.maxHeight);
        return _build(context, size);
      },
    );
  }

  Widget _build(BuildContext context, Size size) {
    return StreamBuilder<void>(
      stream: stream, // a Stream<void> or null
      builder: (BuildContext context, _) {
        List<Widget> polygons = <Widget>[];

        for (Polygon polygon in polygonOpts.polygons) {
          polygon.offsets.clear();

          if (null != polygon.holeOffsetsList) {
            for (List<Offset> offsets in polygon.holeOffsetsList!) {
              offsets.clear();
            }
          }

          if (polygonOpts.polygonCulling &&
              !polygon.boundingBox.isOverlapping(map!.bounds)) {
            // skip this polygon as it's offscreen
            continue;
          }

          _fillOffsets(polygon.offsets, polygon.points!);

          if (null != polygon.holePointsList) {
            for (int i = 0, len = polygon.holePointsList!.length;
                i < len;
                ++i) {
              _fillOffsets(
                  polygon.holeOffsetsList![i], polygon.holePointsList![i]);
            }
          }

          polygons.add(
            CustomPaint(
              painter: PolygonPainter(polygon),
              size: size,
            ),
          );
        }

        return Container(
          child: Stack(
            children: polygons,
          ),
        );
      },
    );
  }

  void _fillOffsets(List<Offset> offsets, List<LatLng?> points) {
    for (int i = 0, len = points.length; i < len; ++i) {
      LatLng? point = points[i];

      CustomPoint<num> pos = map!.project(point);
      pos = pos.multiplyBy(map!.getZoomScale(map!.zoom, map!.zoom)) -
          map!.getPixelOrigin()!;
      offsets.add(Offset(pos.x.toDouble(), pos.y.toDouble()));
      if (i > 0) {
        offsets.add(Offset(pos.x.toDouble(), pos.y.toDouble()));
      }
    }
  }
}

class PolygonPainter extends CustomPainter {
  final Polygon polygonOpt;

  PolygonPainter(this.polygonOpt);

  @override
  void paint(Canvas canvas, Size size) {
    if (polygonOpt.offsets.isEmpty) {
      return;
    }
    Rect rect = Offset.zero & size;
    _paintPolygon(canvas, rect);
  }

  void _paintBorder(Canvas canvas) {
    if (polygonOpt.borderStrokeWidth > 0.0) {
      double borderRadius = (polygonOpt.borderStrokeWidth / 2);

      Paint borderPaint = Paint()
        ..color = polygonOpt.borderColor
        ..strokeWidth = polygonOpt.borderStrokeWidth;

      if (polygonOpt.isDotted) {
        double spacing = polygonOpt.borderStrokeWidth * 1.5;
        _paintDottedLine(
            canvas, polygonOpt.offsets, borderRadius, spacing, borderPaint);

        if (!polygonOpt.disableHolesBorder &&
            null != polygonOpt.holeOffsetsList) {
          for (List<Offset> offsets in polygonOpt.holeOffsetsList!) {
            _paintDottedLine(
                canvas, offsets, borderRadius, spacing, borderPaint);
          }
        }
      } else {
        _paintLine(canvas, polygonOpt.offsets, borderRadius, borderPaint);

        if (!polygonOpt.disableHolesBorder &&
            null != polygonOpt.holeOffsetsList) {
          for (List<Offset> offsets in polygonOpt.holeOffsetsList!) {
            _paintLine(canvas, offsets, borderRadius, borderPaint);
          }
        }
      }
    }
  }

  void _paintDottedLine(Canvas canvas, List<Offset> offsets, double radius,
      double stepLength, Paint paint) {
    double startDistance = 0.0;
    for (int i = 0; i < offsets.length - 1; i++) {
      Offset o0 = offsets[i];
      Offset o1 = offsets[i + 1];
      double totalDistance = _dist(o0, o1);
      double distance = startDistance;
      while (distance < totalDistance) {
        double f1 = distance / totalDistance;
        double f0 = 1.0 - f1;
        Offset offset = Offset(o0.dx * f0 + o1.dx * f1, o0.dy * f0 + o1.dy * f1);
        canvas.drawCircle(offset, radius, paint);
        distance += stepLength;
      }
      startDistance = distance < totalDistance
          ? stepLength - (totalDistance - distance)
          : distance - totalDistance;
    }
    canvas.drawCircle(offsets.last, radius, paint);
  }

  void _paintLine(
      Canvas canvas, List<Offset> offsets, double radius, Paint paint) {
    canvas.drawPoints(PointMode.lines, <Offset>[...offsets, offsets[0]], paint);
    for (Offset offset in offsets) {
      canvas.drawCircle(offset, radius, paint);
    }
  }

  void _paintPolygon(Canvas canvas, Rect rect) {
    Paint paint = Paint();

    if (null != polygonOpt.holeOffsetsList) {
      canvas.saveLayer(rect, paint);
      paint.style = PaintingStyle.fill;

      for (List<Offset> offsets in polygonOpt.holeOffsetsList!) {
        Path path = Path();
        path.addPolygon(offsets, true);
        canvas.drawPath(path, paint);
      }

      paint
        ..color = polygonOpt.color
        ..blendMode = BlendMode.srcOut;

      Path path = Path();
      path.addPolygon(polygonOpt.offsets, true);
      canvas.drawPath(path, paint);

      _paintBorder(canvas);

      canvas.restore();
    } else {
      canvas.clipRect(rect);
      paint
        ..style = PaintingStyle.fill
        ..color = polygonOpt.color;

      Path path = Path();
      path.addPolygon(polygonOpt.offsets, true);
      canvas.drawPath(path, paint);

      _paintBorder(canvas);
    }
  }

  @override
  bool shouldRepaint(PolygonPainter other) => false;

  double _dist(Offset v, Offset w) {
    return sqrt(_dist2(v, w));
  }

  double _dist2(Offset v, Offset w) {
    return _sqr(v.dx - w.dx) + _sqr(v.dy - w.dy);
  }

  double _sqr(double x) {
    return x * x;
  }
}
