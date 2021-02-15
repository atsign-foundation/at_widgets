import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/screens/notification_dialog/notification_dialog.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:at_location_flutter/service/master_location_service.dart';
import 'package:flutter/material.dart';

import 'sharing_location_service.dart';

class AtLocationNotificationListener {
  AtLocationNotificationListener._();
  static final _instance = AtLocationNotificationListener._();
  factory AtLocationNotificationListener() => _instance;
  final String locationKey = 'locationnotify';
  AtClientImpl atClientInstance;
  String currentAtSign;
  GlobalKey<NavigatorState> navKey;

  init(AtClientImpl atClientInstanceFromApp, String currentAtSignFromApp,
      GlobalKey<NavigatorState> navKeyFromMainApp,
      {Function newGetAtValueFromMainApp}) {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    navKey = navKeyFromMainApp;
    MasterLocationService().init(currentAtSignFromApp, atClientInstanceFromApp,
        newGetAtValueFromMainApp: newGetAtValueFromMainApp);
    startMonitor();
  }

  Future<bool> startMonitor() async {
    String privateKey = await getPrivateKey(currentAtSign);
    atClientInstance.startMonitor(privateKey, _notificationCallback);
    print("Monitor started in location package");
    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await atClientInstance.getPrivateKey(atsign);
  }

  void _notificationCallback(dynamic notification) async {
    print('_notificationCallback called');
    notification = notification.replaceFirst('notification:', '');
    var responseJson = jsonDecode(notification);
    var value = responseJson['value'];
    var notificationKey = responseJson['key'];
    print(
        '_notificationCallback :$notification , notification key: $notificationKey');
    var fromAtSign = responseJson['from'];
    var atKey = notificationKey.split(':')[1];
    var operation = responseJson['operation'];
    print('_notificationCallback opeartion $operation');
    if (operation == 'delete') {
      if (atKey.toString().toLowerCase().contains(locationKey)) {
        print('$notificationKey deleted');
        MasterLocationService().deleteReceivedData(fromAtSign);
        return;
      } else if (atKey.toString().toLowerCase().contains('sharelocation')) {
        KeyStreamService().removeData(atKey);
        return;
      }
    }
    var decryptedMessage = await atClientInstance.encryptionService
        .decrypt(value, fromAtSign)
        .catchError((e) =>
            print("error in decrypting: ${e.errorCode} ${e.errorMessage}"));
    if (atKey.toString().toLowerCase().contains(locationKey)) {
      LocationNotificationModel msg =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('_notificationCallback LocationNotificationModel $msg');
      MasterLocationService().updateHybridList(msg);
    } else if (atKey
        .toString()
        .toLowerCase()
        .contains('sharelocationacknowledged')) {
      LocationNotificationModel locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('sharelocationacknowledged ${locationData.isAccepted}');
      SharingLocationService().updateWithShareLocationAcknowledge(locationData);
    } else if (atKey.toString().toLowerCase().contains('sharelocation')) {
      LocationNotificationModel locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('locationData service -> ${locationData.isAccepted}');
      if (locationData.isAcknowledgment == true) {
        KeyStreamService().mapUpdatedLocationDataToWidget(locationData);
      } else {
        print('add this to our list else');
        KeyStreamService().addDataToList(locationData);

        showMyDialog(fromAtSign, locationData);
      }
    }
  }

  Future<void> showMyDialog(
      String fromAtSign, LocationNotificationModel locationData) async {
    return showDialog<void>(
      context: navKey.currentContext,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return NotificationDialog(
          userName: fromAtSign,
          locationData: locationData,
        );
      },
    );
  }
}
