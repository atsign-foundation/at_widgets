import 'package:flutter/widgets.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/core/point.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/layer/marker_layer.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/map/map.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_popup/src/popup_container.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_popup/src/popup_snap.dart';

class PopupPosition {
  static PopupContainer container(
    MapState mapState,
    Marker marker,
    PopupSnap snap,
  ) {
    CustomPoint<num> markerPosition = _markerPosition(mapState, marker);

    return _containerFor(
      mapState.size,
      markerPosition,
      CustomPoint<num>(marker.width, marker.height),
      snap,
    );
  }

  static PopupContainer _containerFor(
      CustomPoint<num>? visibleSize, CustomPoint<num> markerPosition, CustomPoint<num> markerSize, PopupSnap snap) {
    // Note: We always add the popup even if it might not be visible. This
    //       ensures the popup state is maintained even when it is not visible.
    switch (snap) {
      case PopupSnap.left:
        return _snapLeft(visibleSize!, markerPosition, markerSize);
      case PopupSnap.top:
        return _snapTop(visibleSize!, markerPosition, markerSize);
      case PopupSnap.right:
        return _snapRight(visibleSize!, markerPosition, markerSize);
      case PopupSnap.bottom:
        return _snapBottom(visibleSize!, markerPosition, markerSize);
      case PopupSnap.center:
        return _snapCenter(visibleSize!, markerPosition, markerSize);
      default:
        return _snapTop(visibleSize!, markerPosition, markerSize);
    }
  }

  static PopupContainer _snapLeft(
      CustomPoint<num> visibleSize, CustomPoint<num> markerPosition, CustomPoint<num> markerSize) {
    return PopupContainer(
      size: visibleSize,
      right: visibleSize.x - (markerPosition.x.toDouble()),
      top: markerPosition.y - (visibleSize.y / 2) + (markerSize.y / 2),
      alignment: Alignment.centerRight,
    );
  }

  static PopupContainer _snapTop(
      CustomPoint<num> visibleSize, CustomPoint<num> markerPosition, CustomPoint<num> markerSize) {
    return PopupContainer(
      size: visibleSize,
      alignment: Alignment.bottomCenter,
      left: markerPosition.x - (visibleSize.x / 2) + (markerSize.x / 2),
      bottom: visibleSize.y - markerPosition.y.toDouble(),
    );
  }

  static PopupContainer _snapRight(
      CustomPoint<num> visibleSize, CustomPoint<num> markerPosition, CustomPoint<num> markerSize) {
    return PopupContainer(
      size: visibleSize,
      alignment: Alignment.centerLeft,
      left: markerPosition.x + (markerSize.x.toDouble()),
      top: markerPosition.y - (visibleSize.y / 2) + (markerSize.y / 2),
    );
  }

  static PopupContainer _snapBottom(
      CustomPoint<num> visibleSize, CustomPoint<num> markerPosition, CustomPoint<num> markerSize) {
    return PopupContainer(
      size: visibleSize,
      alignment: Alignment.topCenter,
      left: markerPosition.x - (visibleSize.x / 2) + (markerSize.x / 2),
      top: markerPosition.y + (markerSize.y.toDouble()),
    );
  }

  static PopupContainer _snapCenter(
      CustomPoint<num> visibleSize, CustomPoint<num> markerPosition, CustomPoint<num> markerSize) {
    return PopupContainer(
      size: visibleSize,
      alignment: Alignment.center,
      left: markerPosition.x - (visibleSize.x / 2) + (markerSize.x / 2),
      top: markerPosition.y - (visibleSize.y / 2) + (markerSize.y / 2),
    );
  }

  static CustomPoint<num> _markerPosition(MapState mapState, Marker marker) {
    CustomPoint<num> pos = mapState.project(marker.point);
    pos = pos.multiplyBy(mapState.getZoomScale(mapState.zoom, mapState.zoom)) - mapState.getPixelOrigin()!;

    return CustomPoint<num>((pos.x - (marker.width - marker.anchor.left)).toDouble(),
        (pos.y - (marker.height - marker.anchor.top)).toDouble());
  }
}
