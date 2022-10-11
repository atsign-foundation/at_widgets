// ignore_for_file: prefer_void_to_null

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/map/map.dart';

class OverlayImageLayerOptions extends LayerOptions {
  final List<OverlayImage> overlayImages;

  OverlayImageLayerOptions({
    Key? key,
    this.overlayImages = const [],
    rebuild,
  }) : super(key: key, rebuild: rebuild);
}

class OverlayImage {
  final LatLngBounds? bounds;
  final ImageProvider? imageProvider;
  final double opacity;
  final bool gaplessPlayback;

  OverlayImage({
    this.bounds,
    this.imageProvider,
    this.opacity = 1.0,
    this.gaplessPlayback = false,
  });
}

class OverlayImageLayerWidget extends StatelessWidget {
  final OverlayImageLayerOptions options;

  OverlayImageLayerWidget({required this.options}) : super(key: options.key);

  @override
  Widget build(BuildContext context) {
    final mapState = MapState.of(context)!;
    return OverlayImageLayer(options, mapState, mapState.onMoved);
  }
}

class OverlayImageLayer extends StatelessWidget {
  final OverlayImageLayerOptions overlayImageOpts;
  final MapState? map;
  final Stream<Null>? stream;

  OverlayImageLayer(this.overlayImageOpts, this.map, this.stream)
      : super(key: overlayImageOpts.key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: stream,
      builder: (BuildContext context, _) {
        return ClipRect(
          child: Stack(
            children: <Widget>[
              for (var overlayImage in overlayImageOpts.overlayImages)
                _positionedForOverlay(overlayImage),
            ],
          ),
        );
      },
    );
  }

  Positioned _positionedForOverlay(OverlayImage overlayImage) {
    final zoomScale = map!.getZoomScale(map!.zoom, map!.zoom);
    final pixelOrigin = map!.getPixelOrigin()!;
    final upperLeftPixel =
        map!.project(overlayImage.bounds!.northWest).multiplyBy(zoomScale) -
            pixelOrigin;
    final bottomRightPixel =
        map!.project(overlayImage.bounds!.southEast).multiplyBy(zoomScale) -
            pixelOrigin;
    return Positioned(
      left: upperLeftPixel.x.toDouble(),
      top: upperLeftPixel.y.toDouble(),
      width: (bottomRightPixel.x - upperLeftPixel.x).toDouble(),
      height: (bottomRightPixel.y - upperLeftPixel.y).toDouble(),
      child: Image(
        image: overlayImage.imageProvider!,
        fit: BoxFit.fill,
        color: Color.fromRGBO(255, 255, 255, overlayImage.opacity),
        colorBlendMode: BlendMode.modulate,
        gaplessPlayback: overlayImage.gaplessPlayback,
      ),
    );
  }
}
