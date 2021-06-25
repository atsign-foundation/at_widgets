import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:at_location_flutter/service/sync_secondary.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:at_location_flutter/utils/constants/init_location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';

import 'key_stream_service.dart';

class SendLocationNotification {
  SendLocationNotification._();
  static final SendLocationNotification _instance =
      SendLocationNotification._();
  factory SendLocationNotification() => _instance;
  Timer timer;
  final String locationKey = 'locationnotify';
  List<LocationNotificationModel> atsignsToShareLocationWith = [];
  StreamSubscription<Position> positionStream;

  AtClientImpl atClient;

  void init(AtClientImpl newAtClient) {
    if ((timer != null) && (timer.isActive)) timer.cancel();
    atClient = newAtClient;
    atsignsToShareLocationWith = [];
    print(
        'atsignsToShareLocationWith length - ${atsignsToShareLocationWith.length}');
    if (positionStream != null) positionStream.cancel();
    findAtSignsToShareLocationWith();
  }

  void findAtSignsToShareLocationWith() {
    atsignsToShareLocationWith = [];
    KeyStreamService().allLocationNotifications.forEach((notification) {
      if ((notification.locationNotificationModel.atsignCreator ==
              atClient.currentAtSign) &&
          (notification.locationNotificationModel.isSharing) &&
          (notification.locationNotificationModel.isAccepted) &&
          (!notification.locationNotificationModel.isExited)) {
        atsignsToShareLocationWith.add(notification.locationNotificationModel);
      }
    });

    sendLocation();
  }

  Future<void> addMember(LocationNotificationModel notification) async {
    if (atsignsToShareLocationWith
            .indexWhere((element) => element.key == notification.key) >
        -1) {
      return;
    }

    var myLocation = await getMyLocation();
    prepareLocationDataAndSend(notification, myLocation);

    // add
    atsignsToShareLocationWith.add(notification);
    print(
        'after adding atsignsToShareLocationWith length ${atsignsToShareLocationWith.length}');
  }

  void removeMember(String key) async {
    LocationNotificationModel locationNotificationModel;
    atsignsToShareLocationWith.removeWhere((element) {
      if (key.contains(element.key)) locationNotificationModel = element;
      return key.contains(element.key);
    });
    if (locationNotificationModel != null) {
      await sendNull(locationNotificationModel);
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

      await Future.forEach(atsignsToShareLocationWith, (notification) async {
        // ignore: await_only_futures
        await prepareLocationDataAndSend(notification,
            LatLng(_currentMyLatLng.latitude, _currentMyLatLng.longitude));
      });
      if (MixedConstants.isDedicated) {
        // ignore: unawaited_futures
        SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
      }

      ///
      positionStream = Geolocator.getPositionStream(distanceFilter: 100)
          .listen((myLocation) async {
        await Future.forEach(atsignsToShareLocationWith, (notification) async {
          prepareLocationDataAndSend(
              notification, LatLng(myLocation.latitude, myLocation.longitude));
        });
        if (MixedConstants.isDedicated) {
          // ignore: unawaited_futures
          SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
        }
      });
    }
  }

  void prepareLocationDataAndSend(
      LocationNotificationModel notification, LatLng myLocation) async {
    var isSend = false;

    if (notification.to == null) {
      isSend = true;
    } else if ((DateTime.now().difference(notification.from) >
            Duration(seconds: 0)) &&
        (notification.to.difference(DateTime.now()) > Duration(seconds: 0))) {
      isSend = true;
    }
    if (isSend) {
      var atkeyMicrosecondId = notification.key.split('-')[1].split('@')[0];
      var atKey = newAtKey(
          5000, 'locationnotify-$atkeyMicrosecondId', notification.receiver,
          ttl: (notification.to != null)
              ? notification.to.difference(DateTime.now()).inMilliseconds
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
        await atClient.put(
          atKey,
          LocationNotificationModel.convertLocationNotificationToJson(
              newLocationNotificationModel),
          isDedicated: MixedConstants.isDedicated,
        );
      } catch (e) {
        print('error in sending location: $e');
      }
    }
  }

  Future<bool> sendNull(
      LocationNotificationModel locationNotificationModel) async {
    var atkeyMicrosecondId =
        locationNotificationModel.key.split('-')[1].split('@')[0];
    var atKey = newAtKey(-1, 'locationnotify-$atkeyMicrosecondId',
        locationNotificationModel.receiver);
    var result =
        await atClient.delete(atKey, isDedicated: MixedConstants.isDedicated);
    print('$atKey delete operation $result');
    if (result) {
      if (MixedConstants.isDedicated) {
        await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
      }
    }
    return result;
  }

  void deleteAllLocationKey() async {
    var response = await atClient.getKeys(
      regex: '$locationKey',
    );
    await Future.forEach(response, (key) async {
      if (!'@$key'.contains('cached')) {
        // the keys i have created
        var atKey = getAtKey(key);
        var result = await atClient.delete(atKey,
            isDedicated: MixedConstants.isDedicated);
        print('$key is deleted ? $result');
      }
    });

    if (MixedConstants.isDedicated) {
      await SyncSecondary().callSyncSecondary(SyncOperation.syncSecondary);
    }
  }

  AtKey newAtKey(int ttr, String key, String sharedWith, {int ttl}) {
    var atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = ttr
      ..metadata.ccd = true
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = atClient.currentAtSign;
    if (ttl != null) atKey.metadata.ttl = ttl;
    return atKey;
  }
}
