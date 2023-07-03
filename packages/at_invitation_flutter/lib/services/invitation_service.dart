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
import 'package:at_utils/at_logger.dart';

/// Provides methods for inviting contacts
class InvitationService {
  InvitationService._();
  static final InvitationService _instance = InvitationService._();
  factory InvitationService() => _instance;

  final AtSignLogger _logger = AtSignLogger('Invitation Service');

  final String invitationKey = 'invite';
  final String invitationAckKey = 'invite-ack';

  GlobalKey<NavigatorState>? navkey = GlobalKey();
  String? rootDomain;
  int? rootPort;
  String? webPage;
  bool hasMonitorStarted = false;

  GlobalKey<NavigatorState> get navigatorKey => navkey ?? GlobalKey();
  void initInvitationService(
      GlobalKey<NavigatorState>? navkeyFromApp,
      String? webPageFromApp,
      String rootDomainFromApp,
      int rootPortFromApp) async {
    navkey = navkeyFromApp;
    webPage = webPageFromApp;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;

    await startMonitor();
  }

  // startMonitor needs to be called at the beginning of session
  // called again if outbound connection is dropped
  Future<bool> startMonitor() async {
    if (!hasMonitorStarted) {
      AtClientManager.getInstance()
          .atClient
          .notificationService
          .subscribe(shouldDecrypt: true)
          .listen((notification) {
        _notificationCallback(notification);
      });
      hasMonitorStarted = true;
    }

    return true;
  }

  ///Fetches privatekey for [atsign] from device keychain.
  Future<String> getPrivateKey(String atsign) async {
    return await KeychainUtil.getPrivateKey(atsign) ?? '';
  }

  void _notificationCallback(dynamic notification) async {
    var notificationKey = notification.key;
    var fromAtsign = notification.from;

    // remove from and to atsigns from the notification key
    if (notificationKey.contains(':')) {
      notificationKey = notificationKey.split(':')[1];
    }
    notificationKey.replaceFirst(fromAtsign, '');
    notificationKey.trim();

    if (notificationKey.startsWith(invitationKey)) {
      var decryptedMessage = notification.value;
      if (notificationKey.startsWith(invitationAckKey)) {
        _processInviteAcknowledgement(decryptedMessage, fromAtsign);
      } else {
        _logger.info('received invited data => $decryptedMessage');
      }
    }
  }

  /// Process the invitation acknowledgement
  void _processInviteAcknowledgement(String? data, String? fromAtsign) async {
    if (data != null && fromAtsign != null) {
      MessageShareModel receivedInformation =
          MessageShareModel.fromJson(jsonDecode(data));

      // build and fetch self key
      AtKey atKey = AtKey()..metadata = Metadata();
      atKey.key = invitationKey + '.' + (receivedInformation.identifier ?? '');
      atKey.metadata?.ttr = -1;
      var result = await AtClientManager.getInstance().atClient.get(atKey);
      MessageShareModel sentInformation =
          MessageShareModel.fromJson(jsonDecode(result.value));

      var receivedPasscode = receivedInformation.passcode;
      var sentPasscode = sentInformation.passcode;

      if (sentPasscode == receivedPasscode) {
        atKey.sharedWith = fromAtsign;
        await AtClientManager.getInstance()
            .atClient
            .put(atKey, jsonEncode(sentInformation.message))
            .catchError((e) {
          _logger.severe('Error in sharing saved message => $e');
          return false;
        });
      }
    }
  }

  /// Invite a contact and create a shared key
  Future<void> shareAndinvite(BuildContext context, String jsonData) async {
    // create a key and save the json data
    var keyID = const Uuid().v4();
    int code = Random().nextInt(9999);
    String passcode = code.toString().padLeft(4, '0');

    MessageShareModel messageContent = MessageShareModel(
        passcode: passcode, identifier: keyID, message: jsonData);

    AtKey atKey = AtKey()..metadata = Metadata();
    atKey.key = invitationKey + '.' + keyID;
    atKey.metadata?.ttr = -1;
    var result = await AtClientManager.getInstance()
        .atClient
        .put(atKey, jsonEncode(messageContent))
        .catchError((e) {
      _logger.severe('Error in saving shared data => $e');
      return false;
    });
    if (result == true) {
      showDialog(
        context: context,
        builder: (context) => ShareDialog(
            uniqueID: keyID,
            passcode: passcode,
            webPageLink: webPage,
            currentAtsign:
                AtClientManager.getInstance().atClient.getCurrentAtSign() ??
                    ''),
      );
    }
  }

  /// fetch the invitation data
  Future<void> fetchInviteData(
      BuildContext context, String data, String atsign) async {
    String otp = await showDialog(
      context: context,
      builder: (context) => const OTPDialog(),
    );
    AtKey atKey = AtKey()..metadata = Metadata();
    atKey.key = invitationAckKey + '.' + data;
    atKey.sharedWith = atsign;
    atKey.metadata?.ttr = -1;
    MessageShareModel messageContent = MessageShareModel(
        passcode: otp, identifier: data, message: 'invite acknowledgement');
    await AtClientManager.getInstance()
        .atClient
        .put(atKey, jsonEncode(messageContent))
        .catchError((e) {
      _logger.severe('Error in saving acknowledge message => $e');
      return false;
    });
  }
}
