import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/service/location_service.dart';
import 'package:at_location_flutter/show_location.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/layer/marker_layer.dart';
import 'package:at_location_flutter/map_content/flutter_map/src/layer/tile_layer.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/marker_cluster_layer_options.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_cluster/src/marker_cluster_plugin.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_popup/src/popup_controller.dart';
import 'package:at_location_flutter/map_content/flutter_map_marker_popup/src/popup_snap.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'common_components/floating_icon.dart';
import 'common_components/marker_cluster.dart';
import 'common_components/popup.dart';

/// A class defined to show markers based on current location of mentioned atsigns.
// ignore: must_be_immutable
class AtLocationFlutterPlugin extends StatefulWidget {
  /// Atsigns whose location needs to be shown.
  final List<String?>? atsignsToTrack;

  /// Padding for the markers.
  double? left, right, top, bottom;

  /// ETA will be calculated from this co-ordinate.
  LatLng? etaFrom;

  /// [textForCenter] Text for the co-ordinate from where ETA is calculated.
  ///
  /// [focusMapOn] Atsign of user whom to focus on.
  String? textForCenter, focusMapOn;

  /// [calculateETA] if ETA needs to be calculated/displayed.
  /// [addCurrentUserMarker] if logged in users current location should be added to the map.
  bool calculateETA, addCurrentUserMarker;

  AtLocationFlutterPlugin(
    this.atsignsToTrack, {
    this.left,
    this.right,
    this.top,
    this.bottom,
    this.calculateETA = false,
    this.addCurrentUserMarker = false,
    this.textForCenter = 'Centre',
    this.etaFrom,
    this.focusMapOn,
  });
  @override
  _AtLocationFlutterPluginState createState() =>
      _AtLocationFlutterPluginState();
}

class _AtLocationFlutterPluginState extends State<AtLocationFlutterPlugin> {
  PanelController pc = PanelController();
  PopupController _popupController = PopupController();
  MapController? mapController;
  List<LatLng?>? points;
  bool isEventAdmin = false;
  late bool showMarker, mapAdjustedOnce;
  BuildContext? globalContext;

  @override
  void initState() {
    super.initState();
    showMarker = true;
    mapAdjustedOnce = false;
    mapController = MapController();
    LocationService().init(widget.atsignsToTrack,
        etaFrom: widget.etaFrom,
        calculateETA: widget.calculateETA,
        addCurrentUserMarker: widget.addCurrentUserMarker,
        textForCenter: widget.textForCenter,
        showToast: showToast);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      LocationService().mapInitialized();
      LocationService().notifyListeners();
    });
  }

  void showToast(String msg) {
    if (globalContext != null) CustomToast().show(msg, globalContext!);
  }

  @override
  void dispose() {
    LocationService().dispose();
    _popupController.streamController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          StreamBuilder(
              stream: LocationService().atHybridUsersStream,
              builder: (context, AsyncSnapshot<List<HybridModel?>> snapshot) {
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
                    var users = snapshot.data!;
                    var markers = users.map((user) => user!.marker).toList();
                    points = users.map((user) => user!.latLng).toList();
                    print('markers length = ${markers.length}');
                    users.forEach((element) {
                      print('displayanme - ${element!.displayName}');
                    });
                    markers.forEach((element) {
                      print('point - ${element!.point}');
                    });

                    try {
                      if (widget.focusMapOn == null) {
                        if ((markers.isNotEmpty) && (mapController != null)) {
                          mapController!.move(markers[0]!.point, 10);
                        }
                      } else {
                        if ((!mapAdjustedOnce) &&
                            (markers.isNotEmpty) &&
                            (mapController != null)) {
                          var indexOfUser = users.indexWhere((element) =>
                              element!.displayName == widget.focusMapOn);

                          if (indexOfUser > -1) {
                            mapController!
                                .move(markers[indexOfUser]!.point, 10);

                            /// If we want the map to only update once
                            /// And not keep the focus on user sharing his location
                            /// then uncomment
                            //
                            // mapAdjustedOnce = true;
                          } else {
                            /// It moves the focus to logged in user,
                            /// when other user is not sharing location
                            mapController!.move(markers[0]!.point, 10);
                          }
                        }
                      }
                    } catch (e) {
                      print('$e');
                    }

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
                        // ignore: unnecessary_null_comparison
                        center: ((users != null) && (users.isNotEmpty))
                            ? users[0]!.latLng
                            : LatLng(45, 45),
                        zoom: markers.isNotEmpty ? 8 : 2,
                        plugins: [MarkerClusterPlugin(UniqueKey())],
                        onTap: (_) => _popupController
                            .hidePopup(), // Hide popup when the map is tapped.
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
                                        .streamController!.isClosed
                                    ? Text('Closed')
                                    : buildPopup(snapshot
                                        .data![markers.indexOf(marker)]!);
                              }),
                          builder: (context, markers) {
                            return buildMarkerCluster(markers);
                          },
                        ),
                      ],
                    );
                  }
                } else {
                  return showLocation(UniqueKey(), mapController);
                }
              }),
          Positioned(
            top: 100,
            right: 0,
            child: FloatingIcon(icon: Icons.zoom_out_map, onPressed: zoomOutFn),
          ),
        ],
      ),
    ));
  }

  void zoomOutFn() {
    _popupController.hidePopup();
    if (LocationService().hybridUsersList.isNotEmpty) {
      mapController!.move(LocationService().hybridUsersList[0]!.latLng, 4);
    }
    // LocationService().hybridUsersList.isNotEmpty
    //     ? mapController.move(LocationService().hybridUsersList[0].latLng, 4)
    //     : null;
  }
}
