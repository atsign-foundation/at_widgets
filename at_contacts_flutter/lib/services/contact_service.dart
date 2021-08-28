/// A service to handle CRUD operation on contacts

import 'dart:async';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:flutter/material.dart';

class ContactService {
  ContactService._();

  static final ContactService _instance = ContactService._();

  factory ContactService() => _instance;

  late AtContactsImpl atContactImpl;
  AtClientImpl? atClientInstance;
  late String rootDomain;
  late int rootPort;
  AtContact? loggedInUserDetails;

  StreamController<List<AtContact?>> contactStreamController = StreamController<List<AtContact?>>.broadcast();

  Sink<List<AtContact?>> get contactSink => contactStreamController.sink;

  Stream<List<AtContact?>> get contactStream => contactStreamController.stream;

  StreamController<List<AtContact?>> blockedContactStreamController = StreamController<List<AtContact?>>.broadcast();

  Sink<List<AtContact?>> get blockedContactSink => blockedContactStreamController.sink;

  Stream<List<AtContact?>> get blockedContactStream => blockedContactStreamController.stream;

  StreamController<List<AtContact?>> selectedContactStreamController = StreamController<List<AtContact?>>.broadcast();

  Sink<List<AtContact?>> get selectedContactSink => selectedContactStreamController.sink;

  Stream<List<AtContact?>> get selectedContactStream => selectedContactStreamController.stream;

  void disposeControllers() {
    contactStreamController.close();
    selectedContactStreamController.close();
    blockedContactStreamController.close();
  }

  List<AtContact?> contactList = <AtContact?>[],
      blockContactList = <AtContact?>[],
      selectedContacts = <AtContact?>[],
      cachedContactList = <AtContact?>[];
  bool isContactPresent = false, limitReached = false;

  String getAtSignError = '';
  bool? checkAtSign;
  List<String> allContactsList = <String>[];

  // ignore: always_declare_return_types
  initContactsService(
      AtClientImpl atClientInstanceFromApp, String currentAtSign, String rootDomainFromApp, int rootPortFromApp) async {
    loggedInUserDetails = null;
    atClientInstance = atClientInstanceFromApp;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    atContactImpl = await AtContactsImpl.getInstance(currentAtSign);
    loggedInUserDetails = await getAtSignDetails(currentAtSign);
    cachedContactList = await atContactImpl.listContacts();
    await fetchBlockContactList();
  }

  // ignore: always_declare_return_types
  resetData() {
    getAtSignError = '';
    checkAtSign = false;
  }

  Future<List<AtContact?>> fetchContacts() async {
    selectedContacts = <AtContact?>[];
    try {
      contactList = <AtContact?>[];
      allContactsList = <String>[];
      contactList = await atContactImpl.listContacts();
      List<AtContact?> tempContactList = <AtContact?>[...contactList];
      int range = contactList.length;
      for (int i = 0; i < range; i++) {
        allContactsList.add(contactList[i]!.atSign!);
        if (contactList[i]!.blocked!) {
          tempContactList.remove(contactList[i]);
        }
      }
      contactList = tempContactList;
      contactList.sort((AtContact? a, AtContact? b) {
        int? index = a?.atSign.toString().substring(1).compareTo(b!.atSign!.toString().substring(1));
        return index!;
      });
      contactSink.add(contactList);
      return contactList;
    } catch (e) {
      print('error here => $e');
      return <AtContact?>[];
    }
  }

