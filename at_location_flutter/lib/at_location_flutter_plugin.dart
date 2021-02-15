import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/service/location_service.dart';
import 'package:at_location_flutter/show_location.dart';
import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/layer/marker_layer.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/layer/tile_layer.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/marker_cluster_layer_options.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/marker_cluster_Plugin.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_popup/src/popup_controller.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_popup/src/popup_snap.dart';
import 'package:latlong/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'common_components/floating_icon.dart';
import 'common_components/marker_cluster.dart';
import 'common_components/popup.dart';

class AtLocationFlutterPlugin extends StatefulWidget {
  final List<String> atsignsToTrack;
  double left, right, top, bottom;
  AtLocationFlutterPlugin(
    this.atsignsToTrack, {
    this.left,
    this.right,
    this.top,
    this.bottom,
  });
  @override
  _AtLocationFlutterPluginState createState() =>
      _AtLocationFlutterPluginState();
}

class _AtLocationFlutterPluginState extends State<AtLocationFlutterPlugin> {
  final PanelController pc = PanelController();
  PopupController _popupController = PopupController();
  MapController mapController = MapController();
  List<LatLng> points;
  bool isEventAdmin = false;
  bool showMarker;
  // GlobalKey<ScaffoldState> scaffoldKey;

  @override
  void initState() {
    super.initState();
    showMarker = true;
    LocationService().init(widget.atsignsToTrack);
  }

  void dispose() {
    super.dispose();
    LocationService().dispose();
    _popupController?.streamController?.close();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          // key: scaffoldKey,
          body: Stack(
        children: [
          StreamBuilder(
              stream: LocationService().atHybridUsersStream,
              builder: (context, AsyncSnapshot<List<HybridModel>> snapshot) {
                print('snapshot.data ${snapshot.data}');
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'error',
                        style: TextStyle(fontSize: 400),
                      ),
                    );
                  } else {
                    print('FlutterMap called');
                    _popupController = PopupController();
                    List<HybridModel> users = snapshot.data;
                    List<Marker> markers =
                        users.map((user) => user.marker).toList();
                    points = users.map((user) => user.latLng).toList();
                    print('markers length = ${markers.length}');
                    users.forEach((element) {
                      print('displayanme - ${element.displayName}');
                    });
                    markers.forEach((element) {
                      print('point - ${element.point}');
                    });

                    return FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        boundsOptions: FitBoundsOptions(
                            padding: EdgeInsets.fromLTRB(
                          widget.left ?? 20,
                          widget.top ?? 20,
                          widget.right ?? 20,
                          widget.bottom ?? 20,
                        )),
                        center: ((users != null) && (users.length != 0))
                            ? users[0].latLng
                            : LatLng(45, 45),
                        zoom: 8,
                        plugins: [MarkerClusterPlugin(UniqueKey())],
                        onTap: (_) => _popupController
                            .hidePopup(), // Hide popup when the map is tapped.
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
                          size: showMarker
                              ? ((markers.length > 1)
                                  ? Size(200, 150)
                                  : Size(5, 5))
                              : Size(0, 0),
                          anchor: AnchorPos.align(AnchorAlign.center),
                          fitBoundsOptions: FitBoundsOptions(
                            padding: EdgeInsets.all(50),
                          ),
                          markers: showMarker ? markers : [],
                          polygonOptions: PolygonOptions(
                              borderColor: Colors.blueAccent,
                              color: Colors.black12,
                              borderStrokeWidth: 3),
                          popupOptions: PopupOptions(
                              popupSnap: PopupSnap.top,
                              popupController: _popupController,
                              popupBuilder: (_, marker) {
                                return _popupController
                                        .streamController.isClosed
                                    ? Text('Closed')
                                    : buildPopup(
                                        snapshot.data[markers.indexOf(marker)]);
                              }),
                          builder: (context, markers) {
                            return (false)
                                ? buildMarkerCluster(markers,
                                    eventData: LocationService().eventData)
                                : buildMarkerCluster(markers);
                          },
                        ),
                      ],
                    );
                  }
                } else {
                  print('map not active');
                  return ShowLocation(UniqueKey());
                }
              }),
          Positioned(
            top: 100,
            right: 0,
            child: FloatingIcon(
                bgColor: Theme.of(context).accentColor,
                icon: Icons.all_inclusive,
                iconColor: AllColors().Black,
                onPressed: zoomOutFn),
          ),
        ],
      )),
    );
  }

  zoomOutFn() {
    print('zoomOutFn');
    _popupController.hidePopup();
    LocationService().hybridUsersList.length > 0
        ? mapController.move(LocationService().hybridUsersList[0].latLng, 4)
        : null;
  }

  fnWhenZoomChanges(double zoom) {
    print('fnWhenZoomChanges $zoom');
    if ((zoom > 2) && (!showMarker)) {
      print('greater $zoom');
      setState(() {
        showMarker = true;
      });
    }
    if ((zoom < 2) && (showMarker)) {
      print('less $zoom');
      setState(() {
        showMarker = false;
      });
    }
  }
}
