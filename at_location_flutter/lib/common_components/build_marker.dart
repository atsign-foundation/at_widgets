import 'package:at_location_flutter/map_content/flutter_map/src/layer/marker_layer.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:flutter/material.dart';

import 'circle_marker_painter.dart';
import 'contacts_initial.dart';
import 'custom_circle_avatar.dart';
import 'pointed_bottom.dart';

Marker buildMarker(HybridModel user, {bool singleMarker = false}) {
  return Marker(
    anchorPos: AnchorPos.align(AnchorAlign.center),
    height: 50,
    width: 50,
    point: user.latLng,
    builder: (ctx) => singleMarker
        ? Icon(
            Icons.location_on,
            size: 60,
            color: AllColors().ORANGE,
          )
        : Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                child: user.image != null
                    ? CustomCircleAvatar(
                        byteImage: user.image, nonAsset: true, size: 30)
                    : ContactInitial(
                        initials: user.displayName.substring(1, 3),
                        size: 60,
                      ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: CustomPaint(
                  painter: CircleMarkerPainter(),
                ),
              ),
              Positioned(top: 50, child: pointedBottom(color: Colors.black)),
            ],
          ),
  );
}
