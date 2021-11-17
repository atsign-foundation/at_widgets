/// A service to handle CRUD operation on contacts

import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_client_mobile/at_client_mobile.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_commons/at_commons.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_lookup/at_lookup.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:at_client/src/manager/at_client_manager.dart';

class ContactService {
  ContactService._();

  static final ContactService _instance = ContactService._();

  factory ContactService() => _instance;

  late AtContactsImpl atContactImpl;
  late String rootDomain;
  late int rootPort;
  AtContact? loggedInUserDetails;
  late AtClientManager atClientManager;
  late String currentAtsign;

  StreamController<List<AtContact?>> contactStreamController =
      StreamController<List<AtContact?>>.broadcast();

  Sink get contactSink => contactStreamController.sink;

  Stream<List<AtContact?>> get contactStream => contactStreamController.stream;

  StreamController<List<AtContact?>> blockedContactStreamController =
      StreamController<List<AtContact?>>.broadcast();

  Sink get blockedContactSink => blockedContactStreamController.sink;

  Stream<List<AtContact?>> get blockedContactStream =>
      blockedContactStreamController.stream;

  StreamController<List<AtContact?>> selectedContactStreamController =
      StreamController<List<AtContact?>>.broadcast();

  Sink get selectedContactSink => selectedContactStreamController.sink;

  Stream<List<AtContact?>> get selectedContactStream =>
      selectedContactStreamController.stream;

  void disposeControllers() {
    contactStreamController.close();
    selectedContactStreamController.close();
    blockedContactStreamController.close();
  }

  List<AtContact?> contactList = [],
      blockContactList = [],
      selectedContacts = [],
      cachedContactList = [];
  bool isContactPresent = false, limitReached = false;

  String getAtSignError = '';
  bool? checkAtSign;
  List<String> allContactsList = [];

  // ignore: always_declare_return_types
  initContactsService(String rootDomainFromApp, int rootPortFromApp) async {
    loggedInUserDetails = null;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    atClientManager = AtClientManager.getInstance();
    currentAtsign = atClientManager.atClient.getCurrentAtSign()!;
    atContactImpl = await AtContactsImpl.getInstance(currentAtsign);
    loggedInUserDetails = await getAtSignDetails(currentAtsign);
    cachedContactList = await atContactImpl.listContacts();
    await fetchBlockContactList();
  }

  // ignore: always_declare_return_types
  resetData() {
    getAtSignError = '';
    checkAtSign = false;
  }

  // ignore: always_declare_return_types
  Future<List<AtContact?>> fetchContacts() async {
    selectedContacts = [];
    try {
      contactList = [];
      allContactsList = [];
      contactList = await atContactImpl.listContacts();
      var tempContactList = <AtContact?>[...contactList];
      var range = contactList.length;
      for (var i = 0; i < range; i++) {
        allContactsList.add(contactList[i]!.atSign!);
        if (contactList[i]!.blocked!) {
          tempContactList.remove(contactList[i]);
        }
      }
      contactList = tempContactList;
      contactList.sort((a, b) {
        // ignore: omit_local_variable_types
        int? index = a?.atSign
            .toString()
            .substring(1)
            .compareTo(b!.atSign!.toString().substring(1));
        return index!;
      });
      contactSink.add(contactList);
      return contactList;
    } catch (e) {
      print('error here => $e');
      return [];
    }
  }

  // ignore: always_declare_return_types
  blockUnblockContact(
      {required AtContact contact, required bool blockAction}) async {
    try {
      contact.blocked = blockAction;
      await atContactImpl.update(contact);
      await fetchBlockContactList();
      await fetchContacts();
    } catch (error) {
      print('error in unblock: $error');
    }
  }

  // ignore: always_declare_return_types
  fetchBlockContactList() async {
    try {
      blockContactList = [];
      blockContactList = await atContactImpl.listBlockedContacts();
      blockedContactSink.add(blockContactList);
    } catch (error) {
      print('error in fetching contact list:$error');
    }
  }

  // ignore: always_declare_return_types
  deleteAtSign({required String atSign}) async {
    try {
      var result = await atContactImpl.delete(atSign);
      print('delete result => $result');
      fetchContacts();
    } catch (error) {
      print('error in delete atsign:$error');
    }
  }

