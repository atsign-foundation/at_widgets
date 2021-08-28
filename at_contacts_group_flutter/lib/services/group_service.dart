// ignore: import_of_legacy_library_into_null_safe
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'dart:async';
import 'package:at_contacts_flutter/utils/exposed_service.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_client_mobile/at_client_mobile.dart';

class GroupService {
  GroupService._();
  static final GroupService _instance = GroupService._();
  factory GroupService() => _instance;
  String? _atsign;
  List<AtContact?>? selecteContactList;
  List<GroupContactsModel?> allContacts = <GroupContactsModel?>[], selectedGroupContacts = <GroupContactsModel?>[];
  AtGroup? selectedGroup;
  AtClientImpl? atClientInstance;
  late AtContactsImpl atContactImpl;
  String? rootDomain;
  int? rootPort;
  int length = 0;
  bool? showLoader;

// group list stream
  final StreamController<List<AtGroup>> _atGroupStreamController = StreamController<List<AtGroup>>.broadcast();
  Stream<List<AtGroup>> get atGroupStream => _atGroupStreamController.stream;
  StreamSink<List<AtGroup>> get atGroupSink => _atGroupStreamController.sink;

// group view stream
  final StreamController<AtGroup> _groupViewStreamController = StreamController<AtGroup>.broadcast();
  Stream<AtGroup> get groupViewStream => _groupViewStreamController.stream;
  StreamSink<AtGroup> get groupViewSink => _groupViewStreamController.sink;

// all contacts stream
  final StreamController<List<GroupContactsModel?>> _allContactsStreamController =
      StreamController<List<GroupContactsModel?>>.broadcast();
  Stream<List<GroupContactsModel?>> get allContactsStream => _allContactsStreamController.stream;
  StreamSink<List<GroupContactsModel?>> get allContactsSink => _allContactsStreamController.sink;

  // selected group contact stream
  final StreamController<List<GroupContactsModel?>> _selectedContactsStreamController =
      StreamController<List<GroupContactsModel?>>.broadcast();
  Stream<List<GroupContactsModel?>> get selectedContactsStream => _selectedContactsStreamController.stream;
  StreamSink<List<GroupContactsModel?>> get selectedContactsSink => _selectedContactsStreamController.sink;

  // show loader stream
  final StreamController<bool> _showLoaderStreamController = StreamController<bool>.broadcast();
  Stream<bool> get showLoaderStream => _showLoaderStreamController.stream;
  StreamSink<bool> get showLoaderSink => _showLoaderStreamController.sink;

  String? get currentAtsign => _atsign;

  AtGroup? get currentSelectedGroup => selectedGroup;

  // ignore: always_declare_return_types
  setSelectedContacts(List<AtContact?>? list) {
    selecteContactList = list;
  }

  List<AtContact?>? get selectedContactList => selecteContactList;

  // ignore: always_declare_return_types
  init(AtClientImpl atClientImpl, String atSign, String rootDomainFromApp, int rootPortFromApp) async {
    atClientInstance = atClientImpl;
    _atsign = atSign;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    atContactImpl = await AtContactsImpl.getInstance(atSign);
    await fetchGroupsAndContacts();
  }

  Future<dynamic> createGroup(AtGroup atGroup) async {
    try {
      // ignore: omit_local_variable_types
      AtGroup? group = await atContactImpl.createGroup(atGroup);
      if (group is AtGroup) {
        await updateGroupStreams(group);
        return group;
      }
    } catch (e) {
      print('error in creating group: $e');
      return;
    }
  }

  // ignore: always_declare_return_types
  getAllGroupsDetails() async {
    try {
      List<String?> groupIds = await atContactImpl.listGroupIds();
      List<AtGroup> groupList = <AtGroup>[];

      for (int i = 0; i < groupIds.length; i++) {
        AtGroup? groupDetail = await (getGroupDetail(groupIds[i]!));
        // ignore: unnecessary_null_comparison
        if (groupDetail != null) groupList.add(groupDetail);
      }

      for (AtGroup group in groupList) {
        allContacts.add(GroupContactsModel(group: group, contactType: ContactsType.GROUP));
      }
      atGroupSink.add(groupList);
    } catch (e) {
      print('error in getting group list: $e');
    }
  }

  // ignore: always_declare_return_types
  listAllGroupNames() async {
    try {
      List<String?> groupNames = await atContactImpl.listGroupNames();
      return groupNames;
    } catch (e) {
      return e;
    }
  }

  Future<AtGroup?> getGroupDetail(String groupId) async {
    try {
      AtGroup? group = await atContactImpl.getGroup(groupId);
      return group;
    } catch (e) {
      print('error in getting group details : $e');
      return null;
    }
  }

  Future<dynamic> deletGroupMembers(List<AtContact> contacts, AtGroup group) async {
    try {
      bool result = await atContactImpl.deleteMembers(Set<AtContact>.from(contacts), group);
      if (result is bool) {
        await updateGroupStreams(group);
        return result;
      }
    } catch (e) {
      print('error in deleting group members:$e');
      return e;
    }
  }

