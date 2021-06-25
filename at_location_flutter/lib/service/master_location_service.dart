import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'package:latlong/latlong.dart';

import 'contact_service.dart';
import 'location_service.dart';

class MasterLocationService {
  MasterLocationService._();
  static final MasterLocationService _instance = MasterLocationService._();
  factory MasterLocationService() => _instance;
  AtClientImpl atClientInstance;
  Function getAtValueFromMainApp;

  String currentAtSign;
  List<HybridModel> allReceivedUsersList;
  List<KeyLocationModel> allLocationNotifications = [];

  final String locationKey = 'locationnotify';

  StreamController _allReceivedUsersController;
  Stream<List<HybridModel>> get allReceivedUsersStream =>
      _allReceivedUsersController.stream;
  StreamSink<List<HybridModel>> get allReceivedUsersSink =>
      _allReceivedUsersController.sink;

  void init(String currentAtSignFromApp, AtClientImpl atClientInstanceFromApp,
      {Function newGetAtValueFromMainApp}) {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    allReceivedUsersList = [];
    _allReceivedUsersController =
        StreamController<List<HybridModel>>.broadcast();

    if (newGetAtValueFromMainApp != null) {
      getAtValueFromMainApp = newGetAtValueFromMainApp;
    }

    getAtValueFromMainApp = getAtValue;

    getAllLocationData();
  }

  /// get all 'locationnotify' data shared with us
  Future<void> getAllLocationData() async {
    var response = await atClientInstance.getKeys(
      regex: '$locationKey',
    );
    if (response.isEmpty) {
      return;
    }

    await Future.forEach(response, (key) async {
      if ('@$key'.contains('cached')) {
        var atKey = getAtKey(key);
        AtValue value = await getAtValueFromMainApp(atKey);
        if (value != null) {
          var tempKeyLocationModel =
              KeyLocationModel(key: key, atKey: atKey, atValue: value);
          allLocationNotifications.add(tempKeyLocationModel);
        }
      }
    });

    convertJsonToLocationModel();
    filterData();

    createHybridFromKeyLocationModel();
  }

  void convertJsonToLocationModel() {
    for (var i = 0; i < allLocationNotifications.length; i++) {
      try {
        if ((allLocationNotifications[i].atValue.value != null) &&
            (allLocationNotifications[i].atValue.value != 'null')) {
          var locationNotificationModel = LocationNotificationModel.fromJson(
              jsonDecode(allLocationNotifications[i].atValue.value));
          allLocationNotifications[i].locationNotificationModel =
              locationNotificationModel;
        }
      } catch (e) {
        print('error in convertJsonToLocationModel:$e');
      }
    }
  }

  void filterData() {
    var tempArray = <KeyLocationModel>[];
    for (var i = 0; i < allLocationNotifications.length; i++) {
      // ignore: unrelated_type_equality_checks
      if ((allLocationNotifications[i].locationNotificationModel == 'null') ||
          (allLocationNotifications[i].locationNotificationModel == null) ||
          ((allLocationNotifications[i].locationNotificationModel.to != null) &&
              (allLocationNotifications[i]
                      .locationNotificationModel
                      .to
                      .difference(DateTime.now())
                      .inMinutes <
                  0))) tempArray.add(allLocationNotifications[i]);
    }

    allLocationNotifications
        .removeWhere((element) => tempArray.contains(element));
  }

  void createHybridFromKeyLocationModel() async {
    await Future.forEach(allLocationNotifications, (keyLocationModel) async {
      var _image = await getImageOfAtsignNew(
          keyLocationModel.locationNotificationModel.atsignCreator);
      var user = HybridModel(
          displayName: keyLocationModel.locationNotificationModel.atsignCreator,
          latLng: keyLocationModel.locationNotificationModel.getLatLng,
          image: _image,
          eta: '?');

      allReceivedUsersList.add(user);
    });
    allReceivedUsersSink.add(allReceivedUsersList);
  }

  void updateHybridList(LocationNotificationModel newUser) async {
    var contains = false;
    int index;
    allReceivedUsersList.forEach((user) {
      if (user.displayName == newUser.atsignCreator) {
        contains = true;
        index = allReceivedUsersList.indexOf(user);
      }
    });
    if (!contains) {
      if (newUser.getLatLng != LatLng(0, 0)) {
        print('!contains from main app');
        var atsign = newUser.atsignCreator;
        var _latlng = newUser.getLatLng;
        var _image = await getImageOfAtsignNew(atsign);

        var user = HybridModel(
            displayName: newUser.atsignCreator,
            latLng: _latlng,
            image: _image,
            eta: '?');

        allReceivedUsersList.add(user);
        _allReceivedUsersController.add(allReceivedUsersList);
        allReceivedUsersSink.add(allReceivedUsersList);
        LocationService().newList();
      }
    } else {
      print('contains from main app');

      allReceivedUsersList[index].latLng = newUser.getLatLng;
      allReceivedUsersList[index].eta = '?';
      _allReceivedUsersController.add(allReceivedUsersList);
      allReceivedUsersSink.add(allReceivedUsersList);
      LocationService().newList();
    }
  }

  void deleteReceivedData(String atsign) {
    allReceivedUsersList
        .removeWhere((element) => element.displayName == atsign);
    LocationService().removeUser(atsign);
    allReceivedUsersSink.add(allReceivedUsersList);
  }

  Future<Uint8List> getImageOfAtsignNew(String atsign) async {
    try {
      AtContact contact;
      Uint8List image;
      contact = await getAtSignDetails(atsign);

      if (contact != null) {
        if (contact.tags != null && contact.tags['image'] != null) {
          List<int> intList = contact.tags['image'].cast<int>();
          image = Uint8List.fromList(intList);
        }
      }
      return image;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> getAtValue(AtKey key) async {
    print(atClientInstance.currentAtSign);
    try {
      var atvalue = await atClientInstance.get(key).catchError(
          // ignore: return_of_invalid_type_from_catch_error
          (e) => print('error in getAtValue in master location service : $e'));

      if (atvalue != null) {
        return atvalue;
      } else {
        return null;
      }
    } catch (e) {
      print('getAtValue in master location service:$e');
      return null;
    }
  }
}
