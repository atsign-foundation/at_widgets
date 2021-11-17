import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/location_modal/location_data_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';

import 'contact_service.dart';
import 'location_service.dart';

class MasterLocationService {
  MasterLocationService._();
  static final MasterLocationService _instance = MasterLocationService._();
  factory MasterLocationService() => _instance;
  late AtClient atClientInstance;
  late Function getAtValueFromMainApp;

  String? currentAtSign;
  Map<String, HybridModel> _allReceivedUsersList = {};
  Map<String, LocationDataModel> _locationReceivedData = {};

  Map<String, LocationDataModel> get locationReceivedData =>
      _locationReceivedData;

  final String locationKey = 'locationnotify';

  StreamController _allReceivedUsersController =
      StreamController<Map<String, HybridModel>>.broadcast();
  Stream<Map<String, HybridModel>> get allReceivedUsersStream =>
      _allReceivedUsersController.stream as Stream<Map<String, HybridModel>>;
  StreamSink<Map<String, HybridModel>> get allReceivedUsersSink =>
      _allReceivedUsersController.sink as StreamSink<Map<String, HybridModel>>;

  //   Steps:
  //// locationReceivedData will contain locationDataModel for atsigns
  ///       {'atsign': locationDataModel}
  ///  And for each user (atsign) we will store their HybridModel in _allReceivedUsersList
  ///       {'atsign': HybridModel}
  ///  when we want the location of a user we will query in the _locationReceivedData map
  ///  with the atsign and event/p2p id
  ///  if the atsign is present
  ///  then we will look into locationSharingFor value of the _locationReceivedData['atsign']
  ///  if the event/p2p id is present in locationSharingFor value
  ///  and DateTime.now() is between from and to of the locationSharingFor value
  ///  then we will return the HybridModel of the atsign in _allReceivedUsersList

  HybridModel? getHybridModel(String atsign, {String? id}) {
    if (id != null) {
      if ((_locationReceivedData[atsign] != null) &&
          (_locationReceivedData[atsign]!.locationSharingFor[id] != null)) {
        var _locationSharingFor =
            _locationReceivedData[atsign]!.locationSharingFor[id];
        if ((_locationSharingFor!.from != null &&
                _locationSharingFor.to != null) &&
            (DateTime.now().isAfter(_locationSharingFor!.from!)) &&
            (DateTime.now().isBefore(_locationSharingFor.to!))) {
          return _allReceivedUsersList[atsign];
        }
      }

      return null;
    } else {
      /// for calls that don't pass an id (dont need data specific to any event/p2p)
      return _allReceivedUsersList[atsign];
    }
  }

  void init(String currentAtSignFromApp, AtClient atClientInstanceFromApp,
      {Function? newGetAtValueFromMainApp}) {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    _allReceivedUsersList = {};
    _allReceivedUsersController =
        StreamController<Map<String, HybridModel>>.broadcast();

    if (newGetAtValueFromMainApp != null) {
      getAtValueFromMainApp = newGetAtValueFromMainApp;
    } else {
      getAtValueFromMainApp = getAtValue;
    }

    getAllLocationData();
  }

  /// get all 'locationnotify' data shared with us
  Future<void> getAllLocationData() async {
    var response = await atClientInstance.getKeys(
      regex: locationKey,
    );
    if (response.isEmpty) {
      return;
    }

    await Future.forEach(response, (dynamic key) async {
      if ('@$key'.contains('cached')) {
        var atKey = getAtKey(key);
        AtValue? _atValue = await getAtValueFromMainApp(atKey);
        if (_atValue != null) {
          // var _locationDataModel =
          //     LocationDataModel.fromJson(jsonDecode(_atValue.value));
          var _locationDataModel = LocationDataModel(
              {}, 22, 22, DateTime.now(), '@new52plum', '@26juststay');
          _locationReceivedData[_locationDataModel.sender] = _locationDataModel;
        }
      }
    });

    //// for demo
    // var _locationDataModel = LocationDataModel(
    //   {},
    //   22,
    //   22,
    //   DateTime.now(),
    //   '@new52plum',
    //   '@26juststay',
    // );
    // _locationReceivedData[_locationDataModel.sender] = _locationDataModel;

    ///demo

    createHybridFromLocationDataModel();
  }

  void createHybridFromLocationDataModel() async {
    await Future.forEach(_locationReceivedData.entries,
        (MapEntry<String, LocationDataModel> _locationData) async {
      var _image = await getImageOfAtsignNew(_locationData.value.sender);
      var _user = HybridModel(
          displayName: _locationData.value.sender,
          latLng: _locationData.value.getLatLng,
          image: _image,
          eta: '?');

      _allReceivedUsersList[_locationData.key] = _user;
    });
    allReceivedUsersSink.add(_allReceivedUsersList);
  }

  void updateHybridList(LocationDataModel _newUser) async {
    var contains = _allReceivedUsersList[_newUser.sender] != null;

    if (!contains) {
      print('!contains from main app');
      var _image = await getImageOfAtsignNew(_newUser.sender);

      var _user = HybridModel(
          displayName: _newUser.sender,
          latLng: _newUser.getLatLng,
          image: _image,
          eta: '?');

      _allReceivedUsersList[_newUser.sender] = _user;
      _allReceivedUsersController.add(_allReceivedUsersList);
      allReceivedUsersSink.add(_allReceivedUsersList);
      LocationService().newList(_newUser.sender);
    } else {
      print('contains from main app');

      _allReceivedUsersList[_newUser.sender]!.latLng = _newUser.getLatLng;
      _allReceivedUsersList[_newUser.sender]!.eta = '?';
      _allReceivedUsersController.add(_allReceivedUsersList);
      allReceivedUsersSink.add(_allReceivedUsersList);
      LocationService().newList(_newUser.sender);
    }
  }

  void deleteReceivedData(String atsign) {
    _allReceivedUsersList.remove(atsign);
    LocationService().removeUser(atsign);
    allReceivedUsersSink.add(_allReceivedUsersList);
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
    print(atClientInstance.getCurrentAtSign());
    try {
      var atvalue = await atClientInstance.get(key).catchError(
          // ignore: return_of_invalid_type_from_catch_error
          (e) => print('error in getAtValue in master location service : $e'));

      // ignore: unnecessary_null_comparison
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