  // ignore: always_declare_return_types
  blockUnblockContact({required AtContact contact, required bool blockAction}) async {
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
      blockContactList = <AtContact?>[];
      blockContactList = await atContactImpl.listBlockedContacts();
      blockedContactSink.add(blockContactList);
    } catch (error) {
      print('error in fetching contact list:$error');
    }
  }

  // ignore: always_declare_return_types
  deleteAtSign({required String atSign}) async {
    try {
      bool result = await atContactImpl.delete(atSign);
      print('delete result => $result');
      await fetchContacts();
    } catch (error) {
      print('error in delete atsign:$error');
    }
  }

  Future<dynamic> addAtSign(
    BuildContext context, {
    String? atSign,
    String? nickName,
  }) async {
    if (atSign == null || atSign == '') {
      getAtSignError = TextStrings().emptyAtsign;

      return true;
    } else if (atSign[0] != '@') {
      atSign = '@' + atSign;
    }
    atSign = atSign.toLowerCase().trim();

    if (atSign == atClientInstance?.currentAtSign) {
      getAtSignError = TextStrings().addingLoggedInUser;

      return true;
    }
    try {
      isContactPresent = false;

      getAtSignError = '';
      AtContact contact = AtContact();

      checkAtSign = await checkAtsign(atSign);

      if (!checkAtSign!) {
        getAtSignError = TextStrings().unknownAtsign(atSign);
      } else {
        for (AtContact? element in contactList) {
          if (element!.atSign == atSign) {
            getAtSignError = TextStrings().atsignExists(atSign);
            isContactPresent = true;
            return;
          }
        }
      }
      if (!isContactPresent && checkAtSign!) {
        Map<String, dynamic> details = await getContactDetails(atSign, nickName);
        contact = AtContact(
          atSign: atSign,
          tags: details,
        );
        print('details ==> ${contact.atSign}');
        bool result = await atContactImpl.add(contact).catchError((dynamic e) {
          print('error to add contact => $e');
        });
        print(result);
        await fetchContacts();
      }
    } catch (e) {
      print(e);
    }
  }

  // ignore: always_declare_return_types
  removeSelectedAtSign(AtContact? contact) {
    try {
      // ignore: omit_local_variable_types
      for (AtContact? atContact in selectedContacts) {
        if (contact == atContact || atContact!.atSign == contact!.atSign) {
          int index = selectedContacts.indexOf(contact);
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
      if (selectedContacts.length <= 25 && !selectedContacts.contains(contact)) {
        selectedContacts.add(contact);
      } else {
        limitReached = true;
      }
      selectedContactSink.add(selectedContacts);
    } catch (error) {
      print(error);
    }
  }

  void clearAtSigns() {
    try {
      selectedContacts = <AtContact?>[];
      selectedContactSink.add(selectedContacts);
    } catch (error) {
      print(error.toString());
    }
  }

  Future<bool> checkAtsign(String? atSign) async {
    if (atSign == null) {
      return false;
    } else if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    String? checkPresence = await AtLookupImpl.findSecondary(atSign, rootDomain, rootPort);
    // ignore: unnecessary_null_comparison
    return checkPresence != null;
  }

  Future<Map<String, dynamic>> getContactDetails(String? atSign, String? nickName) async {
    Map<String, dynamic> contactDetails = <String, dynamic>{};

    if (atClientInstance == null || atSign == null) {
      return contactDetails;
    } else if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    Metadata metadata = Metadata();
    metadata.isPublic = true;
    metadata.namespaceAware = false;
    AtKey key = AtKey();
    key.sharedBy = atSign;
    key.metadata = metadata;
    List<String> contactFields = TextStrings().contactFields;

    try {
      // firstname
      key.key = contactFields[0];
      AtValue result = await atClientInstance!.get(key).catchError((dynamic e) {
        print('error in get ${e.errorCode} ${e.errorMessage}');
      });
      dynamic firstname = result.value;

      // lastname
      key.key = contactFields[1];
      result = await atClientInstance!.get(key);
      dynamic lastname = result.value;

      // construct name
      String name = ((firstname ?? '') + ' ' + (lastname ?? '')).trim();
      if (name.isEmpty) {
        name = atSign.substring(1);
      }

      // profile picture
      key.metadata?.isBinary = true;
      key.key = contactFields[2];
      result = await atClientInstance!.get(key);
      dynamic image = result.value;
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
