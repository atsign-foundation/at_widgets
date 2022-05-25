import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_dude_flutter/models/dude_model.dart';
import 'package:at_dude_flutter/models/profile_model.dart';
import 'package:at_utils/at_utils.dart';
import 'package:flutter/material.dart';
import 'package:at_client/src/service/notification_service.dart';
import 'package:provider/provider.dart';
import 'local_notification_service.dart';

class DudeService extends ChangeNotifier {
  /// Singleton instance declaration
  DudeService._();

  static final DudeService _instance = DudeService._();

  /// Factory pattern to get singleton instance
  factory DudeService() => _instance;
  late AtContactsImpl atContactImpl;
  List<AtContact?>? selectedContacts = [];

  late AtClientManager atClientManager;
  String? currentAtSign;
  final AtSignLogger _logger =
      AtSignLogger("AppNameSpace"); // Developers App Namespace
  var contactService = ContactService(); //not static

  Future<void> initDudeService(String currentAtSignFromApp,
      String rootDomainFromApp, int rootPortFromApp) async {
    atClientManager = AtClientManager.getInstance();
    currentAtSign = currentAtSignFromApp;
    atContactImpl = await AtContactsImpl.getInstance(currentAtSignFromApp);
    initializeContactsService(rootDomain: rootDomainFromApp);
    await monitorNotifications();
    selectedContacts = await getContactList();
    getContactList();
  }

  Future<bool> putDude(DudeModel dude, String contactAtsign) async {
    bool isCompleted = false;
    dude.saveSender(atClientManager.atClient.getCurrentAtSign()!);
    dude.saveReceiver(contactAtsign);
    dude.saveId();
    var metaData = Metadata()
      ..isEncrypted = true
      ..namespaceAware = true
      ..ttr = -1
      ..isPublic = false;

    var key = AtKey()
      ..key = dude.id
      ..sharedBy = dude.sender
      ..sharedWith = dude.receiver
      ..metadata = metaData
      ..namespace = '';

    dude.saveTimeSent();

    await atClientManager.notificationService.notify(
      NotificationParams.forUpdate(
        key,
        value: json.encode(dude.toJson()),
      ),
    );

    var profileMetaData = Metadata()
      ..isEncrypted = true
      ..namespaceAware = true
      ..isPublic = false;

    var profileKey = AtKey()
      ..key = 'dude_profile_' + dude.sender.replaceFirst('@', '')
      ..sharedBy = dude.sender
      ..metadata = profileMetaData;

    try {
      AtValue profileAtValue = await atClientManager.atClient.get(profileKey);
      ProfileModel profileModel =
          ProfileModel.fromJson(jsonDecode(profileAtValue.value));
      profileModel.saveId(dude.sender);
      profileModel.dudesSent += 1;
      profileModel.dudeHours += dude.duration;
      if (dude.duration > profileModel.longestDude) {
        profileModel.saveLongestDude(dude.duration);
      }
      await atClientManager.atClient
          .put(
            profileKey,
            json.encode(
              profileModel.toJson(),
            ),
          )
          .whenComplete(() => isCompleted = true)
          .onError((error, stackTrace) => isCompleted = false);
    } catch (e) {
      // Exception should be thrown the first time a profile is created for an atsign
      await atClientManager.atClient
          .put(
            profileKey,
            json.encode(
              ProfileModel(
                      id: dude.sender,
                      dudesSent: 1,
                      dudeHours: dude.duration,
                      longestDude: dude.duration)
                  .toJson(),
            ),
          )
          .whenComplete(() => isCompleted = true)
          .onError((error, stackTrace) => isCompleted = false);
    }
    return isCompleted;
  }

  Future<List<DudeModel>> getDudes() async {
    atContactImpl = await AtContactsImpl.getInstance(
        atClientManager.atClient.getCurrentAtSign()!);
    // @blizzard30:some_uuid.at_skeleton_app@assault30
    // @blizzard30:signing_privatekey@blizzard30
    List<String> sendersAtsignList = await getSenderAtsigns();
    List<AtKey> receivedKeysList = [];
    for (var atsign in sendersAtsignList) {
      var key = await atClientManager.atClient.getAtKeys(
        regex: '^cached:.*@.+\$',
      );

      receivedKeysList.addAll(key);
    }

    List<DudeModel> duDe = [];
    for (AtKey key in receivedKeysList) {
      try {
        if (key.sharedBy != null && key.key!.length == 36) {
          AtValue _keyValue = await atClientManager.atClient.get(key);

          duDe.add(DudeModel.fromJson(jsonDecode(_keyValue.value)));
        }
      } on Exception catch (e) {
        ScaffoldMessenger(child: SnackBar(content: Text(e.toString())));
      }
    }
    return duDe;
  }
// monitor regex

