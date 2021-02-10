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
import 'package:at_location_flutter/service/master_location_service.dart';
import 'package:at_lookup/src/connection/outbound_connection.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'distance_calculate.dart';

class LocationService {
  LocationService._();
  static LocationService _instance = LocationService._();
  factory LocationService() => _instance;

  List<String> atsignsToTrack;

  AtClientImpl atClientInstance;

  HybridModel eventData;
  HybridModel myData;

  List<HybridModel> hybridUsersList;

  StreamController _atHybridUsersController;
  Stream<List<HybridModel>> get atHybridUsersStream =>
      _atHybridUsersController.stream;
  StreamSink<List<HybridModel>> get atHybridUsersSink =>
      _atHybridUsersController.sink;

  init(List<String> atsignsToTrackFromApp) {
    hybridUsersList = [];
    _atHybridUsersController = StreamController<List<HybridModel>>.broadcast();
    atsignsToTrack = atsignsToTrackFromApp;
    print('atsignsTotrack $atsignsToTrack');
    updateHybridList();
  }

  void dispose() {
    _atHybridUsersController.close();
  }

  addMyDetailsToHybridUsersList() async {}

  addEventDetailsToHybridUsersList() async {}

  // called for the first time pckage is entered from main app
  updateHybridList() async {
    print('updateHybridList location_service');
    MasterLocationService().allReceivedUsersList.forEach((user) async {
      print('MasterLocationService().allReceivedUsersList ${user.displayName}');
      print(
          'atsignsToTrack.contains(user.displayName) ${atsignsToTrack.contains(user.displayName)}');
      if (atsignsToTrack.contains(user.displayName)) await updateDetails(user);
    });
    print('hybridUsersList $hybridUsersList');
    hybridUsersList.forEach((element) {
      print('added in updateHybridList: ${element.displayName}');
      print('added in updateHybridList: ${element.latLng}');
    });
    if (_atHybridUsersController.hasListener)
      _atHybridUsersController.add(hybridUsersList);
    else
      Future.delayed(const Duration(seconds: 2),
          () => _atHybridUsersController.add(hybridUsersList));
  }

  // called when any new/updated data is received in the main app
  newList() {
    if (atsignsToTrack != null) {
      MasterLocationService().allReceivedUsersList.forEach((user) async {
        if (atsignsToTrack.contains(user.displayName))
          await updateDetails(user);
      });
      hybridUsersList.forEach((element) {
        print('added in location_service: ${element.displayName}');
      });
      if (!_atHybridUsersController.isClosed)
        _atHybridUsersController.add(hybridUsersList);
    }
  }

  // called when a user stops sharing his location
  removeUser(String atsign) {
    if (atsignsToTrack != null) {
      hybridUsersList.removeWhere((element) => element.displayName == atsign);
      if (!_atHybridUsersController.isClosed)
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
    print('hybridUsersList from addDetails $hybridUsersList');
  }

  _calculateEta(HybridModel user) async {}
}