  Future<dynamic> addGroupMembers(List<AtContact?> contacts, AtGroup group) async {
    try {
      bool result = await atContactImpl.addMembers(Set<AtContact>.from(contacts), group);
      if (result is bool) {
        await updateGroupStreams(group);
        return result;
      }
    } catch (e) {
      print('error in adding members: $e');
      return e;
    }
  }

  Future<dynamic> updateGroup(AtGroup group) async {
    try {
      AtGroup? updatedGroup = await atContactImpl.updateGroup(group);
      if (updatedGroup is AtGroup) {
        updateGroupStreams(updatedGroup);
        return updatedGroup;
      } else {
        return 'something went wrong';
      }
    } catch (e) {
      print('error in updating group: $e');
      return e;
    }
  }

  // ignore: always_declare_return_types
  updateGroupStreams(AtGroup group) async {
    AtGroup? groupDetail = await (getGroupDetail(group.groupId!));
    if (groupDetail is AtGroup) groupViewSink.add(groupDetail);
    await getAllGroupsDetails();
  }

  Future<bool?> deleteGroup(AtGroup group) async {
    try {
      bool result = await atContactImpl.deleteGroup(group);
      await getAllGroupsDetails(); //updating group list sink
      return result;
    } catch (e) {
      print('error in deleting group: $e');
      return null;
    }
  }

  Future<dynamic> updateGroupData(AtGroup group, BuildContext context) async {
    try {
      dynamic result = await updateGroup(group);
      if (result is AtGroup) {
        Navigator.of(context).pop();
      } else if (result == null) {
        CustomToast().show(TextConstants().SERVICE_ERROR, context);
      } else {
        CustomToast().show(result.toString(), context);
      }
    } catch (e) {
      return e;
    }
  }

  // fetches contacts using the contacts library and groups from itself
  Future<void> fetchGroupsAndContacts() async {
    try {
      allContacts = <GroupContactsModel?>[];
      List<AtContact?> contactList = await fetchContacts();
      // print('CONT====>$contactList');
      for (AtContact? contact in contactList) {
        allContacts.add(GroupContactsModel(contact: contact, contactType: ContactsType.CONTACT));
      }
      await getAllGroupsDetails();
      // print('ALL CONTACTS====>${allContacts[8]}');
      _allContactsStreamController.add(allContacts);
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeGroupContact(GroupContactsModel? item) async {
    try {
      length = 0;
      if (selectedGroupContacts.isNotEmpty) {
        for (GroupContactsModel? groupContact in selectedGroupContacts) {
          if (groupContact!.contactType == ContactsType.CONTACT) {
            length++;
          } else if (groupContact.contactType == ContactsType.GROUP) {
            length = length + groupContact.group!.members!.length;
          }
        }
      }

      // ignore: omit_local_variable_types
      for (GroupContactsModel? groupContact in selectedGroupContacts) {
        if ((groupContact.toString() == item.toString())) {
          int index = selectedGroupContacts.indexOf(groupContact);
          selectedGroupContacts.removeAt(index);
          break;
        }
      }
      if (item!.contactType == ContactsType.CONTACT) {
        length--;
      } else if (item.contactType == ContactsType.GROUP) {
        length -= item.group!.members!.length;
      }

      selectedContactsSink.add(selectedGroupContacts);
    } catch (e) {
      print(e);
    }
  }

  void addGroupContact(GroupContactsModel? item) {
    try {
      bool isSelected = false;
      length = 0;
      if (selectedGroupContacts.isNotEmpty) {
        for (GroupContactsModel? groupContact in selectedGroupContacts) {
          if (groupContact!.contactType == ContactsType.CONTACT) {
            length++;
          } else if (groupContact.contactType == ContactsType.GROUP) {
            length = length + groupContact.group!.members!.length;
          }
        }
      }

      for (GroupContactsModel? groupContact in selectedGroupContacts) {
        if ((item.toString() == groupContact.toString())) {
          isSelected = true;
          break;
        } else {
          isSelected = false;
        }
      }

      if (length <= 25 && !isSelected) {
        selectedGroupContacts.add(item);
      }

      if (item!.contactType == ContactsType.CONTACT) {
        length++;
      } else if (item.contactType == ContactsType.GROUP) {
        length += item.group!.members!.length;
      }

      selectedContactsSink.add(selectedGroupContacts);
    } catch (e) {
      print(e);
    }
  }

  void resetData() {
    allContacts = <GroupContactsModel?>[];
    selectedGroupContacts = <GroupContactsModel?>[];
    selectedContactsSink.add(selectedGroupContacts);
    atGroupSink.add(<AtGroup>[]);
    allContactsSink.add(<GroupContactsModel?>[]);
    showLoaderSink.add(false);
  }

  void dispose() {
    _atGroupStreamController.close();
    _showLoaderStreamController.close();
    _groupViewStreamController.close();
    _allContactsStreamController.close();
    _selectedContactsStreamController.close();
  }
}
