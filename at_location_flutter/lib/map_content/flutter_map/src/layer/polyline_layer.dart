import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/map/map.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';

class PolylineLayerOptions extends LayerOptions {
  final List<Polyline> polylines;
  final bool polylineCulling;

  PolylineLayerOptions({
    Key? key,
    this.polylines = const <Polyline>[],
    this.polylineCulling = false,
    dynamic rebuild,
  }) : super(key: key, rebuild: rebuild) {
    if (polylineCulling) {
      for (Polyline polyline in polylines) {
        polyline.boundingBox = LatLngBounds.fromPoints(polyline.points);
      }
    }
  }
}

class Polyline {
  final List<LatLng>? points;
  final List<Offset> offsets = <Offset>[];
  final double strokeWidth;
  final Color color;
  final double borderStrokeWidth;
  final Color borderColor;
  final List<Color>? gradientColors;
  final List<double>? colorsStop;
  final bool isDotted;
  late LatLngBounds boundingBox;

  Polyline({
    this.points,
    this.strokeWidth = 1.0,
    this.color = const Color(0xFF00FF00),
    this.borderStrokeWidth = 0.0,
    this.borderColor = const Color(0xFFFFFF00),
    this.gradientColors,
    this.colorsStop,
    this.isDotted = false,
  });
}

class PolylineLayerWidget extends StatelessWidget {
  final PolylineLayerOptions options;
  PolylineLayerWidget({required this.options}) : super(key: options.key);

  @override
  Widget build(BuildContext context) {
    MapState mapState = MapState.of(context)!;
    return PolylineLayer(options, mapState, mapState.onMoved);
  }
}

class PolylineLayer extends StatelessWidget {
  final PolylineLayerOptions polylineOpts;
  final MapState? map;
  final Stream<void>? stream;

  PolylineLayer(this.polylineOpts, this.map, this.stream) : super(key: polylineOpts.key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints bc) {
        ui.Size size = Size(bc.maxWidth, bc.maxHeight);
        return _build(context, size);
      },
    );
  }

  Widget _build(BuildContext context, Size size) {
    return StreamBuilder<void>(
      stream: stream, // a Stream<void> or null
      builder: (BuildContext context, _) {
        List<Widget> polylines = <Widget>[];

        for (Polyline polylineOpt in polylineOpts.polylines) {
          polylineOpt.offsets.clear();

          if (polylineOpts.polylineCulling && !polylineOpt.boundingBox.isOverlapping(map!.bounds)) {
            // skip this polyline as it's offscreen
            continue;
          }

          _fillOffsets(polylineOpt.offsets, polylineOpt.points!);

          polylines.add(CustomPaint(
            painter: PolylinePainter(polylineOpt),
            size: size,
          ));
        }

        return Container(
          child: Stack(
            children: polylines,
          ),
        );
      },
    );
  }

  void _fillOffsets(List<Offset> offsets, List<LatLng> points) {
    for (int i = 0, len = points.length; i < len; ++i) {
      LatLng point = points[i];

      CustomPoint<num> pos = map!.project(point);
      pos = pos.multiplyBy(map!.getZoomScale(map!.zoom, map!.zoom)) - map!.getPixelOrigin()!;
      offsets.add(Offset(pos.x.toDouble(), pos.y.toDouble()));
      if (i > 0) {
        offsets.add(Offset(pos.x.toDouble(), pos.y.toDouble()));
      }
    }
  }
}

class PolylinePainter extends CustomPainter {
  final Polyline polylineOpt;

  PolylinePainter(this.polylineOpt);

