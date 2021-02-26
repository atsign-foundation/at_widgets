import 'package:at_location_flutter/common_components/pointed_bottom.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/layer/marker_layer.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:flutter/material.dart';

import 'circle_marker_painter.dart';

Widget buildMarkerCluster(List<Marker> markers, {HybridModel eventData}) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Positioned(
          top: 0,
          child: Container(
            height: markers.contains(eventData?.marker) ? 50 : 30,
            width: 200,
            alignment: Alignment.center,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(3)),
                boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10)]),
            child: markers.contains(eventData?.marker)
                ? Column(
                    children: [
                      Flexible(
                        child: Text(
                          eventData.displayName ?? 'Tina\'s Birthday Party',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "${markers.length - 1} people nearby",
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ],
                  )
                : Text(
                    "${markers.length} people nearby",
                    style: TextStyle(color: Colors.deepOrange),
                  ),
          )),
      Positioned(
          top: markers.contains(eventData?.marker) ? 47 : 27,
          child: pointedBottom()),
      Positioned(
        top: 55,
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          child: markers.contains(eventData?.marker)
              ? Icon(Icons.flag)
              : SizedBox(),
        ),
      ),
      Positioned(
        top: 50,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Opacity(
            opacity: 0.6,
            child: CustomPaint(
              painter: CircleMarkerPainter(),
            ),
          ),
        ),
      ),
    ],
  );
}
