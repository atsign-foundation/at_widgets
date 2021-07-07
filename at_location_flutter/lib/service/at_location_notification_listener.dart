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

class AtLocationNotificationListener {
  AtLocationNotificationListener._();
  static final _instance = AtLocationNotificationListener._();
  factory AtLocationNotificationListener() => _instance;
  final String locationKey = 'locationnotify';
  AtClientImpl? atClientInstance;
  String? currentAtSign;
  bool _monitorStarted = false;
  late bool showDialogBox;
  late GlobalKey<NavigatorState> navKey;
  // ignore: non_constant_identifier_names
  String? ROOT_DOMAIN;

  void init(
      AtClientImpl atClientInstanceFromApp,
      String currentAtSignFromApp,
      GlobalKey<NavigatorState> navKeyFromMainApp,
      String rootDomain,
      bool showDialogBox,
      {Function? newGetAtValueFromMainApp}) {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    navKey = navKeyFromMainApp;
    this.showDialogBox = showDialogBox;
    ROOT_DOMAIN = rootDomain;
    MasterLocationService().init(currentAtSignFromApp, atClientInstanceFromApp,
        newGetAtValueFromMainApp: newGetAtValueFromMainApp);

    startMonitor();
  }

  Future<bool> startMonitor() async {
    if (!_monitorStarted) {
      var privateKey =
          await (getPrivateKey(currentAtSign!) as FutureOr<String>);
      await atClientInstance!.startMonitor(privateKey, fnCallBack);
      print('Monitor started in location package');
      _monitorStarted = true;
    }
    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String?> getPrivateKey(String atsign) async {
    return await atClientInstance!.getPrivateKey(atsign);
  }

  void fnCallBack(var response) async {
    print('fnCallBack called');
    SyncSecondary()
        .completePrioritySync(response, afterSync: _notificationCallback);
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

    if (operation == 'delete') {
      if (atKey.toString().toLowerCase().contains(locationKey)) {
        print('$notificationKey deleted');
        MasterLocationService().deleteReceivedData(fromAtSign);
        return;
      }

      if (atKey
          .toString()
          .toLowerCase()
          .contains(MixedConstants.SHARE_LOCATION)) {
        print('$notificationKey containing sharelocation deleted');
        KeyStreamService().removeData(atKey.toString());
        return;
      }

      if (atKey
          .toString()
          .toLowerCase()
          .contains(MixedConstants.REQUEST_LOCATION)) {
        print('$notificationKey containing requestlocation deleted');
        KeyStreamService().removeData(atKey.toString());
        return;
      }
    }

    var decryptedMessage = await atClientInstance!.encryptionService!
        .decrypt(value, fromAtSign)
        // ignore: return_of_invalid_type_from_catch_error
        .catchError((e) => print('error in decrypting: $e'));

    if (atKey
        .toString()
        .toLowerCase()
        .contains(MixedConstants.DELETE_REQUEST_LOCATION_ACK)) {
      var msg =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      // ignore: unawaited_futures
      RequestLocationService().deleteKey(msg);
      return;
    }

    if (atKey.toString().toLowerCase().contains(locationKey)) {
      var msg =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      MasterLocationService().updateHybridList(msg);
      return;
    }

    if (atKey
        .toString()
        .toLowerCase()
        .contains(MixedConstants.SHARE_LOCATION_ACK)) {
      var locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      // ignore: unawaited_futures
      SharingLocationService().updateWithShareLocationAcknowledge(locationData);
      return;
    }

    if (atKey
        .toString()
        .toLowerCase()
        .contains(MixedConstants.SHARE_LOCATION)) {
      var locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      if (locationData.isAcknowledgment == true) {
        KeyStreamService().mapUpdatedLocationDataToWidget(locationData);
      } else {
        await KeyStreamService().addDataToList(locationData);
        await showMyDialog(fromAtSign, locationData);
      }
      return;
    }

    if (atKey
        .toString()
        .toLowerCase()
        .contains(MixedConstants.REQUEST_LOCATION_ACK)) {
      var locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      // ignore: unawaited_futures
      RequestLocationService()
          .updateWithRequestLocationAcknowledge(locationData);
      return;
    }

    if (atKey
        .toString()
        .toLowerCase()
        .contains(MixedConstants.REQUEST_LOCATION)) {
      var locationData =
          LocationNotificationModel.fromJson(jsonDecode(decryptedMessage));
      if (locationData.isAcknowledgment == true) {
        KeyStreamService().mapUpdatedLocationDataToWidget(locationData);
      } else {
        await KeyStreamService().addDataToList(locationData);
        await showMyDialog(fromAtSign, locationData);
      }
      return;
    }
  }

  Future<void> showMyDialog(
      String? fromAtSign, LocationNotificationModel locationData) async {
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
