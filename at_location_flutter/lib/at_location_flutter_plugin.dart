import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_chat_flutter/screens/chat_screen.dart';
import 'package:at_chat_flutter/utils/init_chat_service.dart';
import 'package:at_events_flutter/common_components/bottom_sheet.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/location_service.dart';
import 'package:at_location_flutter/service/pan_boundaries.dart';
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
import 'package:location/location.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'common_components/collapsed_content.dart';
import 'common_components/floating_icon.dart';
import 'common_components/marker_cluster.dart';
import 'common_components/popup.dart';

class AtLocationFlutterPlugin extends StatefulWidget {
  List<LatLng> positions;
  LocationNotificationModel userListenerKeyword;
  EventNotificationModel eventListenerKeyword;
  final AtClientImpl atClientInstance;
  double left, right, top, bottom;
  final ValueChanged<EventNotificationModel> onEventUpdate;
  final Function onEventCancel, onEventExit, onShareToggle, onRemove, onRequest;
  List<HybridModel> allUsersList;

  AtLocationFlutterPlugin(this.atClientInstance,
      {@required this.allUsersList,
      this.onEventCancel,
      this.onEventExit,
      this.userListenerKeyword,
      this.eventListenerKeyword,
      this.left,
      this.right,
      this.top,
      this.bottom,
      this.onEventUpdate,
      this.onRemove,
      this.onRequest,
      this.onShareToggle});
  @override
  _AtLocationFlutterPluginState createState() =>
      _AtLocationFlutterPluginState();
}
//

class _AtLocationFlutterPluginState extends State<AtLocationFlutterPlugin> {
  final PanelController pc = PanelController();
  PopupController _popupController = PopupController();
  MapController mapController = MapController();
  List<LatLng> points;
  bool isEventAdmin = false;
  bool showMarker;
  GlobalKey<ScaffoldState> scaffoldKey;

