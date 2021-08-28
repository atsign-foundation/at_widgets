import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/marker_cluster_layer_options.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';
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
Widget showLocation(Key? key, MapController? mapController,
    {LatLng? location, List<LatLng>? locationList, Widget? locationListMarker}) {
  bool showMarker;
  Marker marker;
  List<Marker>? markerList;

  /// init
  showMarker = true;
  print('widget.location $location');
  if (location != null) {
    marker = buildMarker(HybridModel(latLng: location), singleMarker: true);
    if (mapController != null) {
      mapController.move(location, 8);
    }
  } else {
    marker = buildMarker(HybridModel(latLng: LatLng(45, 45)), singleMarker: true);
    showMarker = false;
  }

  if (locationList != null) {
    markerList = <Marker>[];
    for (LatLng location in locationList) {
      Marker marker = buildMarker(HybridModel(latLng: location), singleMarker: true, marker: locationListMarker);
      markerList.add(marker);
    }
  }

  ///

  return SafeArea(
    child: Scaffold(
        body: FlutterMap(
      key: key,
      mapController: mapController ?? MapController(),
      options: MapOptions(
        center: markerList != null
            ? markerList[0].point
            : (location != null)
                ? location
                : LatLng(45, 45),
        zoom: markerList != null
            ? 5
            : (location != null)
                ? 15
                : 4,
        plugins: <MapPlugin>[MarkerClusterPlugin(UniqueKey())],
      ),
      layers: <LayerOptions>[
        TileLayerOptions(
          minNativeZoom: 2,
          maxNativeZoom: 18,
          minZoom: 1,
          urlTemplate: 'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=${MixedConstants.MAP_KEY}',
        ),
        MarkerClusterLayerOptions(
          maxClusterRadius: 190,
          disableClusteringAtZoom: 16,
          size: const Size(5, 5),
          anchor: AnchorPos.align(AnchorAlign.center),
          fitBoundsOptions: const FitBoundsOptions(
            padding: EdgeInsets.all(50),
          ),
          markers: markerList ?? (showMarker ? <Marker?>[marker] : <Marker?>[]),
          builder: (BuildContext context, List<Marker?> markers) {
            return buildMarkerCluster(markers);
          },
        ),
      ],
    )),
  );
}
