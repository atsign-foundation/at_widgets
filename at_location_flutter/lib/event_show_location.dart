import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';

import 'common_components/floating_icon.dart';
import 'common_components/marker_cluster.dart';
import 'common_components/popup.dart';
import 'location_modal/hybrid_model.dart';
import 'map_content/flutter_map/flutter_map.dart';
import 'map_content/flutter_map_marker_cluster/src/marker_cluster_layer_options.dart';
import 'map_content/flutter_map_marker_cluster/src/marker_cluster_plugin.dart';
import 'map_content/flutter_map_marker_popup/src/popup_controller.dart';
import 'map_content/flutter_map_marker_popup/src/popup_snap.dart';
import 'utils/constants/constants.dart';

Widget eventShowLocation(List<HybridModel> users, LatLng venue) {
  print('FlutterMap called');
  var _popupController = PopupController();
  var mapController = MapController();
  var markers = users.map((user) => user.marker).toList();
  print('markers length = ${markers.length}');
  users.forEach((element) {
    print('displayanme - ${element.displayName}');
  });
  markers.forEach((element) {
    print('point - ${element!.point}');
  });

  var _eventData = users[users.indexWhere((e) => e.latLng == venue)];

  return Stack(
    children: [
      FlutterMap(
        key: UniqueKey(),
        mapController: mapController,
        options: MapOptions(
          center: venue,
          zoom: markers.isNotEmpty ? 8 : 2,
          plugins: [MarkerClusterPlugin(UniqueKey())],
          onTap: (_) => _popupController.hidePopup(),
        ),
        layers: [
          TileLayerOptions(
            minNativeZoom: 2,
            maxNativeZoom: 18,
            minZoom: 2,
            urlTemplate:
                'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=${MixedConstants.MAP_KEY}',
          ),
          MarkerClusterLayerOptions(
            maxClusterRadius: 190,
            disableClusteringAtZoom: 16,
            size: Size(200, 150),
            anchor: AnchorPos.align(AnchorAlign.center),
            fitBoundsOptions: FitBoundsOptions(
              padding: EdgeInsets.all(50),
            ),
            markers: markers,
            polygonOptions: PolygonOptions(
                borderColor: Colors.blueAccent,
                color: Colors.black12,
                borderStrokeWidth: 3),
            popupOptions: PopupOptions(
                popupSnap: PopupSnap.top,
                popupController: _popupController,
                popupBuilder: (_, marker) {
                  return _popupController.streamController!.isClosed
                      ? Text('Closed')
                      : buildPopup(users[markers.indexOf(marker)],
                          center: venue);
                }),
            builder: (context, markers) {
              return buildMarkerCluster(markers, eventData: _eventData);
            },
          ),
        ],
      ),
      Positioned(
        top: 100,
        right: 0,
        child: FloatingIcon(
            icon: Icons.zoom_out_map,
            onPressed: () {
              _popupController.hidePopup();
              mapController.move(venue, 4);
            }),
      ),
    ],
  );
}
