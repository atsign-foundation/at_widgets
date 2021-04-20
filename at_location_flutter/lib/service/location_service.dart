import 'dart:async';
import 'dart:core';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_location_flutter/common_components/build_marker.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/service/master_location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

import 'at_location_notification_listener.dart';
import 'distance_calculate.dart';
import 'my_location.dart';

class LocationService {
  LocationService._();
  static LocationService _instance = LocationService._();
  factory LocationService() => _instance;

  List<String> atsignsToTrack;

  AtClientImpl atClientInstance;

  HybridModel eventData;
  HybridModel myData;
  LatLng etaFrom;
  String textForCenter;
  bool calculateETA, addCurrentUserMarker, isMapInitialized = false;
  Function showToast;
  StreamSubscription<Position> myLocationStream;

  List<HybridModel> hybridUsersList;

  StreamController _atHybridUsersController;
  Stream<List<HybridModel>> get atHybridUsersStream =>
      _atHybridUsersController.stream;
  StreamSink<List<HybridModel>> get atHybridUsersSink =>
      _atHybridUsersController.sink;

  init(List<String> atsignsToTrackFromApp,
      {LatLng etaFrom,
      bool calculateETA,
      bool addCurrentUserMarker,
      String textForCenter,
      Function showToast}) async {
    hybridUsersList = [];
    _atHybridUsersController = StreamController<List<HybridModel>>.broadcast();
    atsignsToTrack = atsignsToTrackFromApp;
    this.etaFrom = etaFrom;
    this.calculateETA = calculateETA;
    this.addCurrentUserMarker = addCurrentUserMarker;
    this.textForCenter = textForCenter;
    this.showToast = showToast;

    // ignore: unawaited_futures
    if (myLocationStream != null) myLocationStream.cancel();

    if (etaFrom != null) addCentreMarker();
    await addMyDetailsToHybridUsersList();

    updateHybridList();
  }

  void dispose() {
    _atHybridUsersController.close();
    isMapInitialized = false;
  }

  mapInitialized() {
    isMapInitialized = true;
  }

  addMyDetailsToHybridUsersList() async {
    String _atsign = AtLocationNotificationListener().currentAtSign;
    LatLng mylatlng = await getMyLocation();
    var _image = await MasterLocationService().getImageOfAtsignNew(_atsign);

    HybridModel _myData = HybridModel(
        displayName: _atsign, latLng: mylatlng, eta: '?', image: _image);

    updateMyLatLng(_myData);

    // if (etaFrom != null) _myData.eta = await _calculateEta(_myData);

    // _myData.marker = buildMarker(_myData, singleMarker: true);

    // myData = _myData;

    // if (addCurrentUserMarker) {
    //   hybridUsersList.add(myData);
    // }
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   _atHybridUsersController.add(hybridUsersList);
    // });
    //
    var permission = await Geolocator.checkPermission();
    if (((permission == LocationPermission.always) ||
        (permission == LocationPermission.whileInUse))) {
      myLocationStream = Geolocator.getPositionStream(distanceFilter: 10)
          .listen((myLocation) async {
        var mylatlng = LatLng(myLocation.latitude, myLocation.longitude);

        _myData = HybridModel(
            displayName: _atsign, latLng: mylatlng, eta: '?', image: _image);

        updateMyLatLng(_myData);
      });
    }
  }

  updateMyLatLng(HybridModel _myData) async {
    if (etaFrom != null) _myData.eta = await _calculateEta(_myData);

    _myData.marker = buildMarker(_myData, singleMarker: true);

    myData = _myData;

    if (addCurrentUserMarker) {
      hybridUsersList.add(myData);
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _atHybridUsersController.add(hybridUsersList);
    });
  }

  addCentreMarker() {
    HybridModel centreMarker = HybridModel(
        displayName: textForCenter, latLng: etaFrom, eta: '', image: null);
    centreMarker.marker = buildMarker(centreMarker);

    Future.delayed(
        const Duration(seconds: 2), () => hybridUsersList.add(centreMarker));
  }

  // called for the first time pckage is entered from main app
  updateHybridList() async {
    await Future.forEach(MasterLocationService().allReceivedUsersList,
        (user) async {
      if (atsignsToTrack.contains(user.displayName)) await updateDetails(user);
    });

    if (hybridUsersList.isNotEmpty) {
      Future.delayed(const Duration(seconds: 2),
          () => _atHybridUsersController.add(hybridUsersList));
    }
  }

  // called when any new/updated data is received in the main app
  newList() async {
    if (atsignsToTrack != null) {
      await Future.forEach(MasterLocationService().allReceivedUsersList,
          (user) async {
        if (atsignsToTrack.contains(user.displayName)) {
          await updateDetails(user);
        }
      });

      if (!_atHybridUsersController.isClosed) {
        _atHybridUsersController.add(hybridUsersList);
      }
    }
  }

  // called when a user stops sharing his location
  removeUser(String atsign) {
    if ((atsignsToTrack != null) && (hybridUsersList.isNotEmpty)) {
      hybridUsersList.removeWhere((element) => element.displayName == atsign);
      if (!_atHybridUsersController.isClosed) {
        _atHybridUsersController.add(hybridUsersList);
      }
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
      await addDetails(user, index: index);
    } else {
      await addDetails(user);
    }
  }

  // returns new marker and eta
  addDetails(HybridModel user, {int index}) async {
    try {
      user.marker = buildMarker(user);
      var _eta = await _calculateEta(user);
      user.eta = _eta;
      if ((index != null)) {
        if ((index < hybridUsersList.length)) hybridUsersList[index] = user;
      } else {
        bool _continue = true;
        hybridUsersList.forEach((hybridUser) {
          if (hybridUser.displayName == user.displayName) {
            hybridUser = user;
            _continue = false;
            return;
          }
        });
        if (_continue) {
          hybridUsersList.add(user);
          if (showToast != null) {
            showToast('${user.displayName} started sharing their location');
          }
        }
      }
    } catch (e) {
      print(e);
      if (showToast != null) showToast('Something went wrong');
    }
  }

  _calculateEta(HybridModel user) async {
    if (calculateETA) {
      try {
        var _res;
        if (etaFrom != null) {
          _res = await DistanceCalculate().calculateETA(etaFrom, user.latLng);
        } else {
          LatLng mylatlng;
          if (myData != null) {
            mylatlng = myData.latLng;
          } else {
            mylatlng = await getMyLocation();
          }
          _res = await DistanceCalculate().calculateETA(mylatlng, user.latLng);
        }

        return _res;
      } catch (e) {
        print('Error in _calculateEta $e');
        return '?';
      }
    } else {
      return '?';
    }
  }

  notifyListeners() {
    if (hybridUsersList.isNotEmpty) {
      _atHybridUsersController.add(hybridUsersList);
    }
  }
}
