import 'dart:async';
import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/models/event_member_location.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/screens/notification_dialog/event_notification_dialog.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
// import 'package:at_events_flutter/services/sync_secondary.dart';
import 'package:at_location_flutter/service/sync_secondary.dart';
import 'package:at_events_flutter/utils/constants.dart';
import 'package:flutter/material.dart';

/// Starts monitor and listens for notifications related to this package.
class AtEventNotificationListener {
  AtEventNotificationListener._();
  static final AtEventNotificationListener _instance = AtEventNotificationListener._();
  factory AtEventNotificationListener() => _instance;
  AtClientImpl? atClientInstance;
  bool monitorStarted = false;
  String? currentAtSign;
  GlobalKey<NavigatorState>? navKey;
  // ignore: non_constant_identifier_names
  String? rootDomain;

  void init(AtClientImpl atClientInstanceFromApp, String currentAtSignFromApp,
      GlobalKey<NavigatorState> navKeyFromMainApp, String rootDomain,
      {Function? newGetAtValueFromMainApp}) {
    initializeContactsService(atClientInstanceFromApp, currentAtSignFromApp, rootDomain: rootDomain);

    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    navKey = navKeyFromMainApp;
    rootDomain = rootDomain;
    startMonitor();
  }

  Future<bool> startMonitor() async {
    if (!monitorStarted) {
      String privateKey = (await (getPrivateKey(currentAtSign!))) ?? '';
      await atClientInstance!.startMonitor(privateKey, fnCallBack);
      print('Monitor started in events package');
      monitorStarted = true;
    }

    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String?> getPrivateKey(String atsign) async {
    return atClientInstance!.getPrivateKey(atsign);
  }

  void fnCallBack(String response) {
    print('fnCallBack called');
    SyncSecondary().completePrioritySync(response, afterSync: _notificationCallback);
  }

  Future<void> _notificationCallback(dynamic response) async {
    print('fnCallBack called in event service');
    response = response.replaceFirst('notification:', '');
    dynamic responseJson = jsonDecode(response);
    dynamic value = responseJson['value'];
    dynamic notificationKey = responseJson['key'];
    dynamic fromAtSign = responseJson['from'];
    dynamic atKey = notificationKey.split(':')[1];
    dynamic operation = responseJson['operation'];
    print('_notificationCallback opeartion $operation');
    if ((operation == 'delete') && atKey.toString().toLowerCase().contains('createevent')) {
      return;
    }

    String decryptedMessage = await atClientInstance!.encryptionService!.decrypt(value, fromAtSign).catchError((dynamic e) {
      print('error in decrypting: $e');
    });
    print('decrypted message:$decryptedMessage');

    if (atKey.toString().contains('createevent')) {
      EventNotificationModel eventData = EventNotificationModel.fromJson(jsonDecode(decryptedMessage));
      if (eventData.isUpdate != null && eventData.isUpdate == false) {
        // new event received
        // show dialog
        // add in event list
        EventKeyLocationModel? _result = await EventKeyStreamService().addDataToList(eventData);
        if (_result is EventKeyLocationModel) {
          await showMyDialog(eventNotificationModel: eventData);
        }
      } else if (eventData.isUpdate!) {
        // event updated received
        // update event list
        EventKeyStreamService().mapUpdatedEventDataToWidget(eventData);
      }

      return;
    }

    if (atKey.toString().contains('eventacknowledged')) {
      EventNotificationModel msg = EventNotificationModel.fromJson(jsonDecode(decryptedMessage));

      await EventKeyStreamService().createEventAcknowledge(msg, atKey, fromAtSign);
      return;
    }

    if (atKey.toString().contains(MixedConstants.eventMemberLocationKey)) {
      EventMemberLocation msg = EventMemberLocation.fromJson(jsonDecode(decryptedMessage));

      await EventKeyStreamService().updateLocationData(msg, atKey, fromAtSign);
      return;
    }
  }

  Future<void> showMyDialog({EventNotificationModel? eventNotificationModel}) async {
    return showDialog<void>(
      context: navKey!.currentContext!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return EventNotificationDialog(eventData: eventNotificationModel);
      },
    );
  }
}
