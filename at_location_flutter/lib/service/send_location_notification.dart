import 'dart:async';
import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/location_modal/location_data_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'package:geolocator/geolocator.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';
import 'package:at_client/src/service/notification_service.dart';
import 'key_stream_service.dart';

/// [masterSwitchState] will control whether location is sent to any user
///
/// [locationPromptDialog] will be called whenever package is about to send location and [masterSwitchState] is false.
///
/// Make sure that [locationPromptDialog] is a dialog or a function which can ask the user to turn the [masterSwitchState]
/// true if needed.
class SendLocationNotification {
  SendLocationNotification._();
  static final SendLocationNotification _instance =
      SendLocationNotification._();
  factory SendLocationNotification() => _instance;
  Timer? timer;
  final String locationKey = 'locationnotify';
  List<LocationNotificationModel?> atsignsToShareLocationWith = [];
  StreamSubscription<Position>? positionStream;
  bool masterSwitchState = true;
  Function? locationPromptDialog;
  Map<String, LocationDataModel> allAtsignsLocationData = {};
  AtClient? atClient;
  bool isEventInUse = false,
      isLocationDataInitialized = false,
      isEventDataInitialized = false;

  void init(AtClient? newAtClient) {
    if ((timer != null) && (timer!.isActive)) timer!.cancel();
    atClient = newAtClient;
    atsignsToShareLocationWith = [];
    isEventInUse = AtLocationNotificationListener().isEventInUse;
    print(
        'atsignsToShareLocationWith length - ${atsignsToShareLocationWith.length}');
    if (positionStream != null) positionStream!.cancel();
    findAtSignsToShareLocationWith();
  }

  initEventData(List<LocationDataModel> locationDataModel) {
    locationDataModel.forEach((element) {
      if (allAtsignsLocationData[element.receiver] != null) {
        print(
            'allAtsignsLocationData[element.receiver] : ${allAtsignsLocationData[element.receiver]!.locationSharingFor}');
        allAtsignsLocationData[element.receiver]!
            .locationSharingFor
            .addAll(element.locationSharingFor);

        print(
            'allAtsignsLocationData[element.receiver] :  after: ${allAtsignsLocationData[element.receiver]!.locationSharingFor}');
      } else {
        allAtsignsLocationData[element.receiver] = element;
      }
    });

    isEventDataInitialized = true;
    if (isLocationDataInitialized) {
      sendLocation();
    }
  }

  void findAtSignsToShareLocationWith() {
    atsignsToShareLocationWith = [];

    KeyStreamService()
        .allLocationNotifications
        .forEach((KeyLocationModel notification) {
      LocationDataModel locationDataModel = LocationDataModel({
        notification.key!: LocationSharingFor(
            notification.locationNotificationModel!.from!,
            notification.locationNotificationModel!.to!,
            LocationSharingType.P2P)
      },
          0,
          0,
          DateTime.now(),
          AtClientManager.getInstance().atClient.getCurrentAtSign()!,
          notification.locationNotificationModel!.receiver!);

      if (allAtsignsLocationData[locationDataModel.receiver] != null) {
        allAtsignsLocationData[locationDataModel.receiver]!
            .locationSharingFor
            .addAll(locationDataModel.locationSharingFor);
      } else {
        allAtsignsLocationData[locationDataModel.receiver] = locationDataModel;
      }
    });

    print('allAtsignsLocationData : ${allAtsignsLocationData}');
    isLocationDataInitialized = true;
    if ((isEventDataInitialized && isEventInUse) || !isEventInUse) {
      sendLocation();
    }
  }

  void setLocationPrompt(Function _locationPrompt) {
    locationPromptDialog = _locationPrompt;
  }

  void setMasterSwitchState(bool _state) {
    masterSwitchState = _state;
    if (_state) {
      findAtSignsToShareLocationWith();
    } else {
      deleteAllLocationKey();
    }
  }

  Future<void> addMember(LocationDataModel locationDataModel) async {
    var myLocation = await getMyLocation();
    if (myLocation != null) {
      if (masterSwitchState) {
        await prepareLocationDataAndSend(
            locationDataModel.receiver, locationDataModel, myLocation);
      } else {
        /// method from main app
        if (locationPromptDialog != null) {
          initEventData([locationDataModel]);
          locationPromptDialog!();

          /// return as when main switch is turned on, it will send location to all.
          return;
        }
      }
    } else {
      // ignore: unnecessary_null_comparison
      if (AtLocationNotificationListener().navKey != null) {
        CustomToast().show('Location permission not granted',
            AtLocationNotificationListener().navKey.currentContext!,
            isError: true);
      }
    }

    // add
    initEventData([locationDataModel]);
    print(
        'after adding atsignsToShareLocationWith length ${atsignsToShareLocationWith.length}');
  }