  Future<bool> addAtSign(
    context, {
    String? atSign,
    String? nickName,
  }) async {
    if (atSign == null || atSign == '') {
      getAtSignError = TextStrings().emptyAtsign;

      return false;
    } else if (atSign[0] != '@') {
      atSign = '@' + atSign;
    }
    atSign = atSign.toLowerCase().trim();

    if (atSign == atClientManager.atClient.getCurrentAtSign()) {
      getAtSignError = TextStrings().addingLoggedInUser;

      return false;
    }
    try {
      isContactPresent = false;

      getAtSignError = '';
      var contact = AtContact();

      checkAtSign = await checkAtsign(atSign);

      if (!checkAtSign!) {
        getAtSignError = TextStrings().unknownAtsign(atSign);
      } else {
        contactList.forEach((element) async {
          if (element!.atSign == atSign) {
            getAtSignError = TextStrings().atsignExists(atSign);
            isContactPresent = true;
            return;
          }
        });
      }
      if (!isContactPresent && checkAtSign!) {
        var details = await getContactDetails(atSign, nickName);
        contact = AtContact(
          atSign: atSign,
          tags: details,
        );
        print('details==>${contact.atSign}');
        var result = await atContactImpl.add(contact).catchError((e) {
          print('error to add contact => $e');
        });
        print(result);
        fetchContacts();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  // ignore: always_declare_return_types
  removeSelectedAtSign(AtContact? contact) {
    try {
      // ignore: omit_local_variable_types
      for (AtContact? atContact in selectedContacts) {
        if (contact == atContact || atContact!.atSign == contact!.atSign) {
          var index = selectedContacts.indexOf(contact);
          print('index is $index');
          selectedContacts.removeAt(index);
          break;
        }
      }
      if (selectedContacts.length <= 25) {
        limitReached = false;
      } else {
        limitReached = true;
      }
      selectedContactSink.add(selectedContacts);
    } catch (error) {
      print(error);
    }
  }

  // ignore: always_declare_return_types
  selectAtSign(AtContact? contact) {
    try {
      if (selectedContacts.length <= 25 &&
          !selectedContacts.contains(contact)) {
        selectedContacts.add(contact);
      } else {
        limitReached = true;
      }
      selectedContactSink.add(selectedContacts);
    } catch (error) {
      print(error);
    }
  }

  // ignore: always_declare_return_types
  clearAtSigns() {
    try {
      selectedContacts = [];
      selectedContactSink.add(selectedContacts);
    } catch (error) {
      print(error);
    }
  }

  Future<bool> checkAtsign(String? atSign) async {
    if (atSign == null) {
      return false;
    } else if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    var checkPresence =
        await AtLookupImpl.findSecondary(atSign, rootDomain, rootPort);
    // ignore: unnecessary_null_comparison
    return checkPresence != null;
  }

  Future<Map<String, dynamic>> getContactDetails(
      String? atSign, String? nickName) async {
    var contactDetails = <String, dynamic>{};

    if (atClientManager.atClient == null || atSign == null) {
      return contactDetails;
    } else if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    var metadata = Metadata();
    metadata.isPublic = true;
    metadata.namespaceAware = false;
    var key = AtKey();
    key.sharedBy = atSign;
    key.metadata = metadata;
    List contactFields = TextStrings().contactFields;

    try {
      // firstname
      key.key = contactFields[0];
      var result = await atClientManager.atClient.get(key).catchError((e) {
        print('error in get ${e.errorCode} ${e.errorMessage}');
      });
      var firstname = result.value;

      // lastname
      key.key = contactFields[1];
      result = await atClientManager.atClient.get(key);
      var lastname = result.value;

      // construct name
      var name = ((firstname ?? '') + ' ' + (lastname ?? '')).trim();
      if (name.length == 0) {
        name = atSign.substring(1);
      }

      // profile picture
      key.metadata?.isBinary = true;
      key.key = contactFields[2];
      result = await atClientManager.atClient.get(key);
      var image = result.value;
      contactDetails['name'] = name;
      contactDetails['image'] = image;
      contactDetails['nickname'] = nickName != '' ? nickName : null;
    } catch (e) {
      contactDetails['name'] = null;
      contactDetails['image'] = null;
      contactDetails['nickname'] = null;
    }
    return contactDetails;
  }
}
