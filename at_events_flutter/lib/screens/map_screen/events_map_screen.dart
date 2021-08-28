import 'dart:async';
import 'dart:typed_data';
import 'package:at_chat_flutter/at_chat_flutter.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/src/model/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_events_flutter/common_components/floating_icon.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_events_flutter/utils/colors.dart';
import 'package:at_events_flutter/utils/constants.dart';
import 'package:at_location_flutter/common_components/build_marker.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/service/distance_calculate.dart';
import 'package:at_location_flutter/event_show_location.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'events_collapsed_content.dart';

class EventsMapScreenData {
  EventsMapScreenData._();
  static final EventsMapScreenData _instance = EventsMapScreenData._();
  factory EventsMapScreenData() => _instance;

  ValueNotifier<EventNotificationModel?>? eventNotifier;
  late List<HybridModel>? markers;
  late List<String?> exitedAtSigns;
  int count = 0;

  Future<void> moveToEventScreen(EventNotificationModel _eventNotificationModel) async {
    markers = <HybridModel>[];
    exitedAtSigns = <String?>[];
    await _initChat(_eventNotificationModel);
    _calculateExitedAtsigns(_eventNotificationModel);
    eventNotifier = ValueNotifier<EventNotificationModel?>(_eventNotificationModel);
    markers!.add(addVenueMarker(_eventNotificationModel));

    await Navigator.push(
      AtEventNotificationListener().navKey!.currentContext!,
      MaterialPageRoute<_EventsMapScreen>(
        builder: (BuildContext context) => const _EventsMapScreen(),
      ),
    );

    // markers =
    List<HybridModel> _hybridModelList = await _calculateHybridModelList(_eventNotificationModel);
    for (HybridModel element in _hybridModelList) {
      markers!.add(element);
    }
    eventNotifier!.value = eventNotifier!.value;
  }

  void _calculateExitedAtsigns(EventNotificationModel _event) {
    for (AtContact element in _event.group!.members!) {
      if ((element.tags!['isExited']) && (!element.tags!['isAccepted'])) {
        exitedAtSigns.add(element.atSign);
      }
    }
  }

  // ignore: prefer_final_fields
  List<List<EventKeyLocationModel>> _listOfLists = <List<EventKeyLocationModel>>[];
  bool _updating = false;
  void updateEventdataFromList(List<EventKeyLocationModel> _list) {
    _listOfLists.add(_list);
    if (!_updating) {
      _startUpdating();
    }
  }

  Future<void> _startUpdating() async {
    _updating = true;
    for (int i = 0; i < _listOfLists.length; i++) {
      List<EventKeyLocationModel> _obj = _listOfLists.removeAt(0);
      await _updateEventdataFromList(_obj);
    }
    _updating = false;
  }

  Future<void> _updateEventdataFromList(List<EventKeyLocationModel> _list) async {
    count++;
    print('count++ $count');
    if (eventNotifier != null) {
      for (int i = 0; i < _list.length; i++) {
        if (_list[i].eventNotificationModel!.key == eventNotifier!.value!.key) {
          exitedAtSigns = <String?>[];
          _calculateExitedAtsigns(_list[i].eventNotificationModel!);

          markers = <HybridModel>[];

          markers!.add(addVenueMarker(_list[i].eventNotificationModel!));

          List<HybridModel> _hybridModelList = await _calculateHybridModelList(_list[i].eventNotificationModel!);
          for (HybridModel element in _hybridModelList) {
            markers!.add(element);
          }

          eventNotifier!.value = _list[i].eventNotificationModel;
          eventNotifier!.value = eventNotifier!.value;

          count--;
          print('count-- $count');
          break;
        }
      }
    }
  }

  HybridModel addVenueMarker(EventNotificationModel _event) {
    HybridModel _eventHybridModel = HybridModel(
        displayName: _event.venue!.label,
        latLng: LatLng(_event.venue!.latitude!, _event.venue!.longitude!),
        eta: '?',
        image: null);
    _eventHybridModel.marker = buildMarker(_eventHybridModel);
    return _eventHybridModel;
  }

  Future<List<HybridModel>> _calculateHybridModelList(EventNotificationModel _event) async {
    List<HybridModel> _tempMarkersList = <HybridModel>[];

    /// Event creator
    if (_event.lat != null && _event.long != null) {
      HybridModel user = HybridModel(
          displayName: _event.atsignCreator, latLng: LatLng(_event.lat!, _event.long!), eta: '?', image: null);
      user.eta = await _calculateEta(user, LatLng(_event.venue!.latitude!, _event.venue!.longitude!));
      user.image = await (_imageOfAtsign(_event.atsignCreator!));
      user.marker = buildMarker(user);
      _tempMarkersList.add(user);
    }

    /// Event members
    await Future.forEach(_event.group!.members!, (dynamic element) async {
      print('${element.atSign}, ${element.tags['lat']}, ${element.tags['long']}');
      if ((element.tags['lat'] != null) && (element.tags['long'] != null)) {
        HybridModel _user = HybridModel(
            displayName: element.atSign,
            latLng: LatLng(element.tags['lat'], element.tags['long']),
            eta: '?',
            image: null);
        _user.eta = await _calculateEta(_user, LatLng(_event.venue!.latitude!, _event.venue!.longitude!));

        _user.image = await (_imageOfAtsign(element.atSign));
        _user.marker = buildMarker(_user);

        _tempMarkersList.add(_user);
      }
    });

    return _tempMarkersList;
  }

