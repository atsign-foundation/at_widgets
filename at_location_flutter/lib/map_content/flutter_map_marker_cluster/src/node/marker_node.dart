import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/node/marker_cluster_node.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

class MarkerNode implements Marker {
  final Marker marker;
  MarkerClusterNode parent;

  MarkerNode(this.marker);

  @override
  Anchor get anchor => marker.anchor;

  @override
  WidgetBuilder get builder => marker.builder;

  @override
  double get height => marker.height;

  @override
  LatLng get point => marker.point;

  @override
  double get width => marker.width;
}
