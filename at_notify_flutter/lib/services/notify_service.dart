/// A service to handle save and retrieve operation on chat

import 'dart:async';
import 'dart:convert';
import 'package:at_client/at_client.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_notify_flutter/models/notify_model.dart';
import 'package:at_notify_flutter/utils/notify_utils.dart';

// ignore: implementation_imports
import 'package:at_client/src/service/notification_service.dart';

class NotifyService {
  NotifyService._();

  static final NotifyService _instance = NotifyService._();

  factory NotifyService() => _instance;

  final String storageKey = 'notify.';
  final String notifyKey = 'notifyKey';

  String sendToAtSign = '';

  late AtClientManager atClientManager;
  late AtClient atClient;

  // late AtClientImpl atClientInstance;
  String? rootDomain;
  int? rootPort;
  String? currentAtSign;

  List<Notify> notifies = [];
  List<dynamic>? notifiesJson = [];

  StreamController<List<Notify>> notifyStreamController =
      StreamController<List<Notify>>.broadcast();

  Sink get notifySink => notifyStreamController.sink;

  Stream<List<Notify>> get notifyStream => notifyStreamController.stream;

  void disposeControllers() {
    notifyStreamController.close();
  }

  void initNotifyService(
      AtClientManager atClientManagerFromApp,
      AtClientPreference atClientPreference,
      String currentAtSignFromApp,
      String rootDomainFromApp,
      int rootPortFromApp) async {
    currentAtSign = currentAtSignFromApp;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    atClientManager = atClientManagerFromApp;
    atClientManager.setCurrentAtSign(
        currentAtSignFromApp, '', atClientPreference);

    atClient = atClientManager.atClient;

    // notificationService.subscribe(regex: '.wavi').listen((notification) {
    //   _notificationCallback(notification);
    // });

    //   await startMonitor();
    atClientManager.notificationService.subscribe().listen((notification) {
      _notificationCallback(notification);
    });
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  // Future<bool> startMonitor() async {
  //   var privateKey = await getPrivateKey(currentAtSign!);
  //   await atClient.startMonitor(privateKey, _notificationCallback);
  //   print('Monitor started');
  //   return true;
  // }
  //
  // ///Fetches privatekey for [atsign] from device keychain.
  // Future<String> getPrivateKey(String atSign) async {
  //   var str = await atClientManager.atClient.getPrivateKey(atSign);
  //   return str!;
  // }

  /// Listen Notification
  void _notificationCallback(dynamic notification) async {
    AtNotification atNotification = notification;
    var notificationKey = atNotification.key;
    var fromAtsign = atNotification.from;
    var toAtsign = atNotification.to;

    // remove from and to atsigns from the notification key
    if (notificationKey.contains(':')) {
      notificationKey = notificationKey.split(':')[1];
    }
    notificationKey = notificationKey.replaceFirst(fromAtsign, '').trim();

    if ((notificationKey.startsWith(storageKey) && toAtsign == currentAtSign)) {
      var message = atNotification.value ?? '';
      var decryptedMessage = await atClient.encryptionService!
          .decrypt(message, fromAtsign)
          .catchError((e) {
     //   print('error in decrypting notify $e');
      });
      print('notify message => $decryptedMessage $fromAtsign');
      // await addNotify(
      //   Notify(
      //     message: decryptedMessage,
      //     atSign: fromAtsign,
      //     time: responseJson['epochMillis'],
      //   ),
      // );
    }
  }

  /// Get Notify List From AtClient
  Future<void> getNotifies({String? atsign}) async {
    try {
      notifies = [];
      var key = AtKey()
        ..key = storageKey + (atsign ?? currentAtSign ?? ' ').substring(1)
        ..sharedBy = currentAtSign
        ..sharedWith = sendToAtSign
        ..metadata = Metadata();

      var keyValue = await atClient.get(key).catchError((e) {
        print('error in get ${e.errorCode} ${e.errorMessage}');
      });

      // ignore: unnecessary_null_comparison
      if (keyValue != null && keyValue.value != null) {
        notifiesJson = json.decode((keyValue.value) as String) as List?;
        notifiesJson!.forEach((value) {
          var bugReport = Notify.fromJson((value));
          notifies.insert(0, bugReport);
        });
        notifySink.add(notifies);
      } else {
        notifiesJson = [];
        notifySink.add(notifies);
      }
    } catch (error) {
      print('Error in getting bug Report -> $error');
    }
  }

  void setSendToAtSign(String? sendToAtSign) {
    if (sendToAtSign != null && sendToAtSign[0] != '@') {
      sendToAtSign = '@' + sendToAtSign;
    }
    this.sendToAtSign = sendToAtSign!;
  }

  /// Send new notify to atClient
  Future<bool> addNotify(Notify notify, {NotifyEnum? notifyType}) async {
    try {
      var key = AtKey()
        ..key = storageKey + (currentAtSign ?? ' ').substring(1)
        ..sharedBy = currentAtSign
        ..sharedWith = sendToAtSign
        ..metadata = Metadata();

      notifies.insert(0, notify);
      notifySink.add(notifies);
      notifiesJson!.add(notify.toJson());
      await atClient.put(key, json.encode(notifiesJson));

      sendNotify(key, notify, notifyType ?? NotifyEnum.notifyForUpdate);

      // await atClientInstance.notify(
      //     key, json.encode(notifiesJson), OperationEnum.update);

      return true;
    } catch (e) {
      print('Error in setting notify => $e');
      return false;
    }
  }

  Future<bool> sendNotify(
    AtKey key,
    Notify notify,
    NotifyEnum notifyType,
  ) async {
    var notificationResponse;
    if (notifyType == NotifyEnum.notifyForDelete) {
      notificationResponse = await atClientManager.notificationService.notify(
        NotificationParams.forDelete(key),
      );
    } else if (notifyType == NotifyEnum.notifyText) {
      notificationResponse = await atClientManager.notificationService.notify(
          NotificationParams.forText(notify.message ?? '', sendToAtSign));
    } else {
      notificationResponse = await atClientManager.notificationService.notify(
        NotificationParams.forUpdate(key, value: json.encode(notifiesJson)),
        // onSuccess: _onSuccessCallback,
        // onError: _onErrorCallback,
      );
    }

    if (notificationResponse.notificationStatusEnum ==
        NotificationStatusEnum.delivered) {
      print(notificationResponse.toString());
    } else {
      print(notificationResponse.atClientException.toString());
      return false;
    }
    return true;
  }

  void _onSuccessCallback(notificationResult) {
    print(notificationResult);
  }

  void _onErrorCallback(notificationResult) {
    print(notificationResult.atClientException.toString());
  }
}