  @override
  void initState() {
    super.initState();
    showMarker = true;
    print('widget.onRemove ${widget.onRemove}');
    LocationService().init(widget.atClientInstance, widget.allUsersList,
        newUserListenerKeyword: widget.userListenerKeyword ?? null,
        newEventListenerKeyword: widget.eventListenerKeyword ?? null,
        eventCancel: widget.onEventCancel != null ? widget.onEventCancel : null,
        eventExit: widget.onEventExit ?? null,
        newOnRemove: widget.onRemove,
        newOnRequest: widget.onRequest,
        newOnShareToggle: widget.onShareToggle);

    if (widget.eventListenerKeyword != null) {
      if (widget.atClientInstance.currentAtSign ==
          widget.eventListenerKeyword.atsignCreator) {
        isEventAdmin = true;
      }
    }

    if (widget.onEventUpdate != null) {
      LocationService().onEventUpdate = widget.onEventUpdate;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.eventListenerKeyword != null) {
        LocationService().eventSink.add(widget.eventListenerKeyword);
      }
    });

    scaffoldKey = GlobalKey<ScaffoldState>();

    getAtSignAndInitializeChat();
    setAtsignToChatWith();
  }

  void dispose() {
    super.dispose();
    LocationService().dispose();
    _popupController.streamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          body: Stack(
            children: [
              StreamBuilder(
                  stream: LocationService().atHybridUsersStream,
                  builder:
                      (context, AsyncSnapshot<List<HybridModel>> snapshot) {
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
                        // LatLng nePanBoundary = calculateNEPanBoundary(points);
                        // LatLng swPanBoundary = calculateSWPanBoundary(points);
                        // print('nePanBoundary $nePanBoundary');
                        // print('swPanBoundary $swPanBoundary');
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
                            // swPanBoundary: swPanBoundary,
                            // nePanBoundary: nePanBoundary,
                            boundsOptions: FitBoundsOptions(
                                padding: EdgeInsets.fromLTRB(
                              widget.left ?? 20,
                              widget.top ?? 20,
                              widget.right ?? 20,
                              widget.bottom ?? 20,
                            )),
                            // bounds: LatLngBounds.fromPoints(points),
                            center: widget.eventListenerKeyword != null
                                ? LocationService().eventData.latLng
                                : LocationService().myData.latLng,
                            zoom: 8,
                            plugins: [MarkerClusterPlugin(UniqueKey())],
                            onTap: (_) => _popupController
                                .hidePopup(), // Hide popup when the map is tapped.
                          ),
                          layers: [
                            TileLayerOptions(
                              fnWhenZoomChanges: (zoom) =>
                                  fnWhenZoomChanges(zoom),
                              minNativeZoom: 2,
                              maxNativeZoom: 18,
                              minZoom: 2,
                              urlTemplate:
                                  //"https://api.maptiler.com/maps/streets/static/37,-112,2/300x400"".png?key=B3Wus46C2WZFhwZKQkEx"
                                  "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=B3Wus46C2WZFhwZKQkEx",
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
                                    // mapController.move(marker.point, 10);
                                    return _popupController
                                            .streamController.isClosed
                                        ? Text('Closed')
                                        : buildPopup(snapshot
                                            .data[markers.indexOf(marker)]);
                                  }),
                              builder: (context, markers) {
                                // return Text('marker');
                                return widget.eventListenerKeyword != null
                                    ? buildMarkerCluster(markers,
                                        eventData: LocationService().eventData)
                                    : buildMarkerCluster(markers);
                              },
                            ),
                          ],
                        );
                      }
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
              Positioned(
                top: 0,
                left: 0,
                child: FloatingIcon(
                  bgColor: Theme.of(context).scaffoldBackgroundColor,
                  icon: Icons.arrow_back,
                  iconColor: Theme.of(context).primaryColor,
                  isTopLeft: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: FloatingIcon(
                    bgColor: Theme.of(context).primaryColor,
                    icon: Icons.message_outlined,
                    iconColor: Theme.of(context).scaffoldBackgroundColor,
                    onPressed: () =>
                        // bottomSheet(context, ChatScreen(), 743),
                        scaffoldKey.currentState
                            .showBottomSheet((context) => ChatScreen())),
              ),
              Positioned(
                top: 100,
                right: 0,
                child: FloatingIcon(
                    bgColor: Theme.of(context).accentColor,
                    icon: Icons.all_inclusive,
                    iconColor: AllColors().Black,
                    onPressed: () {
                      _popupController.hidePopup();
                      LocationService().hybridUsersList.length > 0
                          ? mapController.move(
                              LocationService().hybridUsersList[0].latLng, 4)
                          // mapController.move(
                          //     LocationService().hybridUsersList[0].latLng, 3)
                          : null;
                    }),
              ),
              SlidingUpPanel(
                controller: pc,
                minHeight: widget.userListenerKeyword != null ? 119 : 205,
                maxHeight: widget.userListenerKeyword != null ? 291 : 431,
                // collapsed: CollapsedContent(UniqueKey(), false,
                //     eventListenerKeyword: widget.eventListenerKeyword,
                //     userListenerKeyword: widget.userListenerKeyword),
                panel: CollapsedContent(UniqueKey(), true, this.isEventAdmin,
                    widget.atClientInstance,
                    eventListenerKeyword: widget.eventListenerKeyword,
                    userListenerKeyword: widget.userListenerKeyword),
              )
            ],
          )),
    );
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

  getAtSignAndInitializeChat() async {
    initializeChatService(
        widget.atClientInstance, widget.atClientInstance.currentAtSign,
        rootDomain: MixedConstants.ROOT_DOMAIN);
  }

  setAtsignToChatWith() {
    String chatWith;
    if (LocationService().eventListenerKeyword != null) {
      if (LocationService().eventListenerKeyword.atsignCreator ==
          widget.atClientInstance.currentAtSign) {
        chatWith =
            widget.eventListenerKeyword.group.members.elementAt(0).atSign;
      } else
        chatWith = widget.eventListenerKeyword.atsignCreator;
    }
    if (widget.eventListenerKeyword != null) {
      setChatWithAtSign(chatWith);
    }
  }
}
