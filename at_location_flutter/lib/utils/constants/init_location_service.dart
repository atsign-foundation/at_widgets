import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:at_location_flutter/service/request_location_service.dart';
import 'package:at_location_flutter/service/send_location_notification.dart';
import 'package:at_location_flutter/service/sharing_location_service.dart';
import 'package:flutter/material.dart';

void initializeLocationService(AtClientImpl atClientImpl, String currentAtSign,
    GlobalKey<NavigatorState> navKey) {
  AtLocationNotificationListener().init(atClientImpl, currentAtSign, navKey);
  KeyStreamService().init(AtLocationNotificationListener().atClientInstance);
}

Stream getAllNotification() {
  return KeyStreamService().atNotificationsStream;
}

Future<bool> sendShareLocationNotification(String atsign, int minutes) async {
  bool result = await SharingLocationService()
      .sendShareLocationEvent(atsign, false, minutes: minutes);
  return result;
}

Future<bool> sendRequestLocationNotification(String atsign) async {
  bool result = await RequestLocationService().sendRequestLocationEvent(atsign);
  return result;
}

Future<bool> deleteLocationData(
    LocationNotificationModel locationNotificationModel) async {
  bool result =
      await SendLocationNotification().sendNull(locationNotificationModel);
  return result;
}

deleteAllLocationData() {
  SendLocationNotification().deleteAllLocationKey();
}
