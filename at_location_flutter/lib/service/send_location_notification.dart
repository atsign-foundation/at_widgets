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
  int count;
  List<LocationNotificationModel> receivingAtsigns;

  AtClientImpl atClient;

  init(List<LocationNotificationModel> atsigns, AtClientImpl newAtClient) {
    count = 0;
    receivingAtsigns = atsigns;
    atClient = newAtClient;
    print('inside location package init');
    //Location().changeSettings(interval: 10);
    print('receivingAtsigns length - ${receivingAtsigns.length}');
    updateMyLocation2();
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
          // String atkeyMicrosecondId =
          //     notification.key.split('sharelocation-')[1].split('@')[0];
          // AtKey atKey = newAtKey(-1, "sharelocation-$atkeyMicrosecondId",
          //     notification.receiver);
          // LocationNotificationModel myLocationNotificationModel =
          //     LocationNotificationModel()
          //       ..atsignCreator = atClient.currentAtSign
          //       ..receiver = notification.receiver
          //       ..key = atKey.key
          //       ..lat = snapshot.data.latitude
          //       ..long = snapshot.data.longitude
          //       ..isAcknowledgment = true
          //       ..isAccepted = true
          //       ..updateMap = true;

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

    Timer.periodic(Duration(seconds: 3), (Timer t) async {
      receivingAtsigns.forEach((notification) async {
        bool isSend = false;

        if (notification.to == null)
          isSend = true;
        else if ((DateTime.now().difference(notification.from) >
                Duration(seconds: 0)) &&
            (notification.to.difference(DateTime.now()) > Duration(seconds: 0)))
          isSend = true;
        if (isSend) {
          notification.lat = myLocation.latitude;
          notification.long = myLocation.longitude;
          String atkeyMicrosecondId =
              notification.key.split('-')[1].split('@')[0];
          AtKey atKey = newAtKey(
              -1, "locationNotify-$atkeyMicrosecondId", notification.receiver);
          try {
            var result = await atClient.put(
                atKey,
                LocationNotificationModel.convertLocationNotificationToJson(
                    notification));
            // print('location sent:${result}');
            if (result) count++;
            // print('count $count');
          } catch (e) {
            // print('error in sending location: $e');
          }
        }
      });
      myLocation = await MyLocation().myLocation();
      // myLocation = LatLng(44, -112);
    });
  }

  manualLocationSend(double lat, double long) {
    LatLng myLocation = LatLng(lat, long);

    receivingAtsigns.forEach((notification) async {
      if (true) {
        print('inside forEach');

        notification.lat = myLocation.latitude;
        notification.long = myLocation.longitude;
        String atkeyMicrosecondId =
            notification.key.split('-')[1].split('@')[0];
        AtKey atKey = newAtKey(
            -1, "locationNotify-$atkeyMicrosecondId", notification.receiver);
        try {
          var result = await atClient.put(
              atKey,
              LocationNotificationModel.convertLocationNotificationToJson(
                  notification));
          // print('location sent:${result}');
          if (result) count++;
          // print('count $count');
        } catch (e) {
          // print('error in sending location: $e');
        }
      }
    });
  }

  sendNull(LocationNotificationModel locationNotificationModel) async {
    locationNotificationModel.lat = 0;
    locationNotificationModel.long = 0;
    String atkeyMicrosecondId =
        locationNotificationModel.key.split('-')[1].split('@')[0];
    AtKey atKey = newAtKey(-1, "locationNotify-$atkeyMicrosecondId",
        locationNotificationModel.receiver);
    try {
      var result = await atClient.put(
          atKey,
          LocationNotificationModel.convertLocationNotificationToJson(
              locationNotificationModel));
    } catch (e) {}
  }

  AtKey newAtKey(int ttr, String key, String sharedWith) {
    AtKey atKey = AtKey()
      ..metadata = Metadata()
      ..metadata.ttr = -1
      ..key = key
      ..sharedWith = sharedWith
      ..sharedBy = atClient.currentAtSign;
    return atKey;
  }
}
