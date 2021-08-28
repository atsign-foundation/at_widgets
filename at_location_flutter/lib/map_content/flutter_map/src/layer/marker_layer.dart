import 'package:flutter/widgets.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/core/bounds.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/map/map.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';

class MarkerLayerOptions extends LayerOptions {
  final List<Marker> markers;
  MarkerLayerOptions({
    Key? key,
    this.markers = const <Marker>[],
    dynamic rebuild,
  }) : super(key: key, rebuild: rebuild);
}

class Anchor {
  final double left;
  final double top;

  Anchor(this.left, this.top);

  Anchor._(double width, double height, AnchorAlign? alignOpt)
      : left = _leftOffset(width, alignOpt),
        top = _topOffset(height, alignOpt);

  static double _leftOffset(double width, AnchorAlign? alignOpt) {
    switch (alignOpt) {
      case AnchorAlign.left:
        return 0.0;
      case AnchorAlign.right:
        return width;
      case AnchorAlign.top:
      case AnchorAlign.bottom:
      case AnchorAlign.center:
      default:
        return width / 2;
    }
  }

  static double _topOffset(double height, AnchorAlign? alignOpt) {
    switch (alignOpt) {
      case AnchorAlign.top:
        return 0.0;
      case AnchorAlign.bottom:
        return height;
      case AnchorAlign.left:
      case AnchorAlign.right:
      case AnchorAlign.center:
      default:
        return height / 2;
    }
  }

  factory Anchor.forPos(AnchorPos<dynamic>? pos, double width, double height) {
    if (pos == null) return Anchor._(width, height, null);
    if (pos.value is AnchorAlign) return Anchor._(width, height, pos.value);
    if (pos.value is Anchor) return pos.value;
    throw Exception('Unsupported AnchorPos value type: ${pos.runtimeType}.');
  }
}

class AnchorPos<T> {
  AnchorPos._(this.value);
  T value;
  static AnchorPos<dynamic> exactly(Anchor anchor) => AnchorPos<dynamic>._(anchor);
  static AnchorPos<dynamic> align(AnchorAlign alignOpt) => AnchorPos<dynamic>._(alignOpt);
}

enum AnchorAlign {
  left,
  right,
  top,
  bottom,
  center,
}

class Marker {
  final LatLng point;
  final WidgetBuilder builder;
  final double width;
  final double height;
  final Anchor anchor;

  Marker({
    required this.point,
    required this.builder,
    this.width = 30.0,
    this.height = 30.0,
    AnchorPos<dynamic>? anchorPos,
  }) : anchor = Anchor.forPos(anchorPos, width, height);
}

class MarkerLayerWidget extends StatelessWidget {
  final MarkerLayerOptions options;

  MarkerLayerWidget({required this.options}) : super(key: options.key);

  @override
  Widget build(BuildContext context) {
    MapState mapState = MapState.of(context)!;
    return MarkerLayer(options, mapState, mapState.onMoved);
  }
}

class MarkerLayer extends StatelessWidget {
  final MarkerLayerOptions markerOpts;
  final MapState? map;
  final Stream<void>? stream;

  MarkerLayer(this.markerOpts, this.map, this.stream) : super(key: markerOpts.key);

  bool _boundsContainsMarker(Marker marker) {
    CustomPoint<num> pixelPoint = map!.project(marker.point);

    double width = marker.width - marker.anchor.left;
    double height = marker.height - marker.anchor.top;

    CustomPoint<num> sw = CustomPoint<num>(pixelPoint.x + width, pixelPoint.y - height);
    CustomPoint<num> ne = CustomPoint<num>(pixelPoint.x - width, pixelPoint.y + height);
    return map!.pixelBounds!.containsPartialBounds(Bounds<num>(sw, ne));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: stream as Stream<int?>?,
      builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
        List<Widget> markers = <Widget>[];
        for (Marker markerOpt in markerOpts.markers) {
          CustomPoint<num> pos = map!.project(markerOpt.point);
          pos = pos.multiplyBy(map!.getZoomScale(map!.zoom, map!.zoom)) - map!.getPixelOrigin()!;

          double pixelPosX = (pos.x - (markerOpt.width - markerOpt.anchor.left)).toDouble();
          double pixelPosY = (pos.y - (markerOpt.height - markerOpt.anchor.top)).toDouble();

          if (!_boundsContainsMarker(markerOpt)) {
            continue;
          }

          markers.add(
            Positioned(
              width: markerOpt.width,
              height: markerOpt.height,
              left: pixelPosX,
              top: pixelPosY,
              child: markerOpt.builder(context),
            ),
          );
        }
        return Container(
          child: Stack(
            children: markers,
          ),
        );
      },
    );
  }
}
