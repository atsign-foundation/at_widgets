import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_location_flutter/common_components/build_marker.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:latlong/latlong.dart';

import 'location_service.dart';

class MasterLocationService {
  MasterLocationService._();
  static final MasterLocationService _instance = MasterLocationService._();
  factory MasterLocationService() => _instance;
  AtClientImpl atClientInstance;

  String currentAtSign;
  List<HybridModel> allReceivedUsersList;
  List<KeyModel> allLocationNotifications = [];
  final String locationKey = 'locationnotify';
  StreamController _allReceivedUsersController;
  Stream<List<HybridModel>> get allReceivedUsersStream =>
      _allReceivedUsersController.stream;
  StreamSink<List<HybridModel>> get allReceivedUsersSink =>
      _allReceivedUsersController.sink;

  init(
    String currentAtSignFromApp,
    AtClientImpl atClientInstanceFromApp,
  ) {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    allReceivedUsersList = [];
    _allReceivedUsersController =
        StreamController<List<HybridModel>>.broadcast();
    // get all 'locationnotify' data shared with us
    // getAllLocationData();
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

    response.forEach((key) async {
      if ('@$key'.contains('cached')) {
        print('cached key $key');
        AtKey atKey = AtKey.fromString(key);
        AtValue value = await getAtValue(atKey);
        if (value != null) {
          print('at value location $value');
          KeyModel tempKeyModel =
              KeyModel(key: key, atKey: atKey, atValue: value);
          allLocationNotifications.add(tempKeyModel);
        }
      }
    });

    print('allLocationNotifications AtValue $allLocationNotifications');
    convertJsonToLocationModel();
    filterData();

    createHybridFromKeyModel();
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
    List<KeyModel> tempArray = [];
    for (int i = 0; i < allLocationNotifications.length; i++) {
      if ((allLocationNotifications[i].locationNotificationModel == 'null') ||
          (allLocationNotifications[i].locationNotificationModel == null))
        tempArray.add(allLocationNotifications[i]);
    }
    allLocationNotifications
        .removeWhere((element) => tempArray.contains(element));
  }

  createHybridFromKeyModel() {
    allLocationNotifications.forEach((keyModel) async {
      var _image = await getImageOfAtsignNew(
          keyModel.locationNotificationModel.atsignCreator);
      HybridModel user = HybridModel(
          displayName: keyModel.locationNotificationModel.atsignCreator,
          latLng: keyModel.locationNotificationModel.getLatLng,
          image: _image,
          eta: '?');
      allReceivedUsersList.add(user);
    });
    allReceivedUsersSink.add(allReceivedUsersList);
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
    try {
      AtValue atvalue = await atClientInstance.get(key).catchError(
          (e) => print("error in get ${e.errorCode} ${e.errorMessage}"));

      if (atvalue != null)
        return atvalue;
      else
        return null;
    } catch (e) {
      print('getAtValue:$e');
      return null;
    }
  }
}

class KeyModel {
  String key;
  AtKey atKey;
  AtValue atValue;
  LocationNotificationModel locationNotificationModel;
  KeyModel(
      {this.key, this.atKey, this.atValue, this.locationNotificationModel});
}
