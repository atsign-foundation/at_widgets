// ignore_for_file: avoid_print

import 'dart:async';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/models/contact_base_model.dart';
import 'package:at_contacts_flutter/utils/init_contacts_service.dart';
import 'package:at_lookup/at_lookup.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:at_client/at_client.dart';

/// A service to handle CRUD operation on contacts
class ContactService {
  /// Singleton instance declaration
  ContactService._();

  static final ContactService _instance = ContactService._();

  /// Factory pattern to get singleton instance
  factory ContactService() => _instance;

  /// Instance of at_contact dart library
  late AtContactsImpl atContactImpl;

  /// Root domain to access
  late String rootDomain;

  /// Root port to access
  late int rootPort;

  /// Current atsign's contact details
  AtContact? loggedInUserDetails;

  /// Instance of AtClientManager
  late AtClientManager atClientManager;

  /// Current atsign in use
  late String currentAtsign;

  /// Stream controller for contacts' list stream
  StreamController<List<BaseContact?>> contactStreamController =
      StreamController<List<BaseContact?>>.broadcast();

  /// Sink for the contacts' list stream
  Sink get contactSink => contactStreamController.sink;

  /// Stream of contacts' list
  Stream<List<BaseContact?>> get contactStream =>
      contactStreamController.stream;

  /// Stream controller for blocked contacts' list stream
  StreamController<List<BaseContact?>> blockedContactStreamController =
      StreamController<List<BaseContact?>>.broadcast();

  /// Sink for the blocked contacts' list stream
  Sink get blockedContactSink => blockedContactStreamController.sink;

  /// Stream of blocked contacts' list
  Stream<List<BaseContact?>> get blockedContactStream =>
      blockedContactStreamController.stream;

  /// Stream controller for selected contacts' list stream
  StreamController<List<AtContact?>> selectedContactStreamController =
      StreamController<List<AtContact?>>.broadcast();

  /// Sink for the selected contacts' list stream
  Sink get selectedContactSink => selectedContactStreamController.sink;

  /// Stream of selected contacts' list
  Stream<List<AtContact?>> get selectedContactStream =>
      selectedContactStreamController.stream;

  /// dispose function for all the stream controllers declared
  void disposeControllers() {
    contactStreamController.close();
    selectedContactStreamController.close();
    blockedContactStreamController.close();
  }

  List<BaseContact> baseContactList = [], baseBlockedList = [];

  /// List of contacts added by atsign
  List<AtContact> contactList = [],

      /// List of blocked contacts added by atsign
      blockContactList = [],

      /// List of selected contacts added by atsign
      selectedContacts = [],

      /// Cached list of contacts added by atsign
      cachedContactList = [];

  /// Boolean flag to indicate a contact's presence
  bool isContactPresent = false,

      /// Limit indicator for contact selection
      limitReached = false;

  /// Error thrown in fetching an atsign
  String getAtSignError = '';

  /// Boolean indicator for validating atsign
  bool? checkAtSign;

  /// List of all contacts added by atsign
  List<String> allContactsList = [];

