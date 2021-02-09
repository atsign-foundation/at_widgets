/// A service to handle CRUD operation on contacts

import 'dart:async';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';

class ContactService {
  ContactService._();
  static ContactService _instance = ContactService._();
  factory ContactService() => _instance;

  static AtContactsImpl atContactImpl;
  AtClientImpl atClientInstance;
  String rootDomain;
  int rootPort;

  StreamController<List<AtContact>> contactStreamController =
      StreamController<List<AtContact>>.broadcast();
  Sink get contactSink => contactStreamController.sink;
  Stream<List<AtContact>> get contactStream => contactStreamController.stream;

  StreamController<List<AtContact>> blockedContactStreamController =
      StreamController<List<AtContact>>.broadcast();
  Sink get blockedContactSink => blockedContactStreamController.sink;
  Stream<List<AtContact>> get blockedContactStream =>
      blockedContactStreamController.stream;

  StreamController<List<AtContact>> selectedContactStreamController =
      StreamController<List<AtContact>>.broadcast();
  Sink get selectedContactSink => selectedContactStreamController.sink;
  Stream<List<AtContact>> get selectedContactStream =>
      selectedContactStreamController.stream;

  disposeControllers() {
    contactStreamController.close();
    selectedContactStreamController.close();
    blockedContactStreamController.close();
  }

  List<AtContact> contactList, blockContactList, selectedContacts = [];
  bool isContactPresent, limitReached = false;

  String getAtSignError = '';
  bool checkAtSign;
  List<String> allContactsList = [];

  initContactsService(
      AtClientImpl atClientInstanceFromApp,
      String currentAtSign,
      String rootDomainFromApp,
      int rootPortFromApp) async {
    atClientInstance = atClientInstanceFromApp;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    atContactImpl = await AtContactsImpl.getInstance(currentAtSign);
  }

  fetchContacts() async {
    try {
      contactList = [];
      allContactsList = [];
      contactList = await atContactImpl.listContacts();
      List<AtContact> tempContactList = [...contactList];
      int range = contactList.length;
      for (int i = 0; i < range; i++) {
        allContactsList.add(contactList[i].atSign);
        if (contactList[i].blocked) {
          tempContactList.remove(contactList[i]);
        }
      }
      contactList = tempContactList;
      contactList.sort(
          (a, b) => a.atSign.substring(1).compareTo(b.atSign.substring(1)));
      contactSink.add(contactList);
      return contactList;
    } catch (e) {
      print("error here => $e");
    }
  }

  blockUnblockContact({AtContact contact, bool blockAction}) async {
    try {
      contact.blocked = blockAction;
      await atContactImpl.update(contact);
      await fetchBlockContactList();
      await fetchContacts();
    } catch (error) {}
  }

  fetchBlockContactList() async {
    try {
      blockContactList = [];
      blockContactList = await atContactImpl.listBlockedContacts();
      print("fetchBlockContactList => $blockContactList");
      blockedContactSink.add(blockContactList);
    } catch (error) {}
  }

  deleteAtSign({String atSign}) async {
    try {
      var result = await atContactImpl.delete(atSign);
      print("delete result => $result");
      fetchContacts();
    } catch (error) {}
  }

  addAtSign(context, {String atSign}) async {
    if (atSign == null || atSign == '') {
      getAtSignError = TextStrings().emptyAtsign;

      return true;
    } else if (atSign[0] != '@') {
      atSign = '@' + atSign;
    }

    try {
      isContactPresent = false;

      getAtSignError = '';
      AtContact contact = AtContact();

      checkAtSign = await checkAtsign(atSign);

      if (!checkAtSign) {
        getAtSignError = TextStrings().unknownAtsign(atSign);
      } else {
        contactList.forEach((element) async {
          if (element.atSign == atSign) {
            getAtSignError = TextStrings().atsignExists(atSign);
            isContactPresent = true;
            return true;
          }
        });
      }
      if (!isContactPresent && checkAtSign) {
        var details = await getContactDetails(atSign);
        contact = AtContact(
          atSign: atSign,
          tags: details,
        );

        var result = await atContactImpl
            .add(contact)
            .catchError((e) => print('error to add contact => $e'));
        print(result);
        fetchContacts();
      }
    } catch (e) {}
  }

  removeSelectedAtSign(AtContact contact) {
    try {
      selectedContacts.remove(contact);
      if (selectedContacts.length <= 25) {
        limitReached = false;
      } else {
        limitReached = true;
      }
      selectedContactSink.add(selectedContacts);
    } catch (error) {}
  }

  selectAtSign(AtContact contact) {
    try {
      if (selectedContacts.length <= 25 &&
          !selectedContacts.contains(contact)) {
        selectedContacts.add(contact);
      } else {
        limitReached = true;
      }
      selectedContactSink.add(selectedContacts);
    } catch (error) {}
  }

  clearAtSigns() {
    try {
      selectedContacts = [];
      selectedContactSink.add(selectedContacts);
    } catch (error) {}
  }

  Future<bool> checkAtsign(String atSign) async {
    if (atSign == null) {
      return false;
    } else if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    var checkPresence =
        await AtLookupImpl.findSecondary(atSign, rootDomain, rootPort);
    return checkPresence != null;
  }

  Future<Map<String, dynamic>> getContactDetails(String atSign) async {
    Map<String, dynamic> contactDetails = {};

    if (atClientInstance == null || atSign == null) {
      return contactDetails;
    } else if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    var metadata = Metadata();
    metadata.isPublic = true;
    metadata.namespaceAware = false;
    AtKey key = AtKey();
    key.sharedBy = atSign;
    key.metadata = metadata;
    List contactFields = TextStrings().contactFields;

    try {
      // firstname
      key.key = contactFields[0];
      var result = await atClientInstance.get(key).catchError(
          (e) => print("error in get ${e.errorCode} ${e.errorMessage}"));
      var firstname = result.value;

      // lastname
      key.key = contactFields[1];
      result = await atClientInstance.get(key);
      var lastname = result.value;

      // construct name
      var name = ((firstname ?? '') + ' ' + (lastname ?? '')).trim();
      if (name.length == 0) {
        name = atSign.substring(1);
      }

      // profile picture
      key.metadata.isBinary = true;
      key.key = contactFields[2];
      result = await atClientInstance.get(key);
      var image = result.value;
      contactDetails['name'] = name;
      contactDetails['image'] = image;
    } catch (e) {
      contactDetails['name'] = null;
      contactDetails['image'] = null;
    }
    return contactDetails;
  }
}