  void removeMember(String? key) async {
    LocationNotificationModel? locationNotificationModel;
    atsignsToShareLocationWith.removeWhere((element) {
      if (key!.contains(element!.key!)) locationNotificationModel = element;
      return key.contains(element.key!);
    });
    if (locationNotificationModel != null) {
      await sendNull(locationNotificationModel!);
    }

    print(
        'after deleting atsignsToShareLocationWith length ${atsignsToShareLocationWith.length}');
  }

  void sendLocation() async {
    var permission = await Geolocator.checkPermission();

    if (((permission == LocationPermission.always) ||
        (permission == LocationPermission.whileInUse))) {
      /// The stream doesnt run until 100m is covered
      /// So, we send data once
      var _currentMyLatLng = await getMyLocation();

      if (_currentMyLatLng != null && masterSwitchState) {
        for (var field in allAtsignsLocationData.entries) {
          await prepareLocationDataAndSend(field.key, field.value,
              LatLng(_currentMyLatLng.latitude, _currentMyLatLng.longitude));
        }

        // await Future.forEach(atsignsToShareLocationWith,
        //     (dynamic notification) async {
        //   // ignore: await_only_futures
        //   await prepareLocationDataAndSend(notification,
        //       LatLng(_currentMyLatLng.latitude, _currentMyLatLng.longitude));
        // });
      }

      ///
      positionStream = Geolocator.getPositionStream(distanceFilter: 100)
          .listen((myLocation) async {
        if (masterSwitchState) {
          for (var field in allAtsignsLocationData.entries) {
            await prepareLocationDataAndSend(field.key, field.value,
                LatLng(_currentMyLatLng!.latitude, _currentMyLatLng.longitude));
          }
          // await Future.forEach(atsignsToShareLocationWith,
          //     (dynamic notification) async {
          //   // ignore: unawaited_futures
          //   prepareLocationDataAndSend(notification,
          //       LatLng(myLocation.latitude, myLocation.longitude));
          // });
        }
      });
    }
  }

  Future<void> prepareLocationDataAndSend(String receiver,
      LocationDataModel locationData, LatLng myLocation) async {
    var isSend = true;

    // if (notification.to == null) {
    //   isSend = true;
    // } else if ((DateTime.now().difference(notification.from!) >
    //         Duration(seconds: 0)) &&
    //     (notification.to!.difference(DateTime.now()) > Duration(seconds: 0))) {
    //   isSend = true;
    // }
    if (isSend) {
      // var atkeyMicrosecondId = notification.key!.split('-')[1].split('@')[0];
      var atKey = newAtKey(5000, 'new_location_notify-', receiver, ttl: null);

      locationData.lat = myLocation.latitude;
      locationData.long = myLocation.longitude;

      try {
        print('locationData.toJson() : ${locationData.toJson()}');
        var _res =
            await AtClientManager.getInstance().notificationService.notify(
                  NotificationParams.forUpdate(
                    atKey,
                    value: jsonEncode(locationData.toJson()),
                  ),
                );
        print('send loc data : ${_res}');

        // atClient!.put(
        //   atKey,
        //   LocationNotificationModel.convertLocationNotificationToJson(
        //       newLocationNotificationModel),
        // );
        // print('prepareLocationDataAndSend in location package ========> $_res');
      } catch (e) {
        print('error in sending location: $e');
      }
    }
  }

  Future<bool> sendNull(
      LocationNotificationModel locationNotificationModel) async {
    var atkeyMicrosecondId =
        locationNotificationModel.key!.split('-')[1].split('@')[0];
    var atKey = newAtKey(-1, 'locationnotify-$atkeyMicrosecondId',
        locationNotificationModel.receiver);
    var result = await atClient!.delete(
      atKey,
    );
    print('$atKey delete operation $result');
    if (result) {}
    return result;
  }

  void deleteAllLocationKey() async {
    var response = await atClient?.getKeys(
      regex: '$locationKey',
    );
    await Future.forEach(response ?? [], (dynamic key) async {
      if (!'@$key'.contains('cached')) {
        // the keys i have created
        var atKey = getAtKey(key);
        var result = await atClient!.delete(
          atKey,
        );
        print('$key is deleted ? $result');
      }
    });
  }

  AtKey newAtKey(int ttr, String key, String? sharedWith, {int? ttl}) {
    var atKey = AtKey()
      ..metadata = Metadata()
      ..metadata!.ttr = ttr
      ..metadata!.ccd = true
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = atClient!.getCurrentAtSign();
    if (ttl != null) atKey.metadata!.ttl = ttl;
    return atKey;
  }

  LocationDataModel locationNotificationModelToLocationDataModel(
      LocationNotificationModel locationNotificationModel) {
    return LocationDataModel(
      {
        locationNotificationModel.key!: LocationSharingFor(
            locationNotificationModel.from!,
            locationNotificationModel.to!,
            LocationSharingType.P2P)
      },
      null,
      null,
      DateTime.now(),
      locationNotificationModel.atsignCreator!,
      locationNotificationModel.receiver!,
    );
  }
}
