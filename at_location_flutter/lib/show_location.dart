import 'package:at_location_flutter/common_components/build_marker.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:atsign_location/utils/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import 'map_content/flutter_map/flutter_map.dart';
import 'map_content/flutter_map_marker_cluster/src/marker_cluster_layer_options.dart';
import 'map_content/flutter_map_marker_cluster/src/marker_cluster_plugin.dart';

class ShowLocation extends StatefulWidget {
  final LatLng location;
  ShowLocation(this.location);

  @override
  _ShowLocationState createState() => _ShowLocationState();
}

class _ShowLocationState extends State<ShowLocation> {
  final MapController mapController = MapController();
  bool showMarker;
  Marker marker;
  @override
  void initState() {
    super.initState();
    showMarker = true;
    marker = buildMarker(new HybridModel(latLng: widget.location),
        singleMarker: true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: widget.location,
          zoom: 8,
          plugins: [MarkerClusterPlugin(UniqueKey())],
        ),
        layers: [
          TileLayerOptions(
            fnWhenZoomChanges: (zoom) => fnWhenZoomChanges(zoom),
            minNativeZoom: 2,
            maxNativeZoom: 18,
            minZoom: 2,
            urlTemplate:
                "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=${MixedConstants.MAP_KEY}",
          ),
          MarkerClusterLayerOptions(
            maxClusterRadius: 190,
            disableClusteringAtZoom: 16,
            size: Size(5, 5),
            anchor: AnchorPos.align(AnchorAlign.center),
            fitBoundsOptions: FitBoundsOptions(
              padding: EdgeInsets.all(50),
            ),
            markers: showMarker ? [marker] : [],
            builder: (context, markers) {},
          ),
        ],
      )),
    );
  }

  fnWhenZoomChanges(double zoom) {
    if ((zoom > 2) && (!showMarker)) {
      setState(() {
        showMarker = true;
      });
    }
    if ((zoom < 2) && (showMarker)) {
      setState(() {
        showMarker = false;
      });
    }
  }
}
