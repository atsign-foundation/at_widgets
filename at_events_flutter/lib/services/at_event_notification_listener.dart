import 'dart:convert';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/screens/notification_dialog/event_notification_dialog.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
import 'package:at_events_flutter/services/sync_secondary.dart';
import 'package:flutter/material.dart';

class AtEventNotificationListener {
  AtEventNotificationListener._();
  static final _instance = AtEventNotificationListener._();
  factory AtEventNotificationListener() => _instance;
  AtClientImpl atClientInstance;
  String currentAtSign;
  GlobalKey<NavigatorState> navKey;
  // ignore: non_constant_identifier_names
  String ROOT_DOMAIN;

  void init(AtClientImpl atClientInstanceFromApp, String currentAtSignFromApp,
      GlobalKey<NavigatorState> navKeyFromMainApp, String rootDomain,
      {Function newGetAtValueFromMainApp}) {
    initializeContactsService(atClientInstance, currentAtSignFromApp);

    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    navKey = navKeyFromMainApp;
    ROOT_DOMAIN = rootDomain;
    startMonitor();
  }

  Future<bool> startMonitor() async {
    var privateKey = await getPrivateKey(currentAtSign);
    // ignore: await_only_futures
    await atClientInstance.startMonitor(privateKey, fnCallBack);
    print('Monitor started');
    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await atClientInstance.getPrivateKey(atsign);
  }

  void fnCallBack(var response) async {
    print('fnCallBack called');
    SyncSecondary()
        .completePrioritySync(response, afterSync: _notificationCallback);
  }

  void _notificationCallback(dynamic response) async {
    print('fnCallBack called in event service');
    response = response.replaceFirst('notification:', '');
    var responseJson = jsonDecode(response);
    var value = responseJson['value'];
    var notificationKey = responseJson['key'];
    var fromAtSign = responseJson['from'];
    var atKey = notificationKey.split(':')[1];
    var operation = responseJson['operation'];
    print('_notificationCallback opeartion $operation');
    if ((operation == 'delete') &&
        atKey.toString().toLowerCase().contains('createevent')) {
      // EventService().removeDeletedEventFromList(notificationKey);
      return;
    }

    var decryptedMessage = await atClientInstance.encryptionService
        .decrypt(value, fromAtSign)
        .catchError((e) {
      print('error in decrypting: $e');
    });
    print('decrypted message:$decryptedMessage');
    if (atKey.toString().contains('createevent')) {
      var eventData =
          EventNotificationModel.fromJson(jsonDecode(decryptedMessage));
      if (eventData.isUpdate != null && eventData.isUpdate == false) {
        // new event received
        // show dialog
        // add in event list
        var _result = await EventKeyStreamService().addDataToList(eventData);
        if (_result is EventKeyLocationModel) {
          await showMyDialog(eventNotificationModel: eventData);
        }
      } else if (eventData.isUpdate) {
        // event updated received
        // update event list
        EventKeyStreamService().mapUpdatedEventDataToWidget(eventData);
      }
    } else if (atKey.toString().contains('eventacknowledged')) {
      var msg = EventNotificationModel.fromJson(jsonDecode(decryptedMessage));

      EventKeyStreamService().createEventAcknowledge(msg, atKey, fromAtSign);
    }
  }

  Future<void> showMyDialog(
      {EventNotificationModel eventNotificationModel}) async {
    return showDialog<void>(
      context: navKey.currentContext,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return EventNotificationDialog(eventData: eventNotificationModel);
      },
    );
  }
}
