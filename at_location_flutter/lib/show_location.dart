import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/marker_cluster_layer_options.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'common_components/build_marker.dart';
import 'common_components/marker_cluster.dart';
import 'location_modal/hybrid_model.dart';
import 'map_content/flutter_map/flutter_map.dart';
import 'map_content/flutter_map_marker_cluster/src/marker_cluster_plugin.dart';
import 'utils/constants/constants.dart';

/// A widget defined to show zero or one or a list of geo co-ordinates with custom marker.
///
/// [location] Co-ordinate on which marker needs to be shown.
///
/// [locationList] List of Co-ordinates on which markers needs to be shown.
///
/// [locationListMarker] Custom widget displayed as the marker.
Widget showLocation(Key key,
    {LatLng location, List<LatLng> locationList, Widget locationListMarker}) {
  final mapController = MapController();
  bool showMarker;
  Marker marker;
  List<Marker> markerList;

  /// init
  showMarker = true;
  print('widget.location $location');
  if (location != null) {
    marker = buildMarker(HybridModel(latLng: location), singleMarker: true);
  } else {
    marker =
        buildMarker(HybridModel(latLng: LatLng(45, 45)), singleMarker: true);
    showMarker = false;
  }

  if (locationList != null) {
    markerList = [];
    locationList.forEach((location) {
      var marker = buildMarker(HybridModel(latLng: location),
          singleMarker: true, marker: locationListMarker);
      markerList.add(marker);
    });
  }

  ///

  return SafeArea(
    child: Scaffold(
        body: FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: markerList != null
            ? markerList[0].point
            : (location != null)
                ? location
                : LatLng(45, 45),
        zoom: markerList != null
            ? 5
            : (location != null)
                ? 8
                : 2,
        plugins: [MarkerClusterPlugin(UniqueKey())],
      ),
      layers: [
        TileLayerOptions(
          minNativeZoom: 2,
          maxNativeZoom: 18,
          minZoom: 1,
          urlTemplate:
              'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=${MixedConstants.MAP_KEY}',
        ),
        MarkerClusterLayerOptions(
          maxClusterRadius: 190,
          disableClusteringAtZoom: 16,
          size: Size(5, 5),
          anchor: AnchorPos.align(AnchorAlign.center),
          fitBoundsOptions: FitBoundsOptions(
            padding: EdgeInsets.all(50),
          ),
          markers:
              // ignore: prefer_if_null_operators
              markerList != null ? markerList : (showMarker ? [marker] : []),
          builder: (context, markers) {
            return buildMarkerCluster(markers);
          },
        ),
      ],
    )),
  );
}
