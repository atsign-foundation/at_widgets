import 'dart:async';
import 'dart:core';
import 'dart:typed_data';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_location_flutter/common_components/build_marker.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/service/master_location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';

import 'at_location_notification_listener.dart';
import 'distance_calculate.dart';
import 'my_location.dart';

class LocationService {
  LocationService._();
  static final LocationService _instance = LocationService._();
  factory LocationService() => _instance;

  List<String?>? atsignsToTrack;

  AtClientImpl? atClientInstance;

  HybridModel? eventData;
  HybridModel? myData;
  LatLng? etaFrom;
  String? textForCenter;
  bool? calculateETA, addCurrentUserMarker, isMapInitialized = false;
  Function? showToast;
  StreamSubscription<Position>? myLocationStream;

  List<HybridModel?> hybridUsersList = <HybridModel?>[];

  late StreamController<List<HybridModel?>> _atHybridUsersController = StreamController<List<HybridModel?>>.broadcast();
  Stream<List<HybridModel?>> get atHybridUsersStream => _atHybridUsersController.stream;
  StreamSink<List<HybridModel?>> get atHybridUsersSink => _atHybridUsersController.sink;

  Future<void> init(List<String?>? atsignsToTrackFromApp,
      {LatLng? etaFrom,
      bool? calculateETA,
      bool? addCurrentUserMarker,
      String? textForCenter,
      Function? showToast}) async {
    hybridUsersList = <HybridModel?>[];
    _atHybridUsersController = StreamController<List<HybridModel?>>.broadcast();
    atsignsToTrack = atsignsToTrackFromApp;
    this.etaFrom = etaFrom;
    this.calculateETA = calculateETA;
    this.addCurrentUserMarker = addCurrentUserMarker;
    this.textForCenter = textForCenter;
    this.showToast = showToast;

    // ignore: unawaited_futures
    if (myLocationStream != null) myLocationStream!.cancel();

    if (etaFrom != null) addCentreMarker();
    await addMyDetailsToHybridUsersList();

    await updateHybridList();
  }

  void dispose() {
    _atHybridUsersController.close();
    myLocationStream?.cancel();
    isMapInitialized = false;
  }

  void mapInitialized() {
    isMapInitialized = true;
  }

  Future<void> addMyDetailsToHybridUsersList() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (((permission == LocationPermission.always) || (permission == LocationPermission.whileInUse))) {
      String? _atsign = AtLocationNotificationListener().currentAtSign;
      LatLng? mylatlng = await getMyLocation();
      Uint8List? _image = await MasterLocationService().getImageOfAtsignNew(_atsign);

      HybridModel _myData = HybridModel(displayName: _atsign, latLng: mylatlng, eta: '?', image: _image);

      await updateMyLatLng(_myData);

      myLocationStream = Geolocator.getPositionStream(distanceFilter: 10).listen((Position myLocation) async {
        LatLng mylatlng = LatLng(myLocation.latitude, myLocation.longitude);

        _myData = HybridModel(displayName: _atsign, latLng: mylatlng, eta: '?', image: _image);

        await updateMyLatLng(_myData);
      });
    } else {
      if (AtLocationNotificationListener().navKey.toString() != 'null') {
        CustomToast().show('Location permission not granted', AtLocationNotificationListener().navKey.currentContext!);
      }
    }
  }

  Future<void> updateMyLatLng(HybridModel _myData) async {
    if (etaFrom != null) {
      _myData.eta = await _calculateEta(_myData);
    }

    _myData.marker = buildMarker(_myData, singleMarker: true);

    myData = _myData;

    int _index =
        hybridUsersList.indexWhere((HybridModel? element) => element!.displayName == AtLocationNotificationListener().currentAtSign);

    if (_index < 0) {
      if (addCurrentUserMarker!) {
        hybridUsersList.add(myData);
      }
    } else {
      hybridUsersList[_index] = myData;
    }

    WidgetsBinding.instance!.addPostFrameCallback((Duration timeStamp) {
      if (!_atHybridUsersController.isClosed) {
        _atHybridUsersController.add(hybridUsersList);
      }
    });
  }

  void addCentreMarker() {
    HybridModel centreMarker = HybridModel(displayName: textForCenter, latLng: etaFrom, eta: '', image: null);
    centreMarker.marker = buildMarker(centreMarker);

    Future<dynamic>.delayed(const Duration(seconds: 2), () => hybridUsersList.add(centreMarker));
  }

  /// called for the first time pckage is entered from main app
  Future<void> updateHybridList() async {
    await Future.forEach(MasterLocationService().allReceivedUsersList!, (dynamic user) async {
      if (atsignsToTrack!.contains(user.displayName)) await updateDetails(user);
    });

    if (hybridUsersList.isNotEmpty) {
      Future<dynamic>.delayed(const Duration(seconds: 2), () => _atHybridUsersController.add(hybridUsersList));
    }
  }

  /// called when any new/updated data is received in the main app
  Future<void> newList() async {
    if (atsignsToTrack != null) {
      await Future.forEach(MasterLocationService().allReceivedUsersList!, (dynamic user) async {
        if (atsignsToTrack!.contains(user.displayName)) {
          await updateDetails(user);
        }
      });

      if (!_atHybridUsersController.isClosed) {
        _atHybridUsersController.add(hybridUsersList);
      }
    }
  }

  /// called when a user stops sharing his location
  void removeUser(String? atsign) {
    if ((atsignsToTrack != null) && (hybridUsersList.isNotEmpty)) {
      hybridUsersList.removeWhere((HybridModel? element) => element!.displayName == atsign);
      if (!_atHybridUsersController.isClosed) {
        _atHybridUsersController.add(hybridUsersList);
      }
    }
  }

  /// called to get the new details marker & eta
  Future<void> updateDetails(HybridModel user) async {
    bool contains = false;
    int? index;
    for(HybridModel? hybridUser in hybridUsersList) {
      if (hybridUser!.displayName == user.displayName) {
        contains = true;
        index = hybridUsersList.indexOf(hybridUser);
      }
    }
    if (contains) {
      await addDetails(user, index: index);
    } else {
      await addDetails(user);
    }
  }

  /// returns new marker and eta
  Future<void> addDetails(HybridModel user, {int? index}) async {
    try {
      user.marker = buildMarker(user);
      String _eta = await _calculateEta(user);
      user.eta = _eta;
      if ((index != null)) {
        if ((index < hybridUsersList.length)) hybridUsersList[index] = user;
      } else {
        bool _continue = true;
        for(HybridModel? hybridUser in hybridUsersList) {
          if (hybridUser!.displayName == user.displayName) {
            hybridUser = user;
            _continue = false;
            return;
          }
        }
        if (_continue) {
          hybridUsersList.add(user);
          if (showToast != null) {
            showToast!('${user.displayName} started sharing their location');
          }
        }
      }
    } catch (e) {
      print(e);
      if (showToast != null) showToast!('Something went wrong');
    }
  }

  Future<String> _calculateEta(HybridModel user) async {
    if (calculateETA!) {
      try {
        String _res;
        if (etaFrom != null) {
          _res = await DistanceCalculate().calculateETA(etaFrom!, user.latLng!);
        } else {
          LatLng? mylatlng;
          if (myData != null) {
            mylatlng = myData!.latLng;
          } else {
            mylatlng = await getMyLocation();
          }
          _res = await DistanceCalculate().calculateETA(mylatlng!, user.latLng!);
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

  void notifyListeners() {
    if (hybridUsersList.isNotEmpty) {
      _atHybridUsersController.add(hybridUsersList);
    }
  }
}
