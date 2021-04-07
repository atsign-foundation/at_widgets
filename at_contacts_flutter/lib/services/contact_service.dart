/// A service to handle CRUD operation on contacts

import 'dart:async';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';

class ContactService {
  ContactService._();
  static ContactService _instance = ContactService._();
  factory ContactService() => _instance;

  AtContactsImpl atContactImpl;
  AtClientImpl atClientInstance;
  String rootDomain;
  int rootPort;
  AtContact loggedInUserDetails;

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

  List<AtContact> contactList = [],
      blockContactList = [],
      selectedContacts = [],
      cachedContactList = [];
  bool isContactPresent, limitReached = false;

  String getAtSignError = '';
  bool checkAtSign;
  List<String> allContactsList = [];

  initContactsService(
      AtClientImpl atClientInstanceFromApp,
      String currentAtSign,
      String rootDomainFromApp,
      int rootPortFromApp) async {
    loggedInUserDetails = null;
    atClientInstance = atClientInstanceFromApp;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    atContactImpl = await AtContactsImpl.getInstance(currentAtSign);
    loggedInUserDetails = await getAtSignDetails(currentAtSign);
    cachedContactList = await atContactImpl.listContacts();
  }

  resetData() {
    getAtSignError = '';
    checkAtSign = false;
  }

  fetchContacts() async {
    selectedContacts = [];
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
      contactList.sort((a, b) => a?.atSign
          .toString()
          ?.substring(1)
          ?.compareTo(b?.atSign.toString()?.substring(1)));
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
    } catch (error) {
      print('error in unblock: $error');
    }
  }

  fetchBlockContactList() async {
    try {
      blockContactList = [];
      blockContactList = await atContactImpl.listBlockedContacts();
      blockedContactSink.add(blockContactList);
    } catch (error) {
      print('error in fetching contact list:$error');
    }
  }

  deleteAtSign({String atSign}) async {
    try {
      var result = await atContactImpl.delete(atSign);
      print("delete result => $result");
      fetchContacts();
    } catch (error) {
      print('error in delete atsign:$error');
    }
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
        print('details==>${contact.atSign}');
        var result = await atContactImpl.add(contact).catchError((e) {
          print('error to add contact => $e');
        });
        print(result);
        fetchContacts();
      }
    } catch (e) {
      print(e);
    }
  }

  removeSelectedAtSign(AtContact contact) {
    try {
      for (AtContact atContact in selectedContacts) {
        if (contact == atContact || atContact.atSign == contact.atSign) {
          int index = selectedContacts.indexOf(contact);
          print("index is $index");
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

  selectAtSign(AtContact contact) {
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

  clearAtSigns() {
    try {
      selectedContacts = [];
      selectedContactSink.add(selectedContacts);
    } catch (error) {
      print(error);
    }
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
      var result = await atClientInstance.get(key).catchError((e) {
        print("error in get ${e.errorCode} ${e.errorMessage}");
      });
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
