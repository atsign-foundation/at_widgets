import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

class SendLocationNotification {
  SendLocationNotification._();
  static SendLocationNotification _instance = SendLocationNotification._();
  factory SendLocationNotification() => _instance;
  Timer timer;

  List<LocationNotificationModel> receivingAtsigns;

  AtClientImpl atClient;

  init(List<LocationNotificationModel> atsigns, AtClientImpl newAtClient) {
    if ((timer != null) && (timer.isActive)) timer.cancel();

    receivingAtsigns = atsigns;
    atClient = newAtClient;
    //Location().changeSettings(interval: 10);
    print('receivingAtsigns length - ${receivingAtsigns.length}');
    updateMyLocation2();
    // manualLocationSend();
  }

  updateMyLocation() async {
    Location().onLocationChanged.listen((event) {
      print('listening event:${event}');
      receivingAtsigns.forEach((notification) async {
        if ((DateTime.now().difference(notification.from) >
                Duration(seconds: 0)) &&
            (notification.to.difference(DateTime.now()) >
                Duration(seconds: 0))) {
          print('inside forEach');

          notification.lat = event.latitude;
          notification.long = event.longitude;
          AtKey atKey = newAtKey(-1, notification.key, notification.receiver);
          try {
            var result = await atClient.put(
                atKey,
                LocationNotificationModel.convertLocationNotificationToJson(
                    notification));
            print('location sent:${result}');
          } catch (e) {
            print('error in sending location: $e');
          }
        }
      });
      print('completed 1 round');
    });
  }

// error
// SEVERE|2021-01-28 14:25:33.371574|AtClientImpl|error in put: FormatException: Invalid radix-10 number (at character 2)
//  [{"id"
  updateMyLocation2() async {
    LatLng myLocation = await MyLocation().myLocation();
    // LatLng myLocation = LatLng(lat, long);
    if (receivingAtsigns.length > 0)
      // timer = Timer.periodic(Duration(seconds: 10), (Timer t) async {

      receivingAtsigns.forEach((notification) async {
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
    // myLocation = LatLng(44, -112);
    // });
  }

  manualLocationSend() {
    // LatLng myLocation = LatLng(lat, long);
    LatLng myLocation;
    if (myLocation == null)
      switch (atClient.currentAtSign) {
        case '@ashish🛠':
          {
            myLocation = LatLng(38, -122.406417);
            break;
          }
        case '@colin🛠':
          {
            myLocation = LatLng(39, -122.406417);
            break;
          }
        case '@bob🛠':
          {
            myLocation = LatLng(40, -122.406417);
            break;
          }
      }

    if (receivingAtsigns.length > 0)
      timer = Timer.periodic(Duration(seconds: 5), (Timer t) async {
        receivingAtsigns.forEach((notification) async {
          if (true) {
            String atkeyMicrosecondId =
                notification.key.split('-')[1].split('@')[0];
            AtKey atKey = newAtKey(5000, "locationnotify-$atkeyMicrosecondId",
                notification.receiver,
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
        myLocation.latitude = myLocation.latitude + 0.01;
      });
  }

  sendNull(LocationNotificationModel locationNotificationModel) async {
    String atkeyMicrosecondId =
        locationNotificationModel.key.split('-')[1].split('@')[0];
    AtKey atKey = newAtKey(5000, "locationnotify-$atkeyMicrosecondId",
        locationNotificationModel.receiver);
    var result = await atClient.delete(atKey);
    print('$atKey delete operation $result');
  }

  AtKey newAtKey(int ttr, String key, String sharedWith, {int ttl}) {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = ttr
      ..metadata.ccd = true
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = atClient.currentAtSign;
    // if (ttl != null) atKey.metadata.ttl = ttl;
    return atKey;
  }
}

enum ATSIGNS { COLIN, ASHISH, BOB }
