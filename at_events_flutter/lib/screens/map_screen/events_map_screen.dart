import 'dart:typed_data';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_events_flutter/common_components/floating_icon.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_location_flutter/common_components/build_marker.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/service/distance_calculate.dart';
import 'package:at_location_flutter/event_show_location.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'events_collapsed_content.dart';

class EventsMapScreenData {
  EventsMapScreenData._();
  static final EventsMapScreenData _instance = EventsMapScreenData._();
  factory EventsMapScreenData() => _instance;

  ValueNotifier<EventNotificationModel> _eventNotifier;
  List<HybridModel> markers;
  // bool isMounted;

  void moveToEventScreen(EventNotificationModel _eventNotificationModel) async {
    _eventNotifier = ValueNotifier(_eventNotificationModel);
    markers = await _calculateHybridModelList(_eventNotificationModel);
    await Navigator.push(
      AtEventNotificationListener().navKey.currentContext,
      MaterialPageRoute(
        builder: (context) => _EventsMapScreen(),
      ),
    );
  }

  void updateEventdata(EventNotificationModel _eventNotificationModel) async {
    if (_eventNotificationModel.key == _eventNotifier.value.key) {
      markers = await _calculateHybridModelList(_eventNotificationModel);
      _eventNotifier.value = _eventNotificationModel;
    }
  }

  void updateEventdataFromList(List<EventKeyLocationModel> _list) async {
    if (_eventNotifier != null) {
      for (var i = 0; i < _list.length; i++) {
        if (_list[i].eventNotificationModel.key == _eventNotifier.value.key) {
          markers =
              await _calculateHybridModelList(_list[i].eventNotificationModel);
          _eventNotifier.value = _list[i].eventNotificationModel;
          _eventNotifier.notifyListeners();
          break;
        }
      }
    }
  }

  Future<List<HybridModel>> _calculateHybridModelList(
      EventNotificationModel _event) async {
    var _locationList = <HybridModel>[];

    /// Event venue
    var _eventHybridModel = HybridModel(
        displayName: _event.venue.label,
        latLng: LatLng(_event.venue.latitude, _event.venue.longitude),
        eta: '?',
        image: null);
    _eventHybridModel.marker = buildMarker(_eventHybridModel);
    _locationList.add(_eventHybridModel);

    /// Event creator
    if (_event.lat != null && _event.long != null) {
      var user = HybridModel(
          displayName: _event.atsignCreator,
          latLng: LatLng(_event.lat, _event.long),
          eta: '?',
          image: null);
      user.eta = await _calculateEta(user, _eventHybridModel.latLng);
      user.image = await _imageOfAtsign(_event.atsignCreator);
      user.marker = buildMarker(user);
      _locationList.add(user);
    }

    /// Event members
    await Future.forEach(_event.group.members, (element) async {
      print(
          '${element.atSign}, ${element.tags['lat']}, ${element.tags['long']}');
      if ((element.tags['lat'] != null) && (element.tags['long'] != null)) {
        var _user = HybridModel(
            displayName: element.atSign,
            latLng: LatLng(element.tags['lat'], element.tags['long']),
            eta: '?',
            image: null);
        _user.eta = await _calculateEta(_user, _eventHybridModel.latLng);

        _user.image = await _imageOfAtsign(element.atSign);
        _user.marker = buildMarker(_user);

        _locationList.add(_user);
      }
    });

    return _locationList;
  }

  Future<String> _calculateEta(HybridModel user, LatLng etaFrom) async {
    try {
      var _res = await DistanceCalculate().calculateETA(etaFrom, user.latLng);
      return _res;
    } catch (e) {
      print('Error in _calculateEta $e');
      return '?';
    }
  }

  Future<dynamic> _imageOfAtsign(String _atsign) async {
    var contact = await getAtSignDetails(_atsign);
    if (contact != null) {
      if (contact.tags != null && contact.tags['image'] != null) {
        List<int> intList = contact.tags['image'].cast<int>();
        return Uint8List.fromList(intList);
      }
    }

    return null;
  }

  void dispose() {
    _eventNotifier = null;
  }
}

class _EventsMapScreen extends StatefulWidget {
  const _EventsMapScreen({Key key}) : super(key: key);

  @override
  _EventsMapScreenState createState() => _EventsMapScreenState();
}

class _EventsMapScreenState extends State<_EventsMapScreen> {
  final PanelController pc = PanelController();

  @override
  void dispose() {
    EventsMapScreenData().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: ValueListenableBuilder(
            valueListenable: EventsMapScreenData()._eventNotifier,
            builder: (BuildContext context, EventNotificationModel _event,
                Widget child) {
              print('ValueListenableBuilder called');
              var _locationList = EventsMapScreenData().markers;
              var _membersSharingLocation = [];
              _locationList.forEach((e) => {
                    if ((e.displayName !=
                            AtEventNotificationListener().currentAtSign) &&
                        (e.displayName != _event.venue.label))
                      {_membersSharingLocation.add(e.displayName)}
                  });

              print('_locationList $_locationList');

              if (_membersSharingLocation.isNotEmpty) {
                Future.delayed(Duration(seconds: 1), () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(_membersSharingLocation.length > 1
                          ? '${_listToString(_membersSharingLocation)} are sharing their locations'
                          : '${_listToString(_membersSharingLocation)} is sharing their location')));
                });
              }

              return Stack(
                children: [
                  eventShowLocation(_locationList,
                      LatLng(_event.venue.latitude, _event.venue.longitude)),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: FloatingIcon(
                      icon: Icons.arrow_back,
                      isTopLeft: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SlidingUpPanel(
                    controller: pc,
                    minHeight: 205.toHeight,
                    maxHeight: 431.toHeight,
                    panel: eventsCollapsedContent(_event),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _listToString(List _strings) {
    String _res;
    if (_strings.isNotEmpty) {
      _res = _strings[0];
    }

    _strings.sublist(1).forEach((element) {
      _res = '$_res, $element';
    });

    return _res;
  }
}
