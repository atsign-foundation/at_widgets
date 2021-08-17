/// A service to handle save and retrieve operation on chat

import 'dart:async';
import 'dart:convert';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_client_mobile/at_client_mobile.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_commons/at_commons.dart';
import 'package:at_notify_flutter/models/notify_model.dart';
import 'package:at_notify_flutter/utils/notify_utils.dart';

class NotifyService {
  NotifyService._();

  static final NotifyService _instance = NotifyService._();

  factory NotifyService() => _instance;

  final String storageKey = 'notify.';
  final String notifyKey = 'notifyKey';

  String sendToAtSign = '';

  late AtClientImpl atClientInstance;
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
      AtClientImpl atClientInstanceFromApp,
      String currentAtSignFromApp,
      String rootDomainFromApp,
      int rootPortFromApp) async {
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    await startMonitor();
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor() async {
    var privateKey = await getPrivateKey(currentAtSign!);
    await atClientInstance.startMonitor(privateKey, _notificationCallback);
    print('Monitor started');
    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    var str = await atClientInstance.getPrivateKey(atsign);
    return str!;
  }

  void _notificationCallback(dynamic notification) async {
    notification = notification.replaceFirst('notification:', '');
    var responseJson = jsonDecode(notification);
    var notificationKey = responseJson['key'];
    var fromAtsign = responseJson['from'];

    // remove from and to atsigns from the notification key
    if (notificationKey.contains(':')) {
      notificationKey = notificationKey.split(':')[1];
    }
    notificationKey.replaceFirst(fromAtsign, '');
    notificationKey.trim();

    if ((notificationKey.startsWith(notifyKey) &&
        fromAtsign == currentAtSign)) {
      var message = responseJson['value'];
      var decryptedMessage = await atClientInstance.encryptionService!
          .decrypt(message, fromAtsign)
          .catchError((e) {
        print('error in decrypting bugReport ${e.errorCode} ${e.errorMessage}');
      });
      print('notify message => $decryptedMessage $fromAtsign');
      await addNotify(
        Notify(
          message: decryptedMessage,
          atSign: fromAtsign,
          time: responseJson['epochMillis'],
        ),
      );
    }
  }

  Future<void> getNotifies({String? atsign}) async {
    try {
      notifies = [];
      var key = AtKey()
        ..key = storageKey + (atsign ?? currentAtSign ?? ' ').substring(1)
        ..sharedBy = currentAtSign
        ..sharedWith = sendToAtSign
        ..metadata = Metadata();

      var keyValue = await atClientInstance.get(key).catchError((e) {
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
      // var referenceKey = bugReportKey +
      //     (notifies.isEmpty ? '' : notifies[0].time.toString()) +
      //     currentAtSign!;
      // await checkForMissedMessages(referenceKey);
    } catch (error) {
      print('Error in getting bug Report -> $error');
    }
  }

  void setSendToAtSign(String? sendToAtSign) {
    this.sendToAtSign = sendToAtSign!;
  }

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
      await atClientInstance.put(key, json.encode(notifiesJson));

      if (notifyType != null) {
        if (notifyType == NotifyEnum.notifyAll) {
          await atClientInstance.notifyAll(
              key, json.encode(notifiesJson), OperationEnum.update);
        } else if (notifyType == NotifyEnum.notifyList) {
          await atClientInstance.notifyList();
        } else {
          await atClientInstance.notify(
              key, json.encode(notifiesJson), OperationEnum.update);
        }
      } else {
        await atClientInstance.notify(
            key, json.encode(notifiesJson), OperationEnum.update);
      }
      return true;
    } catch (e) {
      print('Error in setting notify => $e');
      return false;
    }
  }
}
