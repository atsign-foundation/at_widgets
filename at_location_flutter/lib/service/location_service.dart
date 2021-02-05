import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_events_flutter/common_components/custom_toast.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_location_flutter/common_components/build_marker.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_lookup/src/connection/outbound_connection.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'distance_calculate.dart';

class LocationService {
  LocationService._();
  static LocationService _instance = LocationService._();
  factory LocationService() => _instance;

  AtClientImpl atClientInstance;
  LocationNotificationModel userListenerKeyword;
  EventNotificationModel eventListenerKeyword;
  String _atsign;
  AtClientService atClientServiceInstance;
  ValueChanged<EventNotificationModel> onEventUpdate;
  Function callBackFunction,
      onEventCancel,
      onEventExit,
      onShareToggle,
      onRequest,
      onRemove;

  HybridModel eventData;
  HybridModel myData;

  List<String> atsignsAtMonitor;
  List<HybridModel> hybridUsersList;
  List<HybridModel> allUsersList;

  StreamController _atHybridUsersController;
  Stream<List<HybridModel>> get atHybridUsersStream =>
      _atHybridUsersController.stream;
  StreamSink<List<HybridModel>> get atHybridUsersSink =>
      _atHybridUsersController.sink;

  // ignore: close_sinks
  StreamController eventController =
      StreamController<EventNotificationModel>.broadcast();
  Stream<EventNotificationModel> get eventStream => eventController.stream;
  StreamSink<EventNotificationModel> get eventSink => eventController.sink;

  init(AtClientImpl _atClientInstance, List<HybridModel> _allUsersList,
      {LocationNotificationModel newUserListenerKeyword,
      EventNotificationModel newEventListenerKeyword,
      Function eventCancel,
      Function eventExit,
      Function newOnRemove,
      Function newOnRequest,
      Function newOnShareToggle}) {
    hybridUsersList = [];
    atsignsAtMonitor = [];
    allUsersList = _allUsersList;
    _atHybridUsersController = StreamController<List<HybridModel>>.broadcast();
    atClientServiceInstance = AtClientService();
    atClientInstance = _atClientInstance;

    addMyDetailsToHybridUsersList();

    if (newUserListenerKeyword != null) {
      print('newUserListenerKeyword');
      userListenerKeyword = newUserListenerKeyword;
      eventListenerKeyword = null;
      onShareToggle = newOnShareToggle;
      onRequest = newOnRequest;
      onRemove = newOnRemove;
    } else if (newEventListenerKeyword != null) {
      print('newEventListenerKeyword');
      eventListenerKeyword = newEventListenerKeyword;
      userListenerKeyword = null;
      atsignsAtMonitor =
          eventListenerKeyword.group.members.map((e) => e.atSign).toList();
      atsignsAtMonitor.add(eventListenerKeyword.atsignCreator);
      atsignsAtMonitor.remove(
          myData?.displayName); // So, that i dont get my own notification
      addEventDetailsToHybridUsersList();
    }

    if (eventCancel != null) {
      onEventCancel = eventCancel;
    }
    if (eventExit != null) {
      onEventExit = eventExit;
    }
    updateHybridList();
  }

  void dispose() {
    _atHybridUsersController.close();
  }

  addMyDetailsToHybridUsersList() async {
    String _atsign = getAtSign();
    LatLng mylatlng = await MyLocation().myLocation();
    var _image = await getImageOfAtsignNew(_atsign);

    HybridModel _myData = HybridModel(
        displayName: _atsign, latLng: mylatlng, eta: '?', image: _image);
    _myData.marker = buildMarker(_myData);

    myData = _myData;
    if ((eventListenerKeyword != null) && (eventData != null))
      await _calculateEta(myData); //To add eta for the user

    hybridUsersList.add(myData);
    _atHybridUsersController.add(hybridUsersList);

    atsignsAtMonitor
        ?.remove(myData.displayName); // So, that i dont get my own notification
  }

