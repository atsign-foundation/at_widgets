import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_location_flutter/common_components/custom_toast.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'package:geolocator/geolocator.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:latlong2/latlong.dart';

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

  AtClient? atClient;

  void init(AtClient? newAtClient) {
    if ((timer != null) && (timer!.isActive)) timer!.cancel();
    atClient = newAtClient;
    atsignsToShareLocationWith = [];
    print(
        'atsignsToShareLocationWith length - ${atsignsToShareLocationWith.length}');
    if (positionStream != null) positionStream!.cancel();
    findAtSignsToShareLocationWith();
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

  void findAtSignsToShareLocationWith() {
    atsignsToShareLocationWith = [];
    KeyStreamService().allLocationNotifications.forEach((notification) {
      if ((notification.locationNotificationModel!.atsignCreator ==
              atClient!.getCurrentAtSign()) &&
          (notification.locationNotificationModel!.isSharing) &&
          (notification.locationNotificationModel!.isAccepted) &&
          (!notification.locationNotificationModel!.isExited)) {
        atsignsToShareLocationWith.add(notification.locationNotificationModel);
      }
    });

    sendLocation();
  }

  Future<void> addMember(LocationNotificationModel? notification) async {
    if (atsignsToShareLocationWith
            .indexWhere((element) => element!.key == notification!.key) >
        -1) {
      return;
    }

    var myLocation = await getMyLocation();
    if (myLocation != null) {
      if (masterSwitchState) {
        await prepareLocationDataAndSend(notification!, myLocation);
      } else {
        /// method from main app
        if (locationPromptDialog != null) {
          atsignsToShareLocationWith.add(notification);
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
    atsignsToShareLocationWith.add(notification);
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
        await Future.forEach(atsignsToShareLocationWith,
            (dynamic notification) async {
          // ignore: await_only_futures
          await prepareLocationDataAndSend(notification,
              LatLng(_currentMyLatLng.latitude, _currentMyLatLng.longitude));
        });
      }

      ///
      positionStream = Geolocator.getPositionStream(distanceFilter: 100)
          .listen((myLocation) async {
        if (masterSwitchState) {
          await Future.forEach(atsignsToShareLocationWith,
              (dynamic notification) async {
            // ignore: unawaited_futures
            prepareLocationDataAndSend(notification,
                LatLng(myLocation.latitude, myLocation.longitude));
          });
        }
      });
    }
  }

  Future<void> prepareLocationDataAndSend(
      LocationNotificationModel notification, LatLng myLocation) async {
    var isSend = false;

    if (notification.to == null) {
      isSend = true;
    } else if ((DateTime.now().difference(notification.from!) >
            Duration(seconds: 0)) &&
        (notification.to!.difference(DateTime.now()) > Duration(seconds: 0))) {
      isSend = true;
    }
    if (isSend) {
      var atkeyMicrosecondId = notification.key!.split('-')[1].split('@')[0];
      var atKey = newAtKey(
          5000, 'locationnotify-$atkeyMicrosecondId', notification.receiver,
          ttl: (notification.to != null)
              ? notification.to!.difference(DateTime.now()).inMilliseconds
              : null);

      var newLocationNotificationModel = LocationNotificationModel()
        ..atsignCreator = notification.atsignCreator
        ..receiver = notification.receiver
        ..isAccepted = notification.isAccepted
        ..isAcknowledgment = notification.isAcknowledgment
        ..isExited = notification.isExited
        ..isRequest = notification.isRequest
        ..isSharing = notification.isSharing
        ..from = DateTime.now()
        ..to = notification.to
        ..lat = myLocation.latitude
        ..long = myLocation.longitude
        ..key = 'locationnotify-$atkeyMicrosecondId';
      try {
        var _res = await atClient!.put(
          atKey,
          LocationNotificationModel.convertLocationNotificationToJson(
              newLocationNotificationModel),
        );
        print('prepareLocationDataAndSend in location package ========> $_res');
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
    var response = await atClient!.getKeys(
      regex: '$locationKey',
    );
    await Future.forEach(response, (dynamic key) async {
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
}