  Future<void> monitorNotifications() async {
    atClientManager = AtClientManager.getInstance();

    atClientManager.notificationService
        .subscribe(regex: 'at_skeleton_app')
        .listen((AtNotification notification) {
      print('noti id is : ' + notification.value!);
      String? currentAtsign = atClientManager.atClient.getCurrentAtSign();
//
      if (currentAtsign == notification.to) {
        putSenderAtsign(
            senderAtsign: notification.from, receiverAtsign: notification.to);
        LocalNotificationService().showNotifications(notification.id.length,
            'Dude', '${notification.from} sent you a dude', 1);
        // Workmanager().initialize(() {
        //   LocalNotificationService().showNotifications(notification.id.length,
        //       'Dude', '${notification.from} sent you a dude', 1);
        // }, isInDebugMode: true);
        // Workmanager().registerOneOffTask('1', 'send notification');
      }
    });
  }

// changed to async
  Future<List<AtContact>?> getContactList() async {
    atContactImpl = await AtContactsImpl.getInstance(
        atClientManager.atClient.getCurrentAtSign()!);
    return await contactService.fetchContacts();
  }

  Future<Uint8List?> getCurrentAtsignProfileImage() async {
    return await contactService
        .getContactDetails(atClientManager.atClient.getCurrentAtSign(), null)
        .then((value) {
      return value['image'];
    });
  }

  Future<dynamic> getCurrentAtsignContactDetails() async {
    return await contactService
        .getContactDetails(currentAtSign, null)
        .then((value) {
      return value;
    });
  }

  Future<ProfileModel> getProfile() async {

    return await atClientManager.atClient
        .getAtKeys(
          regex: 'dude_profile_',
          sharedBy: atClientManager.atClient.getCurrentAtSign(),
        )
        .then(
          (value) => atClientManager.atClient.get(value[0]).then(
                (value) => ProfileModel.fromJson(
                  jsonDecode(value.value),
                ),
              ),
        );
  }

  Future<void> putSenderAtsign(
      {required String senderAtsign, required String receiverAtsign}) async {
    // atClientManager.syncService.addProgressListener(MySyncProgressListener());
    var metaData = Metadata()
      ..isEncrypted = true
      ..namespaceAware = true
      ..isPublic = false;

    var key = AtKey()
      ..key = 'dude_sender_atsigns_' + senderAtsign.replaceFirst('@', '')
      ..metadata = metaData
      ..sharedBy = senderAtsign
      ..sharedWith = receiverAtsign
      ..namespace = '';
    try {
      await atClientManager.notificationService.notify(
        NotificationParams.forUpdate(
          key,
          value: senderAtsign,
        ),
      );
    } on AtClientException catch (atClientExcep) {
      _logger.severe('❌ AtClientException : ${atClientExcep.errorMessage}');
    } catch (e) {
      _logger.severe('❌ Exception : ${e.toString()}');
    }
  }

  Future<List<String>> getSenderAtsigns() async {
    List<AtKey> keysList =
        await atClientManager.atClient.getAtKeys(regex: 'dude_sender_atsigns_');

    List<String> senderAtsigns = [];
    for (AtKey key in keysList) {
      try {
        AtValue _keyValue = await atClientManager.atClient.get(key);
        senderAtsigns.add(_keyValue.value);
      } on AtClientException catch (atClientExcep) {
        _logger.severe('❌ AtClientException : ${atClientExcep.errorMessage}');
      } catch (e) {
        _logger.severe('❌ Exception : ${e.toString()}');
      }
    }
    return senderAtsigns;
  }

  Future<bool> deleteDude(DudeModel dude) async {
    try {
      List<AtKey> dudeAtKey =
          await atClientManager.atClient.getAtKeys(regex: dude.id);
      bool isDeleted = await atClientManager.atClient.delete(dudeAtKey[0]);

      return isDeleted;
    } on AtClientException catch (atClientExcep) {
      _logger.severe('❌ AtClientException : ${atClientExcep.errorMessage}');
      return false;
    } catch (e) {
      _logger.severe('❌ Exception : ${e.toString()}');
      return false;
    }
  }

  List<DudeModel> _dudes = [];

  List<DudeModel> get dudes {
    _dudes.sort((a, b) => b.timeSent.compareTo(a.timeSent));
    return [..._dudes];
  }

  void getDudesList() async {
    _dudes = await getDudes();
    notifyListeners();
  }

  void deleteSingleDude(DudeModel dude) async {
    bool result = await deleteDude(dude);
    result ? _dudes = await getDudes() : null;
    notifyListeners();
  }
}
