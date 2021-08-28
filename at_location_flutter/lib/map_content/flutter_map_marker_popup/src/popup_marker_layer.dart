import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/core/bounds.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/core/point.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/layer/marker_layer.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/map/map.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_popup/src/marker_popup.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_popup/src/popup_marker_layer_options.dart';

class PopupMarkerLayer extends StatelessWidget {
  /// For normal layer behaviour
  final PopupMarkerLayerOptions layerOpts;
  final MapState? map;
  final Stream<dynamic> stream;

  PopupMarkerLayer(this.layerOpts, this.map, this.stream);

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
      stream: stream as Stream<int>,
      builder: (BuildContext _, AsyncSnapshot<int?> __) {
        List<Widget> markers = <Widget>[];

        for (Marker markerOpt in layerOpts.markers) {
          CustomPoint<num> pos = map!.project(markerOpt.point);
          pos = pos.multiplyBy(map!.getZoomScale(map!.zoom, map!.zoom)) -
              map!.getPixelOrigin()!;

          double pixelPosX =
              (pos.x - (markerOpt.width - markerOpt.anchor.left)).toDouble();
          double pixelPosY =
              (pos.y - (markerOpt.height - markerOpt.anchor.top)).toDouble();

          if (!_boundsContainsMarker(markerOpt)) {
            continue;
          }

          CustomPoint<num> bottomPos = map!.pixelBounds!.max;
          bottomPos =
              bottomPos.multiplyBy(map!.getZoomScale(map!.zoom, map!.zoom)) -
                  map!.getPixelOrigin()!;

          markers.add(
            Positioned(
              width: markerOpt.width,
              height: markerOpt.height,
              left: pixelPosX,
              top: pixelPosY,
              child: GestureDetector(
                onTap: () => layerOpts.popupController.togglePopup(markerOpt),
                child: markerOpt.builder(context),
              ),
            ),
          );
        }

        markers.add(
          MarkerPopup(
            mapState: map,
            popupController: layerOpts.popupController,
            snap: layerOpts.popupSnap,
            popupBuilder: layerOpts.popupBuilder,
          ),
        );

        return Container(
          child: Stack(
            children: markers,
          ),
        );
      },
    );
  }
}