  @override
  void paint(Canvas canvas, Size size) {
    if (polylineOpt.offsets.isEmpty) {
      return;
    }
    ui.Rect rect = Offset.zero & size;
    canvas.clipRect(rect);
    ui.Paint paint = Paint()
      ..strokeWidth = polylineOpt.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..blendMode = BlendMode.srcOver;

    if (polylineOpt.gradientColors == null) {
      paint.color = polylineOpt.color;
    } else {
      polylineOpt.gradientColors!.isNotEmpty ? paint.shader = _paintGradient() : paint.color = polylineOpt.color;
    }

    ui.Paint filterPaint = Paint()
      ..color = polylineOpt.borderColor.withAlpha(255)
      ..strokeWidth = polylineOpt.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..blendMode = BlendMode.dstOut;

    ui.Paint? borderPaint = polylineOpt.borderStrokeWidth > 0.0
        ? (Paint()
          ..color = polylineOpt.borderColor
          ..strokeWidth = polylineOpt.strokeWidth + polylineOpt.borderStrokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..blendMode = BlendMode.srcOver)
        : null;
    double radius = paint.strokeWidth / 2;
    double borderRadius = (borderPaint?.strokeWidth ?? 0) / 2;
    if (polylineOpt.isDotted) {
      double spacing = polylineOpt.strokeWidth * 1.5;
      canvas.saveLayer(rect, Paint());
      if (borderPaint != null) {
        _paintDottedLine(canvas, polylineOpt.offsets, borderRadius, spacing, borderPaint);
        _paintDottedLine(canvas, polylineOpt.offsets, radius, spacing, filterPaint);
      }
      _paintDottedLine(canvas, polylineOpt.offsets, radius, spacing, paint);
      canvas.restore();
    } else {
      paint.style = PaintingStyle.stroke;
      filterPaint.style = PaintingStyle.stroke;
      borderPaint?.style = PaintingStyle.stroke;
      canvas.saveLayer(rect, Paint());
      if (borderPaint != null) {
        _paintLine(canvas, polylineOpt.offsets, borderPaint);
        _paintLine(canvas, polylineOpt.offsets, filterPaint);
      }
      _paintLine(canvas, polylineOpt.offsets, paint);
      canvas.restore();
    }
  }

  void _paintDottedLine(Canvas canvas, List<Offset> offsets, double radius, double stepLength, Paint paint) {
    ui.Path path = ui.Path();
    double startDistance = 0.0;
    for (int i = 0; i < offsets.length - 1; i++) {
      ui.Offset o0 = offsets[i];
      ui.Offset o1 = offsets[i + 1];
      double totalDistance = _dist(o0, o1);
      double distance = startDistance;
      while (distance < totalDistance) {
        double f1 = distance / totalDistance;
        double f0 = 1.0 - f1;
        ui.Offset offset = Offset(o0.dx * f0 + o1.dx * f1, o0.dy * f0 + o1.dy * f1);
        path.addOval(Rect.fromCircle(center: offset, radius: radius));
        distance += stepLength;
      }
      startDistance = distance < totalDistance ? stepLength - (totalDistance - distance) : distance - totalDistance;
    }
    path.addOval(Rect.fromCircle(center: polylineOpt.offsets.last, radius: radius));
    canvas.drawPath(path, paint);
  }

  void _paintLine(Canvas canvas, List<Offset> offsets, Paint paint) {
    if (offsets.isNotEmpty) {
      ui.Path path = ui.Path()..moveTo(offsets[0].dx, offsets[0].dy);
      for (ui.Offset offset in offsets) {
        path.lineTo(offset.dx, offset.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  ui.Gradient _paintGradient() => ui.Gradient.linear(
      polylineOpt.offsets.first, polylineOpt.offsets.last, polylineOpt.gradientColors!, _getColorsStop());

  List<double>? _getColorsStop() =>
      (polylineOpt.colorsStop != null && polylineOpt.colorsStop!.length == polylineOpt.gradientColors!.length)
          ? polylineOpt.colorsStop
          : _calculateColorsStop();

  List<double> _calculateColorsStop() {
    double colorsStopInterval = 1.0 / polylineOpt.gradientColors!.length;
    return polylineOpt.gradientColors!
        .map((ui.Color gradientColor) => polylineOpt.gradientColors!.indexOf(gradientColor) * colorsStopInterval)
        .toList();
  }

  @override
  bool shouldRepaint(PolylinePainter other) => false;
}

double _dist(Offset v, Offset w) {
  return sqrt(_dist2(v, w));
}

double _dist2(Offset v, Offset w) {
  return _sqr(v.dx - w.dx) + _sqr(v.dy - w.dy);
}

double _sqr(double x) {
  return x * x;
}
