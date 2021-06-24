import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/marker_cluster_layer_options.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'common_components/build_marker.dart';
import 'common_components/marker_cluster.dart';
import 'location_modal/hybrid_model.dart';
import 'map_content/flutter_map/flutter_map.dart';
import 'map_content/flutter_map_marker_cluster/src/marker_cluster_plugin.dart';
import 'utils/constants/constants.dart';

/// A class defined to show only one or no or a list of co-ordinates with custom marker.
// ignore: must_be_immutable
class ShowLocation extends StatefulWidget {
  @override
  Key key;

  /// Co-ordinate on which marker needs to be shown.
  final LatLng location;

  /// List of Co-ordinates on which markers needs to be shown.
  final List<LatLng> locationList;

  /// Custom widget displayed as the marker.
  Widget locationListMarker;
  ShowLocation(this.key,
      {this.location, this.locationList, this.locationListMarker});

  @override
  _ShowLocationState createState() => _ShowLocationState();
}

class _ShowLocationState extends State<ShowLocation> {
  final MapController mapController = MapController();
  bool showMarker, noPointReceived;
  Marker marker;
  List<Marker> markerList;
  @override
  void initState() {
    super.initState();
    showMarker = true;
    noPointReceived = false;
    print('widget.location ${widget.location}');
    if (widget.location != null) {
      marker =
          buildMarker(HybridModel(latLng: widget.location), singleMarker: true);
    } else {
      noPointReceived = true;
      marker =
          buildMarker(HybridModel(latLng: LatLng(45, 45)), singleMarker: true);
      showMarker = false;
    }

    if (widget.locationList != null) {
      markerList = [];
      widget.locationList.forEach((location) {
        var marker = buildMarker(HybridModel(latLng: location),
            singleMarker: true, marker: widget.locationListMarker);
        markerList.add(marker);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: markerList != null
              ? markerList[0].point
              : (widget.location != null)
                  ? widget.location
                  : LatLng(45, 45),
          zoom: markerList != null
              ? 5
              : (widget.location != null)
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
}
