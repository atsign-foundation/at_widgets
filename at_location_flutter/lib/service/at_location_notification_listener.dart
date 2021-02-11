import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/master_location_service.dart';

class AtLocationNotificationListener {
  AtLocationNotificationListener._();
  static final _instance = AtLocationNotificationListener._();
  factory AtLocationNotificationListener() => _instance;
  final String locationKey = 'locationnotify';
  AtClientImpl atClientInstance;
  String currentAtSign;

  init(AtClientImpl atClientInstanceFromApp, String currentAtSignFromApp,
      {Function newGetAtValueFromMainApp}) {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
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
      print('$notificationKey deleted');
      MasterLocationService().deleteReceivedData(fromAtSign);
      return;
    }
    var decryptedMessage = await atClientInstance.encryptionService
        .decrypt(value, fromAtSign)
        .catchError((e) =>
            print("error in decrypting: ${e.errorCode} ${e.errorMessage}"));
    if (atKey.toString().contains(locationKey)) {
      LocationNotificationModel msg =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      print('_notificationCallback LocationNotificationModel $msg');
      MasterLocationService().updateHybridList(msg);
    }
  }
}
