/// A service to handle invitation needs

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:at_commons/at_commons.dart';
import 'package:at_invitation_flutter/models/message_share.dart';
import 'package:at_invitation_flutter/widgets/share_dialog.dart';
import 'package:at_invitation_flutter/widgets/otp_dialog.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:uuid/uuid.dart';

class InvitationService {
  InvitationService._();
  static final InvitationService _instance = InvitationService._();
  factory InvitationService() => _instance;

  final String invitationKey = 'invite';
  final String invitationAckKey = 'invite-ack';

  GlobalKey<NavigatorState>? navkey = GlobalKey();
  late AtClientImpl? atClientInstance;
  String? rootDomain;
  int? rootPort;
  String currentAtSign = '';
  String? webPage;

  GlobalKey<NavigatorState> get navigatorKey => navkey ?? GlobalKey();
  Future<void> initInvitationService(GlobalKey<NavigatorState>? navkeyFromApp, AtClientImpl? atClientInstanceFromApp,
      String? currentAtSignFromApp, String? webPageFromApp, String rootDomainFromApp, int rootPortFromApp) async {
    navkey = navkeyFromApp;
    atClientInstance = atClientInstanceFromApp;
    currentAtSign = currentAtSignFromApp ?? '';
    webPage = webPageFromApp;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    await startMonitor();
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor() async {
    String privateKey = await getPrivateKey(currentAtSign);
    await atClientInstance?.startMonitor(privateKey, _notificationCallback);
    print('Monitor started');
    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await atClientInstance?.getPrivateKey(atsign) ?? '';
  }

  Future<void> _notificationCallback(dynamic notification) async {
    notification = notification.replaceFirst('notification:', '');
    dynamic responseJson = jsonDecode(notification);
    String notificationKey = responseJson['key'];
    String fromAtsign = responseJson['from'];

    // remove from and to atsigns from the notification key
    if (notificationKey.contains(':')) {
      notificationKey = notificationKey.split(':')[1];
    }
    notificationKey.replaceFirst(fromAtsign, '');
    notificationKey.trim();

    if (notificationKey.startsWith(invitationKey)) {
      String message = responseJson['value'];
      String? decryptedMessage =
          await atClientInstance?.encryptionService?.decrypt(message, fromAtsign).catchError((Object e) {
        print('error in decrypting message ${e.toString()}');
      });
      print('message received => $decryptedMessage $fromAtsign');
      if (notificationKey.startsWith(invitationAckKey)) {
        await _processInviteAcknowledgement(decryptedMessage, fromAtsign);
      } else {
        print('received invited data => $decryptedMessage');
      }
    }
  }

  Future<void> _processInviteAcknowledgement(String? data, String? fromAtsign) async {
    if (data != null && fromAtsign != null) {
      MessageShareModel receivedInformation = MessageShareModel.fromJson(jsonDecode(data));
      print('receivedInformation $receivedInformation');

      // build and fetch self key
      AtKey atKey = AtKey()..metadata = Metadata();
      atKey.key = invitationKey + '.' + (receivedInformation.identifier ?? '');
      atKey.metadata?.ttr = -1;
      AtValue? result = await atClientInstance?.get(atKey);
      print('fetch result $result');
      MessageShareModel sentInformation = MessageShareModel.fromJson(jsonDecode(result?.value));

      String? receivedPasscode = receivedInformation.passcode;
      String? sentPasscode = sentInformation.passcode;

      if (sentPasscode == receivedPasscode) {
        atKey.sharedWith = fromAtsign;
        await atClientInstance?.put(atKey, jsonEncode(sentInformation.message)).catchError((Object e) {
          print('Error in sharing saved message => $e');
        });
      }
    }
  }

  Future<void> shareAndinvite(BuildContext context, String jsonData) async {
    // create a key and save the json data
    String keyID = const Uuid().v4();
    int code = Random().nextInt(9999);
    String passcode = code.toString().padLeft(4, '0');

    MessageShareModel messageContent = MessageShareModel(passcode: passcode, identifier: keyID, message: jsonData);

    AtKey atKey = AtKey()..metadata = Metadata();
    atKey.key = invitationKey + '.' + keyID;
    atKey.metadata?.ttr = -1;
    bool? result = await atClientInstance?.put(atKey, jsonEncode(messageContent)).catchError((Object e) {
      print('Error in saving shared data => $e');
    });
    print(atKey.key);
    if (result == true) {
      await showDialog(
        context: context,
        builder: (BuildContext context) =>
            ShareDialog(uniqueID: keyID, passcode: passcode, webPageLink: webPage, currentAtsign: currentAtSign),
      );
    }
  }

  Future<void> fetchInviteData(BuildContext context, String data, String atsign) async {
    String otp = await showDialog(
      context: context,
      builder: (BuildContext context) => OTPDialog(),
    );
    print('otp received => $otp');
    AtKey atKey = AtKey()..metadata = Metadata();
    atKey.key = invitationAckKey + '.' + data;
    atKey.sharedWith = atsign;
    atKey.metadata?.ttr = -1;
    MessageShareModel messageContent =
        MessageShareModel(passcode: otp, identifier: data, message: 'invite acknowledgement');
    print('created message');
    bool? result = await atClientInstance?.put(atKey, jsonEncode(messageContent)).catchError((Object e) {
      print('Error in saving acknowledge message => $e');
    });
    print(result);
    print(atKey.key);
  }
}
