// ignore_for_file: prefer_void_to_null, prefer_const_constructors, avoid_unnecessary_containers, avoid_renaming_method_parameters
import 'package:flutter/widgets.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/map/map.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart' hide Path; // conflict with Path from UI

class CircleLayerOptions extends LayerOptions {
  final List<CircleMarker> circles;
  CircleLayerOptions({
    Key? key,
    this.circles = const [],
    rebuild,
  }) : super(key: key, rebuild: rebuild);
}

class CircleMarker {
  final LatLng? point;
  final double? radius;
  final Color color;
  final double borderStrokeWidth;
  final Color borderColor;
  final bool useRadiusInMeter;
  Offset offset = Offset.zero;
  num realRadius = 0;
  CircleMarker({
    this.point,
    this.radius,
    this.useRadiusInMeter = false,
    this.color = const Color(0xFF00FF00),
    this.borderStrokeWidth = 0.0,
    this.borderColor = const Color(0xFFFFFF00),
  });
}

class CircleLayerWidget extends StatelessWidget {
  final CircleLayerOptions options;

  CircleLayerWidget({required this.options}) : super(key: options.key);

  @override
  Widget build(BuildContext context) {
    final mapState = MapState.of(context)!;
    return CircleLayer(options, mapState, mapState.onMoved);
  }
}

class CircleLayer extends StatelessWidget {
  final CircleLayerOptions circleOpts;
  final MapState? map;
  final Stream<Null>? stream;
  CircleLayer(this.circleOpts, this.map, this.stream)
      : super(key: circleOpts.key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints bc) {
        final size = Size(bc.maxWidth, bc.maxHeight);
        return _build(context, size);
      },
    );
  }

  Widget _build(BuildContext context, Size size) {
    return StreamBuilder<void>(
      stream: stream, // a Stream<void> or null
      builder: (BuildContext context, _) {
        var circleWidgets = <Widget>[];
        for (var circle in circleOpts.circles) {
          var pos = map!.project(circle.point);
          pos = pos.multiplyBy(map!.getZoomScale(map!.zoom, map!.zoom)) -
              map!.getPixelOrigin()!;
          circle.offset = Offset(pos.x.toDouble(), pos.y.toDouble());

          if (circle.useRadiusInMeter) {
            var r = Distance().offset(circle.point!, circle.radius!, 180);
            var rpos = map!.project(r);
            rpos = rpos.multiplyBy(map!.getZoomScale(map!.zoom, map!.zoom)) -
                map!.getPixelOrigin()!;

            circle.realRadius = rpos.y - pos.y;
          }

          circleWidgets.add(
            CustomPaint(
              painter: CirclePainter(circle),
              size: size,
            ),
          );
        }

        return Container(
          child: Stack(
            children: circleWidgets,
          ),
        );
      },
    );
  }
}

class CirclePainter extends CustomPainter {
  final CircleMarker circle;
  CirclePainter(this.circle);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = circle.color;

    _paintCircle(
        canvas,
        circle.offset,
        circle.useRadiusInMeter ? circle.realRadius as double : circle.radius!,
        paint);

    if (circle.borderStrokeWidth > 0) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = circle.borderColor
        ..strokeWidth = circle.borderStrokeWidth;

      _paintCircle(
          canvas,
          circle.offset,
          circle.useRadiusInMeter
              ? circle.realRadius as double
              : circle.radius!,
          paint);
    }
  }

  void _paintCircle(Canvas canvas, Offset offset, double radius, Paint paint) {
    canvas.drawCircle(offset, radius, paint);
  }

  @override
  bool shouldRepaint(CirclePainter other) => false;
}