  Future<void> initContactsService(
      String rootDomainFromApp, int rootPortFromApp) async {
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

  void resetData() {
    getAtSignError = '';
    checkAtSign = false;
  }

  Future<List<AtContact>?> fetchContacts() async {
    try {
      selectedContacts = [];
      contactList = [];
      allContactsList = [];
      contactList = await atContactImpl.listContacts();
      var tempContactList = <AtContact>[...contactList];
      var range = contactList.length;
      for (var i = 0; i < range; i++) {
        allContactsList.add(contactList[i].atSign!);
        if (contactList[i].blocked!) {
          tempContactList.remove(contactList[i]);
        }
      }
      contactList = tempContactList;
      contactList.sort((a, b) {
        int? index = a.atSign
            .toString()
            .substring(1)
            .compareTo(b.atSign!.toString().substring(1));
        return index;
      });

      compareContactListForUpdatedState();
      contactSink.add(baseContactList);
      return contactList;
    } catch (e) {
      print('error in fetchContacts => $e');
      return null;
    }
  }

  void compareContactListForUpdatedState() {
    for (var c in contactList) {
      var index =
          baseContactList.indexWhere((e) => e.contact!.atSign == c.atSign);
      if (index > -1) {
        baseContactList[index] = BaseContact(
          c,
          isBlocking: baseContactList[index].isBlocking,
          isMarkingFav: baseContactList[index].isMarkingFav,
          isDeleting: baseContactList[index].isDeleting,
        );
      } else {
        baseContactList.add(
          BaseContact(
            c,
            isBlocking: false,
            isMarkingFav: false,
            isDeleting: false,
          ),
        );
      }
    }

    // checking to remove deleted atsigns from baseContactList.
    var atsignsToRemove = <String>[];
    for (var baseContact in baseContactList) {
      var index = contactList.indexWhere(
        (e) => e.atSign == baseContact.contact!.atSign,
      );
      if (index == -1) {
        atsignsToRemove.add(baseContact.contact!.atSign!);
      }
    }
    for (var e in atsignsToRemove) {
      baseContactList.removeWhere((element) => element.contact!.atSign == e);
    }
  }

  Future<bool> blockUnblockContact(
      {required AtContact contact, required bool blockAction}) async {
    try {
      contact.blocked = blockAction;
      var res = await atContactImpl.update(contact);
      if (res) {
        await fetchBlockContactList();
        await fetchContacts();
        return res;
      } else {
        return false;
      }
    } catch (error) {
      print('error in unblock: $error');
      return false;
    }
  }

  Future<bool> markFavContact(AtContact contact) async {
    try {
      contact.favourite = !contact.favourite!;
      var res = await atContactImpl.update(contact);
      if (res) {
        await fetchBlockContactList();
        await fetchContacts();
        return res;
      } else {
        return false;
      }
    } catch (error) {
      print('error in marking fav: $error');
      return false;
    }
  }

  Future<List<AtContact>?> fetchBlockContactList() async {
    try {
      blockContactList = [];
      blockContactList = await atContactImpl.listBlockedContacts();
      compareBlockedContactListForUpdatedState();
      blockedContactSink.add(baseBlockedList);
      return blockContactList;
    } catch (error) {
      print('error in fetching contact list:$error');
      return null;
    }
  }

  void compareBlockedContactListForUpdatedState() {
    for (var c in blockContactList) {
      var index =
          baseBlockedList.indexWhere((e) => e.contact!.atSign == c.atSign);
      if (index > -1) {
        baseBlockedList[index] = BaseContact(
          c,
          isBlocking: baseBlockedList[index].isBlocking,
          isMarkingFav: baseBlockedList[index].isMarkingFav,
          isDeleting: baseBlockedList[index].isDeleting,
        );
      } else {
        baseBlockedList.add(
          BaseContact(
            c,
            isBlocking: false,
            isMarkingFav: false,
            isDeleting: false,
          ),
        );
      }
    }

    // checking to remove unblocked atsigns from baseBlockedList.
    var atsignsToRemove = <String>[];
    for (var baseContact in baseBlockedList) {
      var index = blockContactList.indexWhere(
        (e) => e.atSign == baseContact.contact!.atSign,
      );
      if (index == -1) {
        atsignsToRemove.add(baseContact.contact!.atSign!);
      }
    }
    for (var e in atsignsToRemove) {
      baseBlockedList.removeWhere((element) => element.contact!.atSign == e);
    }
  }

  Future<bool> deleteAtSign({required String atSign}) async {
    try {
      var result = await atContactImpl.delete(atSign);
      print('delete result => $result');
      fetchContacts();
      return result;
    } catch (error) {
      print('error in delete atsign:$error');
      return false;
    }
  }

  /// Function to validate, fetch details and save to current atsign's contact list
  Future<bool> addAtSign({
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
        for (var element in contactList) {
          if (element.atSign == atSign) {
            getAtSignError = TextStrings().atsignExists(atSign);
            isContactPresent = true;
            break;
          }
        }
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

  void removeSelectedAtSign(AtContact? contact) {
    try {
      for (AtContact? atContact in selectedContacts) {
        if (contact == atContact || atContact!.atSign == contact!.atSign) {
          var index = selectedContacts.indexOf(contact!);
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

  void selectAtSign(AtContact? contact) {
    try {
      if (selectedContacts.length <= 25 &&
          !selectedContacts.contains(contact)) {
        selectedContacts.add(contact!);
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
      selectedContacts = [];
      selectedContactSink.add(selectedContacts);
    } catch (error) {
      print(error);
    }
  }

  /// Function to validate atsign
  Future<bool> checkAtsign(String? atSign) async {
    if (atSign == null) {
      return false;
    } else if (!atSign.contains('@')) {
      atSign = '@' + atSign;
    }
    var checkPresence =
        await AtLookupImpl.findSecondary(atSign, rootDomain, rootPort);
    return checkPresence != null;
  }

  /// Function to get firstname, lastname and profile picture of an atsign
  Future<Map<String, dynamic>> getContactDetails(
      String? atSign, String? nickName) async {
    var contactDetails = <String, dynamic>{};

    if (atClientManager.atClient.getCurrentAtSign() == null || atSign == null) {
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

  void updateState(STATE_UPDATE stateToUpdate, AtContact contact, bool state) {
    int indexToUpdate;
    if (stateToUpdate == STATE_UPDATE.unblock) {
      indexToUpdate = baseBlockedList
          .indexWhere((element) => element.contact!.atSign == contact.atSign);
    } else {
      indexToUpdate = baseContactList
          .indexWhere((element) => element.contact!.atSign == contact.atSign);
    }

    if (indexToUpdate == -1) {
      throw Exception('index range error: $indexToUpdate');
    }

    switch (stateToUpdate) {
      case STATE_UPDATE.block:
        baseContactList[indexToUpdate].isBlocking = state;
        break;
      case STATE_UPDATE.unblock:
        baseBlockedList[indexToUpdate].isBlocking = state;
        break;
      case STATE_UPDATE.delete:
        baseContactList[indexToUpdate].isDeleting = state;
        break;
      case STATE_UPDATE.markFav:
        baseContactList[indexToUpdate].isMarkingFav = state;
        break;
      default:
    }

    if (stateToUpdate == STATE_UPDATE.unblock) {
      blockedContactSink.add(baseBlockedList);
    } else {
      contactSink.add(baseContactList);
    }
  }
}
