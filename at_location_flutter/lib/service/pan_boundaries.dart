import 'dart:math';

import 'package:latlong/latlong.dart';

LatLng calculateSWPanBoundary(List<LatLng> points) {
  List<double> latitudes = points.map((point) => point.latitude).toList();
  List<double> longitudes = points.map((point) => point.longitude).toList();
  // return LatLng(latitudes.reduce(min) - 1, longitudes.reduce(min) - 1);
  return LatLng(-90, -180);
}

LatLng calculateNEPanBoundary(List<LatLng> points) {
  List<double> latitudes = points.map((point) => point.latitude).toList();
  List<double> longitudes = points.map((point) => point.longitude).toList();
  // return LatLng(latitudes.reduce(max) + 1, longitudes.reduce(max) + 1);
  return LatLng(90, 180);
}
