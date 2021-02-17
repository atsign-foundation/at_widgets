import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

import 'key_stream_service.dart';

class SendLocationNotification {
  SendLocationNotification._();
  static SendLocationNotification _instance = SendLocationNotification._();
  factory SendLocationNotification() => _instance;
  Timer timer;
  final String locationKey = 'locationnotify';
  List<LocationNotificationModel> atsignsToShareLocationWith = [];

  AtClientImpl atClient;

  init(AtClientImpl newAtClient) {
    if ((timer != null) && (timer.isActive)) timer.cancel();
    atClient = newAtClient;
    atsignsToShareLocationWith = [];
    //Location().changeSettings(interval: 10);
    print(
        'atsignsToShareLocationWith length - ${atsignsToShareLocationWith.length}');
    findAtSignsToShareLocationWith();
  }

  findAtSignsToShareLocationWith() {
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

  sendLocation() async {
    LatLng myLocation = await MyLocation().myLocation();
    if (atsignsToShareLocationWith.length > 0)
      // Location().onLocationChanged.listen((event) {});
      atsignsToShareLocationWith.forEach((notification) async {
        bool isSend = false;

        if (notification.to == null)
          isSend = true;
        else if ((DateTime.now().difference(notification.from) >
                Duration(seconds: 0)) &&
            (notification.to.difference(DateTime.now()) > Duration(seconds: 0)))
          isSend = true;
        if (isSend) {
          String atkeyMicrosecondId =
              notification.key.split('-')[1].split('@')[0];
          AtKey atKey = newAtKey(
              5000, "locationnotify-$atkeyMicrosecondId", notification.receiver,
              ttl: (notification.to != null)
                  ? notification.to.difference(DateTime.now()).inMilliseconds
                  : null);

          LocationNotificationModel newLocationNotificationModel =
              LocationNotificationModel()
                ..atsignCreator = notification.atsignCreator
                ..receiver = notification.receiver
                ..isAccepted = notification.isAccepted
                ..isAcknowledgment = notification.isAcknowledgment
                ..isExited = notification.isExited
                ..isRequest = notification.isRequest
                ..isSharing = notification.isSharing
                ..from = DateTime.now()
                ..to = notification.to != null ? notification.to : null
                ..lat = myLocation.latitude
                ..long = myLocation.longitude
                ..key = "locationnotify-$atkeyMicrosecondId";
          try {
            var result = await atClient.put(
                atKey,
                LocationNotificationModel.convertLocationNotificationToJson(
                    newLocationNotificationModel));
          } catch (e) {
            print('error in sending location: $e');
          }
        }
      });
    myLocation = await MyLocation().myLocation();
  }

  sendNull(LocationNotificationModel locationNotificationModel) async {
    String atkeyMicrosecondId =
        locationNotificationModel.key.split('-')[1].split('@')[0];
    AtKey atKey = newAtKey(5000, "locationnotify-$atkeyMicrosecondId",
        locationNotificationModel.receiver);
    var result = await atClient.delete(atKey);
    print('$atKey delete operation $result');
    return result;
  }

  deleteAllLocationKey() async {
    List<String> response = await atClient.getKeys(
      regex: '$locationKey',
    );
    response.forEach((key) async {
      if (!'@$key'.contains('cached')) {
        // the keys i have created
        AtKey atKey = AtKey.fromString(key);
        var result = await atClient.delete(atKey);
        print('$key is deleted ? $result');
      }
    });
  }

  AtKey newAtKey(int ttr, String key, String sharedWith, {int ttl}) {
    AtKey atKey = AtKey()
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