  addEventDetailsToHybridUsersList() async {
    HybridModel eventHybridModel = HybridModel(
      displayName: eventListenerKeyword.title,
      latLng: LatLng(eventListenerKeyword.venue.latitude,
          eventListenerKeyword.venue.longitude),
      eta: '?',
    );
    eventHybridModel.marker = buildMarker(eventHybridModel);
    hybridUsersList.add(eventHybridModel);
    eventData = eventHybridModel;
    if (myData != null) await _calculateEta(myData); //To add eta for the user
    _atHybridUsersController.add(hybridUsersList);

    print('updateEventLocation called ');
  }

  // called for the first time pckage is entered from main app
  updateHybridList() async {
    if (userListenerKeyword != null) {
      allUsersList.forEach((user) async {
        if (user.displayName == userListenerKeyword.atsignCreator)
          await updateDetails(user);
      });
    } else if (eventListenerKeyword != null) {
      allUsersList.forEach((user) async {
        if (atsignsAtMonitor.contains(user.displayName))
          await updateDetails(user);
      });
    }

    _atHybridUsersController.add(hybridUsersList);
  }

  // called when any new/updated data is received in the main app
  newList(List<HybridModel> allUsersFromMainApp) {
    if (userListenerKeyword != null) {
      allUsersFromMainApp.forEach((user) async {
        if (user.displayName == userListenerKeyword.atsignCreator)
          await updateDetails(user);
      });
      _atHybridUsersController.add(hybridUsersList);
    } else if (eventListenerKeyword != null) {
      allUsersFromMainApp.forEach((user) async {
        if (atsignsAtMonitor.contains(user.displayName))
          await updateDetails(user);
      });
      _atHybridUsersController.add(hybridUsersList);
    }
  }

  // called when a user stops sharing his location
  removeUser(String atsign) {
    if (userListenerKeyword != null) {
      hybridUsersList.removeWhere((element) => element.displayName == atsign);
      _atHybridUsersController.add(hybridUsersList);
    } else if (eventListenerKeyword != null) {
      hybridUsersList.removeWhere((element) => element.displayName == atsign);
      _atHybridUsersController.add(hybridUsersList);
    }
  }

  // called to get the new details marker & eta
  updateDetails(HybridModel user) async {
    bool contains = false;
    int index;
    hybridUsersList.forEach((hybridUser) {
      if (hybridUser.displayName == user.displayName) {
        contains = true;
        index = hybridUsersList.indexOf(hybridUser);
      }
    });
    if (contains) {
      print('${hybridUsersList[index].latLng} != ${user.latLng}');
      await addDetails(user, index: index);
    } else
      await addDetails(user);
  }

  // returns new marker and eta
  addDetails(HybridModel user, {int index}) async {
    user.marker = buildMarker(user);
    // await _calculateEta(user);
    if (index != null)
      hybridUsersList[index] = user;
    else
      hybridUsersList.add(user);
  }

  _calculateEta(HybridModel user) async {
    if (eventListenerKeyword != null) {
      var _res =
          await DistanceCalculate().caculateETA(eventData.latLng, user.latLng);
      if (_res != user.eta) {
        user.eta = _res;
      }
    } else if ((userListenerKeyword != null) &&
        (user.displayName != myData.displayName)) {
      // LatLng mylatlng = await MyLocation().myLocation();
      LatLng mylatlng = myData.latLng;

      var _res = await DistanceCalculate().caculateETA(mylatlng, user.latLng);
      if (_res != user.eta) {
        user.eta = _res;
        myData.eta = user.eta; // because, user's eta & myData.eta will be same
      }
    }
  }

  getImageOfAtsignNew(String atsign) async {
    AtContact contact;
    Uint8List image;
    AtContactsImpl atContact = await AtContactsImpl.getInstance(getAtSign());
    contact = await atContact.get(atsign);
    if (contact != null) {
      if (contact.tags != null && contact.tags['image'] != null) {
        List<int> intList = contact.tags['image'].cast<int>();
        image = Uint8List.fromList(intList);
      }
    }
    return image;
  }

  String getAtSign() {
    return atClientInstance.currentAtSign;
  }

  Future<String> getPrivateKey(String atsign) async {
    return await atClientServiceInstance.getPrivateKey(atsign);
  }
}
