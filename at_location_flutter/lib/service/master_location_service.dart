import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_location_flutter/common_components/build_marker.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:latlong/latlong.dart';

import 'location_service.dart';

class MasterLocationService {
  MasterLocationService._();
  static final MasterLocationService _instance = MasterLocationService._();
  factory MasterLocationService() => _instance;
  AtClientImpl atClientInstance;
  // TODO: dont use this atValue, use the one in this file
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

  init(String currentAtSignFromApp, AtClientImpl atClientInstanceFromApp,
      {Function newGetAtValueFromMainApp}) {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    allReceivedUsersList = [];
    _allReceivedUsersController =
        StreamController<List<HybridModel>>.broadcast();
    if (newGetAtValueFromMainApp != null)
      getAtValueFromMainApp = newGetAtValueFromMainApp;
    //TODO: look at this logic later
    getAtValueFromMainApp = getAtValue;

    // get all 'locationnotify' data shared with us
    getAllLocationData();
  }

  getAllLocationData() async {
    List<String> response = await atClientInstance.getKeys(
      regex: '$locationKey',
      //  sharedBy: '@bob🛠'
    );
    print('response $response');
    if (response.length == 0) {
      return;
    }

    await Future.forEach(response, (key) async {
      if ('@$key'.contains('cached')) {
        print('cached key $key');
        AtKey atKey = AtKey.fromString(key);
        print('getAllLocationData atkey $atKey');
        // AtValue value = await getAtValue(atKey);
        AtValue value = await getAtValueFromMainApp(atKey);
        if (value != null) {
          print('at value location $value');
          KeyLocationModel tempKeyLocationModel =
              KeyLocationModel(key: key, atKey: atKey, atValue: value);
          allLocationNotifications.add(tempKeyLocationModel);
        }
      }
    });

    print('allLocationNotifications AtValue $allLocationNotifications');
    convertJsonToLocationModel();
    filterData();

    createHybridFromKeyLocationModel();
    allReceivedUsersList.forEach((notification) {
      print('LocationNotificationModel ${notification.displayName}');
    });
    print(
        'allLocationNotifications LocationNotificationModel $allLocationNotifications');
  }

  convertJsonToLocationModel() {
    print(
        'allShareLocationNotifications.length -> ${allLocationNotifications.length}');
    for (int i = 0; i < allLocationNotifications.length; i++) {
      try {
        if ((allLocationNotifications[i].atValue.value != null) &&
            (allLocationNotifications[i].atValue.value != "null")) {
          LocationNotificationModel locationNotificationModel =
              LocationNotificationModel.fromJson(
                  jsonDecode(allLocationNotifications[i].atValue.value));
          allLocationNotifications[i].locationNotificationModel =
              locationNotificationModel;
          print(
              'locationNotificationModel $i -> ${locationNotificationModel.getLatLng}');
        }
      } catch (e) {
        print('error in convertJsonToLocationModel:$e');
      }
    }
  }

  filterData() {
    List<KeyLocationModel> tempArray = [];
    for (int i = 0; i < allLocationNotifications.length; i++) {
      if ((allLocationNotifications[i].locationNotificationModel == 'null') ||
          (allLocationNotifications[i].locationNotificationModel == null))
        tempArray.add(allLocationNotifications[i]);
    }
    tempArray.forEach((element) {
      print('removed ${element.locationNotificationModel.atsignCreator}');
    });
    allLocationNotifications
        .removeWhere((element) => tempArray.contains(element));
  }

  createHybridFromKeyLocationModel() {
    print('inside createHybridFromKeyLocationModel');
    allLocationNotifications.forEach((KeyLocationModel) async {
      var _image = await getImageOfAtsignNew(
          KeyLocationModel.locationNotificationModel.atsignCreator);
      HybridModel user = HybridModel(
          displayName: KeyLocationModel.locationNotificationModel.atsignCreator,
          latLng: KeyLocationModel.locationNotificationModel.getLatLng,
          image: _image,
          eta: '?');
      print('HybridModel named ${user.displayName}');
      allReceivedUsersList.add(user);
    });
    allReceivedUsersSink.add(allReceivedUsersList);
    // TODO: this print statement doesnt print but the user's location is retrieved if no exception is thrown in getAtValue
    allReceivedUsersList.forEach((element) {
      print("user retrieved - ${element.displayName}");
    });
  }

  updateHybridList(LocationNotificationModel newUser) async {
    bool contains = false;
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
        String atsign = newUser.atsignCreator;
        LatLng _latlng = newUser.getLatLng;
        var _image = await getImageOfAtsignNew(atsign);

        HybridModel user = HybridModel(
            displayName: newUser.atsignCreator,
            latLng: _latlng,
            image: _image,
            eta: '?');

        allReceivedUsersList.add(user);
        _allReceivedUsersController.add(allReceivedUsersList);
        print('atHybridUsersSink added');
        allReceivedUsersSink.add(allReceivedUsersList);
        LocationService().newList();
      }
    } else {
      print('contains from main app');
      if (newUser.getLatLng == LatLng(0, 0)) {
        allReceivedUsersList.remove(allReceivedUsersList[index]);
        LocationService().removeUser(newUser.atsignCreator);
        allReceivedUsersSink.add(allReceivedUsersList);
      } else
      // if (allUsersList[index].latLng != newUser.getLatLng) // to not update location when same lat , long received(throwing error)
      {
        allReceivedUsersList[index].latLng = newUser.getLatLng;
        allReceivedUsersList[index].eta = '?';
        _allReceivedUsersController.add(allReceivedUsersList);
        print('atHybridUsersSink added');
        allReceivedUsersSink.add(allReceivedUsersList);
        LocationService().newList();
      }
    }
    allReceivedUsersList.forEach((element) {
      print("user got from callback - ${element.displayName}");
    });
  }

  deleteReceivedData(String atsign) {
    allReceivedUsersList
        .removeWhere((element) => element.displayName == atsign);
    LocationService().removeUser(atsign);
    allReceivedUsersSink.add(allReceivedUsersList);
  }

  getImageOfAtsignNew(String atsign) async {
    try {
      AtContact contact;
      Uint8List image;
      AtContactsImpl atContact =
          await AtContactsImpl.getInstance(currentAtSign);
      contact = await atContact.get(atsign);
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
      AtValue atvalue = await atClientInstance.get(key).catchError(
          (e) => print("error in getAtValue in master location service : $e"));

      if (atvalue != null)
        return atvalue;
      else
        return null;
    } catch (e) {
      print('getAtValue in master location service:$e');
      return null;
    }
  }
}
