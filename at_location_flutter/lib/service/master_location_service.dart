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
import 'package:latlong2/latlong.dart';

import 'contact_service.dart';
import 'location_service.dart';

class MasterLocationService {
  MasterLocationService._();
  static final MasterLocationService _instance = MasterLocationService._();
  factory MasterLocationService() => _instance;
  late AtClientImpl atClientInstance;
  late Function getAtValueFromMainApp;

  String? currentAtSign;
  List<HybridModel>? allReceivedUsersList;
  List<KeyLocationModel> allLocationNotifications = <KeyLocationModel>[];

  final String locationKey = 'locationnotify';

  late StreamController<List<HybridModel>?> _allReceivedUsersController;
  Stream<List<HybridModel>?> get allReceivedUsersStream => _allReceivedUsersController.stream;
  StreamSink<List<HybridModel>?> get allReceivedUsersSink => _allReceivedUsersController.sink;

  void init(String currentAtSignFromApp, AtClientImpl atClientInstanceFromApp, {Function? newGetAtValueFromMainApp}) {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    allReceivedUsersList = <HybridModel>[];
    _allReceivedUsersController = StreamController<List<HybridModel>?>.broadcast();

    if (newGetAtValueFromMainApp != null) {
      getAtValueFromMainApp = newGetAtValueFromMainApp;
    } else {
      getAtValueFromMainApp = getAtValue;
    }

    getAllLocationData();
  }

  /// get all 'locationnotify' data shared with us
  Future<void> getAllLocationData() async {
    List<String> response = await atClientInstance.getKeys(
      regex: locationKey,
    );
    if (response.isEmpty) {
      return;
    }

    await Future.forEach(response, (dynamic key) async {
      if ('@$key'.contains('cached')) {
        AtKey atKey = getAtKey(key);
        AtValue? value = await getAtValueFromMainApp(atKey);
        if (value != null) {
          KeyLocationModel tempKeyLocationModel = KeyLocationModel(key: key, atKey: atKey, atValue: value);
          allLocationNotifications.add(tempKeyLocationModel);
        }
      }
    });

    convertJsonToLocationModel();
    filterData();

    await createHybridFromKeyLocationModel();
  }

  void convertJsonToLocationModel() {
    for (int i = 0; i < allLocationNotifications.length; i++) {
      try {
        if ((allLocationNotifications[i].atValue!.value != null) &&
            (allLocationNotifications[i].atValue!.value != 'null')) {
          LocationNotificationModel locationNotificationModel =
              LocationNotificationModel.fromJson(jsonDecode(allLocationNotifications[i].atValue!.value));
          allLocationNotifications[i].locationNotificationModel = locationNotificationModel;
        }
      } catch (e) {
        print('error in convertJsonToLocationModel:$e');
      }
    }
  }

  void filterData() {
    List<KeyLocationModel> tempArray = <KeyLocationModel>[];
    for (int i = 0; i < allLocationNotifications.length; i++) {
      if ((allLocationNotifications[i].locationNotificationModel.toString() == 'null') ||
          (allLocationNotifications[i].locationNotificationModel == null) ||
          ((allLocationNotifications[i].locationNotificationModel!.to != null) &&
              (allLocationNotifications[i].locationNotificationModel!.to!.difference(DateTime.now()).inMinutes < 0))) {
        tempArray.add(allLocationNotifications[i]);
      }
    }

    allLocationNotifications.removeWhere((KeyLocationModel element) => tempArray.contains(element));
  }

  Future<void> createHybridFromKeyLocationModel() async {
    await Future.forEach(allLocationNotifications, (dynamic keyLocationModel) async {
      Uint8List? _image = await getImageOfAtsignNew(keyLocationModel.locationNotificationModel.atsignCreator);
      HybridModel user = HybridModel(
          displayName: keyLocationModel.locationNotificationModel.atsignCreator,
          latLng: keyLocationModel.locationNotificationModel.getLatLng,
          image: _image,
          eta: '?');

      allReceivedUsersList!.add(user);
    });
    allReceivedUsersSink.add(allReceivedUsersList);
  }

  Future<void> updateHybridList(LocationNotificationModel newUser) async {
    bool contains = false;
    late int index;
    for (HybridModel user in allReceivedUsersList!) {
      if (user.displayName == newUser.atsignCreator) {
        contains = true;
        index = allReceivedUsersList!.indexOf(user);
      }
    }
    if (!contains) {
      if (newUser.getLatLng != LatLng(0, 0)) {
        print('!contains from main app');
        String? atsign = newUser.atsignCreator;
        LatLng _latlng = newUser.getLatLng;
        Uint8List? _image = await getImageOfAtsignNew(atsign);

        HybridModel user = HybridModel(displayName: newUser.atsignCreator, latLng: _latlng, image: _image, eta: '?');

        allReceivedUsersList!.add(user);
        _allReceivedUsersController.add(allReceivedUsersList);
        allReceivedUsersSink.add(allReceivedUsersList);
        await LocationService().newList();
      }
    } else {
      print('contains from main app');

      allReceivedUsersList![index].latLng = newUser.getLatLng;
      allReceivedUsersList![index].eta = '?';
      _allReceivedUsersController.add(allReceivedUsersList);
      allReceivedUsersSink.add(allReceivedUsersList);
      await LocationService().newList();
    }
  }

  void deleteReceivedData(String? atsign) {
    allReceivedUsersList!.removeWhere((HybridModel element) => element.displayName == atsign);
    LocationService().removeUser(atsign);
    allReceivedUsersSink.add(allReceivedUsersList);
  }

  Future<Uint8List?> getImageOfAtsignNew(String? atsign) async {
    try {
      AtContact contact;
      Uint8List? image;
      contact = await getAtSignDetails(atsign);

      // ignore: unnecessary_null_comparison
      if (contact != null) {
        if (contact.tags != null && contact.tags!['image'] != null) {
          List<int> intList = contact.tags!['image'].cast<int>();
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
      AtValue atvalue = await atClientInstance.get(key).catchError((dynamic e) {
        print('error in getAtValue in master location service : $e');
      });

      if (atvalue.toString() != 'null') {
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
