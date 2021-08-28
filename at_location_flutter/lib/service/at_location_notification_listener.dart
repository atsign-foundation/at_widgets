import 'dart:async';
import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/screens/notification_dialog/notification_dialog.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:at_location_flutter/service/master_location_service.dart';
import 'package:at_location_flutter/utils/constants/constants.dart';
import 'package:flutter/material.dart';

import 'request_location_service.dart';
import 'sharing_location_service.dart';
import 'sync_secondary.dart';

/// Starts monitor and listens for notifications related to this package.
class AtLocationNotificationListener {
  AtLocationNotificationListener._();
  static final AtLocationNotificationListener _instance = AtLocationNotificationListener._();
  factory AtLocationNotificationListener() => _instance;
  final String locationKey = 'locationnotify';
  AtClientImpl? atClientInstance;
  String? currentAtSign;
  bool _monitorStarted = false;
  late bool showDialogBox;
  late GlobalKey<NavigatorState> navKey;
  String? rootDomain;

  void init(AtClientImpl atClientInstanceFromApp, String currentAtSignFromApp,
      GlobalKey<NavigatorState> navKeyFromMainApp, String rootDomain, bool showDialogBox,
      {Function? newGetAtValueFromMainApp}) {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    navKey = navKeyFromMainApp;
    this.showDialogBox = showDialogBox;
    rootDomain = rootDomain;
    MasterLocationService()
        .init(currentAtSignFromApp, atClientInstanceFromApp, newGetAtValueFromMainApp: newGetAtValueFromMainApp);

    startMonitor();
  }

  Future<bool> startMonitor() async {
    if (!_monitorStarted) {
      String? privateKey = await (getPrivateKey(currentAtSign!));
      await atClientInstance!.startMonitor(privateKey!, fnCallBack);
      print('Monitor started in location package');
      _monitorStarted = true;
    }
    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String?> getPrivateKey(String atsign) async {
    return atClientInstance!.getPrivateKey(atsign);
  }

  Future<void> fnCallBack(String response) async {
    print('fnCallBack called');
    SyncSecondary().completePrioritySync(response, afterSync: _notificationCallback);
  }

  Future<void> _notificationCallback(dynamic notification) async {
    print('_notificationCallback called');
    notification = notification.replaceFirst('notification:', '');
    Map<String, dynamic> responseJson = jsonDecode(notification);
    dynamic value = responseJson['value'];
    dynamic notificationKey = responseJson['key'];
    print('_notificationCallback :$notification , notification key: $notificationKey');
    String fromAtSign = responseJson['from'];
    String atKey = notificationKey.split(':')[1];
    dynamic operation = responseJson['operation'];

    if (operation == 'delete') {
      if (atKey.toString().toLowerCase().contains(locationKey)) {
        print('$notificationKey deleted');
        MasterLocationService().deleteReceivedData(fromAtSign);
        return;
      }

      if (atKey.toString().toLowerCase().contains(MixedConstants.shareLocation)) {
        print('$notificationKey containing sharelocation deleted');
        KeyStreamService().removeData(atKey.toString());
        return;
      }

      if (atKey.toString().toLowerCase().contains(MixedConstants.requestLocation)) {
        print('$notificationKey containing requestlocation deleted');
        KeyStreamService().removeData(atKey.toString());
        return;
      }
    }

    String decryptedMessage =
        await atClientInstance!.encryptionService!.decrypt(value, fromAtSign).catchError((dynamic e) {
      print('error in decrypting: $e');
    });

    if (atKey.toString().toLowerCase().contains(MixedConstants.deleteRequestLocationACK)) {
      LocationNotificationModel msg = LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      await RequestLocationService().deleteKey(msg);
      return;
    }

    if (atKey.toString().toLowerCase().contains(locationKey)) {
      LocationNotificationModel msg = LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      await MasterLocationService().updateHybridList(msg);
      return;
    }

    if (atKey.toString().toLowerCase().contains(MixedConstants.shareLocationACK)) {
      LocationNotificationModel locationData = LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      await SharingLocationService().updateWithShareLocationAcknowledge(locationData);
      return;
    }

    if (atKey.toString().toLowerCase().contains(MixedConstants.shareLocation)) {
      LocationNotificationModel locationData = LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      if (locationData.isAcknowledgment == true) {
        KeyStreamService().mapUpdatedLocationDataToWidget(locationData);
        if (locationData.rePrompt) {
          await showMyDialog(fromAtSign, locationData);
        }
      } else {
        await KeyStreamService().addDataToList(locationData);
        await showMyDialog(fromAtSign, locationData);
      }
      return;
    }

    if (atKey.toString().toLowerCase().contains(MixedConstants.requestLocationACK)) {
      LocationNotificationModel locationData = LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      await RequestLocationService().updateWithRequestLocationAcknowledge(locationData);
      return;
    }

    if (atKey.toString().toLowerCase().contains(MixedConstants.requestLocation)) {
      LocationNotificationModel locationData = LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      if (locationData.isAcknowledgment == true) {
        KeyStreamService().mapUpdatedLocationDataToWidget(locationData);
        if (locationData.rePrompt) {
          await showMyDialog(fromAtSign, locationData);
        }
      } else {
        await KeyStreamService().addDataToList(locationData);
        await showMyDialog(fromAtSign, locationData);
      }
      return;
    }
  }

  Future<void> showMyDialog(String? fromAtSign, LocationNotificationModel locationData) async {
    print('showMyDialog called');
    if (showDialogBox) {
      return showDialog<void>(
        context: navKey.currentContext!,
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
}
