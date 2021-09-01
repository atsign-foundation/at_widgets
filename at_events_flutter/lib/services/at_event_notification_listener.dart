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
import 'package:at_client/src/response/at_notification.dart';

/// Starts monitor and listens for notifications related to this package.
class AtEventNotificationListener {
  AtEventNotificationListener._();
  static final _instance = AtEventNotificationListener._();
  factory AtEventNotificationListener() => _instance;
  late AtClientManager atClientManager;
  bool monitorStarted = false;
  String? currentAtSign;
  GlobalKey<NavigatorState>? navKey;
  // ignore: non_constant_identifier_names
  String? ROOT_DOMAIN;

  void init(AtClientManager atClientManager, String currentAtSignFromApp,
      GlobalKey<NavigatorState> navKeyFromMainApp, String rootDomain,
      {Function? newGetAtValueFromMainApp}) {
    initializeContactsService(atClientManager, currentAtSignFromApp,
        rootDomain: rootDomain);

    this.atClientManager = atClientManager;
    currentAtSign = currentAtSignFromApp;
    navKey = navKeyFromMainApp;
    ROOT_DOMAIN = rootDomain;
    startMonitor();
  }

  Future<bool> startMonitor() async {
    if (!monitorStarted) {
      var privateKey = (await (getPrivateKey(currentAtSign!))) ?? '.rrive';
      print(
          'atClientManager.atClient.getPreferences()!.namespace ${atClientManager.atClient.getPreferences()!.namespace}');
      // ignore: await_only_futures
      // await atClientInstance!.startMonitor(privateKey, fnCallBack);

      atClientManager.notificationService
          .subscribe(
              // regex:
              // atClientManager.atClient.getPreferences()!.namespace ??
              // 'rrive'
              )
          .listen((notification) {
        _notificationCallback(notification as AtNotification);
      });

      print('Monitor started in events package');
      monitorStarted = true;
    }

    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String?> getPrivateKey(String atsign) async {
    // return await atClientInstance!.getPrivateKey(atsign);
  }

  // void fnCallBack(var response) async {
  //   print('fnCallBack called');
  //   // SyncSecondary()
  //   //     .completePrioritySync(response, afterSync: _notificationCallback);
  // }

  void _notificationCallback(AtNotification notification) async {
    print('fnCallBack called in event service');
    print('notification $notification');
    // response = response.replaceFirst('notification:', '');
    // var responseJson = jsonDecode(response);
    var value = notification.value;
    var notificationKey = notification.key;
    var fromAtSign = notification.from;

    if ((!notificationKey.contains('createevent')) &&
        (!notificationKey.contains('eventacknowledged')) &&
        (!notificationKey.contains(MixedConstants.EVENT_MEMBER_LOCATION_KEY))) {
      return;
    }

    // var atKey = notificationKey.split(':')[1];
    var operation = notification.operation;
    print('_notificationCallback opeartion $operation');
    if ((operation == 'delete') &&
        notificationKey.toString().toLowerCase().contains('createevent')) {
      // EventService().removeDeletedEventFromList(notificationKey);
      return;
    }

    var decryptedMessage = await atClientManager.atClient.encryptionService!
        .decrypt(value ?? '', fromAtSign)
        .catchError((e) {
      print('error in decrypting: $e');
    });
    print('decrypted message:$decryptedMessage');

    if (notificationKey.toString().contains('createevent')) {
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
      } else if (eventData.isUpdate!) {
        // event updated received
        // update event list
        EventKeyStreamService().mapUpdatedEventDataToWidget(eventData);
      }

      return;
    }

    if (notificationKey.toString().contains('eventacknowledged')) {
      var msg = EventNotificationModel.fromJson(jsonDecode(decryptedMessage));

      EventKeyStreamService().createEventAcknowledge(msg, fromAtSign);
      return;
    }

    if (notificationKey
        .toString()
        .contains(MixedConstants.EVENT_MEMBER_LOCATION_KEY)) {
      var msg = EventMemberLocation.fromJson(jsonDecode(decryptedMessage));

      EventKeyStreamService().updateLocationData(msg, fromAtSign);
      return;
    }
  }

  Future<void> showMyDialog(
      {EventNotificationModel? eventNotificationModel}) async {
    return showDialog<void>(
      context: navKey!.currentContext!,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return EventNotificationDialog(eventData: eventNotificationModel);
      },
    );
  }
}