  Future<String> _calculateEta(HybridModel user, LatLng etaFrom) async {
    try {
      String _res = await DistanceCalculate().calculateETA(etaFrom, user.latLng!);
      return _res;
    } catch (e) {
      print('Error in _calculateEta $e');
      return '?';
    }
  }

  Future<Uint8List?> _imageOfAtsign(String _atsign) async {
    AtContact? contact = await getAtSignDetails(_atsign);
    if (contact.tags != null && contact.tags!['image'] != null) {
      List<int> intList = contact.tags!['image'].cast<int>();
      return Uint8List.fromList(intList);
    }
    return null;
  }

  Future<void> _initChat(EventNotificationModel _event) async {
    await _getAtSignAndInitializeChat();
    _setAtsignToChatWith(_event);
  }

  Future<void> _getAtSignAndInitializeChat() async {
    initializeChatService(AtEventNotificationListener().atClientInstance!, AtEventNotificationListener().currentAtSign!,
        rootDomain: MixedConstants.rootDomain);
  }

  void _setAtsignToChatWith(EventNotificationModel _event) {
    List<String> groupMembers = <String>[];
    groupMembers.add(_event.atsignCreator!);
    for (AtContact member in _event.group!.members!) {
      groupMembers.add(member.atSign!);
    }
    groupMembers.remove(AtEventNotificationListener().currentAtSign);
    String atkeyMicrosecondId = _event.key!.split('createevent-')[1].split('@')[0];
    if ((AtEventNotificationListener().atClientInstance!.preference != null) &&
        (AtEventNotificationListener().atClientInstance!.preference!.namespace != null)) {
      atkeyMicrosecondId = atkeyMicrosecondId.replaceAll(
          '.${AtEventNotificationListener().atClientInstance!.preference!.namespace!}', '');
    }
    print('atkeyMicrosecondId $atkeyMicrosecondId');
    setChatWithAtSign('', isGroup: true, groupId: atkeyMicrosecondId, groupMembers: groupMembers);
  }

  void dispose() {
    eventNotifier = null;
    markers = <HybridModel>[];
    exitedAtSigns = <String?>[];
  }
}

class _EventsMapScreen extends StatefulWidget {
  const _EventsMapScreen({Key? key}) : super(key: key);

  @override
  _EventsMapScreenState createState() => _EventsMapScreenState();
}

class _EventsMapScreenState extends State<_EventsMapScreen> {
  final PanelController pc = PanelController();
  bool snackbarShownOnce = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    EventsMapScreenData().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: Container(
          alignment: Alignment.center,
          child: ValueListenableBuilder<EventNotificationModel?>(
            valueListenable: EventsMapScreenData().eventNotifier!,
            builder: (BuildContext context, EventNotificationModel? _event, Widget? child) {
              print('ValueListenableBuilder called');
              List<HybridModel> _locationList = EventsMapScreenData().markers!;
              List<String> _membersSharingLocation = <String>[];
              for (HybridModel e in _locationList) {
                if ((e.displayName != AtEventNotificationListener().currentAtSign) &&
                    (e.displayName != _event!.venue!.label)) {
                  _membersSharingLocation.add(e.displayName!);
                }
              }

              print('_locationList $_locationList');

              if ((!snackbarShownOnce) && (_membersSharingLocation.isNotEmpty)) {
                Future<dynamic>.delayed(const Duration(seconds: 1), () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(_membersSharingLocation.length > 1
                        ? '${_listToString(_membersSharingLocation)} are sharing their locations'
                        : '${_listToString(_membersSharingLocation)} is sharing their location'),
                  ));
                  snackbarShownOnce = true;
                });
              }

              return Stack(
                children: <Widget>[
                  eventShowLocation(_locationList, LatLng(_event!.venue!.latitude!, _event.venue!.longitude!)),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: FloatingIcon(
                      icon: Icons.arrow_back,
                      isTopLeft: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: FloatingIcon(
                        bgColor: AllColors().Black,
                        icon: Icons.message_outlined,
                        iconColor: Theme.of(context).scaffoldBackgroundColor,
                        onPressed: () =>
                            scaffoldKey.currentState!.showBottomSheet((BuildContext context) => const ChatScreen())),
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

  String? _listToString(List<String?> _strings) {
    String? _res;
    if (_strings.isNotEmpty) {
      _res = _strings[0];
    }

    for (String? element in _strings.sublist(1)) {
      _res = '$_res, $element';
    }

    return _res;
  }
}
