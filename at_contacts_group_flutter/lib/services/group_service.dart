import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'dart:async';
import 'package:at_contacts_flutter/utils/exposed_service.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:flutter/material.dart';

class GroupService {
  GroupService._();
  static GroupService _instance = GroupService._();
  factory GroupService() => _instance;
  String _atsign;
  List<AtContact> selecteContactList;
  List<GroupContactsModel> allContacts = [], selectedGroupContacts = [];
  AtGroup selectedGroup;
  AtContactsImpl atContactImpl;
  int length = 0;

// group list stream
  final _atGroupStreamController = StreamController<List<AtGroup>>.broadcast();
  Stream<List<AtGroup>> get atGroupStream => _atGroupStreamController.stream;
  StreamSink<List<AtGroup>> get atGroupSink => _atGroupStreamController.sink;

// group view stream
  final _groupViewStreamController = StreamController<AtGroup>.broadcast();
  Stream<AtGroup> get groupViewStream => _groupViewStreamController.stream;
  StreamSink<AtGroup> get groupViewSink => _groupViewStreamController.sink;

// all contacts stream
  final _allContactsStreamController =
      StreamController<List<GroupContactsModel>>.broadcast();
  Stream<List<GroupContactsModel>> get allContactsStream =>
      _allContactsStreamController.stream;
  StreamSink<List<GroupContactsModel>> get allContactsSink =>
      _allContactsStreamController.sink;

  // selected group contact stream
  final _selectedContactsStreamController =
      StreamController<List<GroupContactsModel>>.broadcast();
  Stream<List<GroupContactsModel>> get selectedContactsStream =>
      _selectedContactsStreamController.stream;
  StreamSink<List<GroupContactsModel>> get selectedContactsSink =>
      _selectedContactsStreamController.sink;

  get currentAtsign => _atsign;

  get currentSelectedGroup => selectedGroup;

  setSelectedContacts(List<AtContact> list) {
    selecteContactList = list;
  }

  List<AtContact> get selectedContactList => selecteContactList;

  init(String atSign) async {
    _atsign = atSign;
    atContactImpl = await AtContactsImpl.getInstance(atSign);
    await atContactImpl.listContacts();
    // print('test => $test');
    await getAllGroupsDetails();
  }

  Future<dynamic> createGroup(AtGroup atGroup) async {
    try {
      AtGroup group = await atContactImpl.createGroup(atGroup);
      if (group != null) {
        await updateGroupStreams(group);
        return group;
      }
    } catch (e) {
      print('error in creating group: $e');
      return e;
    }
  }

  getAllGroupsDetails() async {
    try {
      List<String> groupNames = await atContactImpl.listGroupNames();
      List<AtGroup> groupList = [];
      // allContacts = [];

      for (int i = 0; i < groupNames.length; i++) {
        AtGroup groupDetail = await getGroupDetail(groupNames[i]);
        if (groupDetail != null) groupList.add(groupDetail);
      }

      groupList.forEach((AtGroup group) {
        allContacts.add(
            GroupContactsModel(group: group, contactType: ContactsType.GROUP));
      });
      atGroupSink.add(groupList);
    } catch (e) {
      print('error in getting group list: $e');
    }
  }

  listAllGroupNames() async {
    try {
      List<String> groupNames = await atContactImpl.listGroupNames();
      return groupNames;
    } catch (e) {
      return e;
    }
  }

  Future<dynamic> getGroupDetail(String groupName) async {
    try {
      AtGroup group = await atContactImpl.getGroup(groupName);
      return group;
    } catch (e) {
      print('error in getting group details : $e');
      return e;
    }
  }

  Future<dynamic> deletGroupMembers(
      List<AtContact> contacts, AtGroup group) async {
    try {
      bool result =
          await atContactImpl.deleteMembers(Set.from(contacts), group);
      if (result is bool) {
        await updateGroupStreams(group);
        return result;
      }
    } catch (e) {
      print('error in deleting group members:$e');
      return e;
    }
  }

  Future<dynamic> addGroupMembers(
      List<AtContact> contacts, AtGroup group) async {
    try {
      bool result = await atContactImpl.addMembers(Set.from(contacts), group);
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
      AtGroup updatedGroup = await atContactImpl.updateGroup(group);
      if (updatedGroup is AtGroup) {
        updateGroupStreams(updatedGroup);
        return updatedGroup;
      } else
        return 'something went wrong';
    } catch (e) {
      print('error in updating group: $e');
      return e;
    }
  }

  updateGroupStreams(AtGroup group) async {
    AtGroup groupDetail = await getGroupDetail(group.name);
    if (groupDetail != null) groupViewSink.add(groupDetail);
    await getAllGroupsDetails();
  }

  Future<dynamic> deleteGroup(AtGroup group) async {
    try {
      var result = await atContactImpl.deleteGroup(group);
      await getAllGroupsDetails(); //updating group list sink
      return result;
    } catch (e) {
      print('error in deleting group: $e');
      return e;
    }
  }

  Future<dynamic> updateGroupData(AtGroup group, BuildContext context) async {
    try {
      var result = await updateGroup(group);
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
  fetchGroupsAndContacts() async {
    try {
      allContacts = [];
      List<AtContact> contactList = await fetchContacts();
      print('CONT====>$contactList');
      contactList.forEach((AtContact contact) {
        allContacts.add(GroupContactsModel(
            contact: contact, contactType: ContactsType.CONTACT));
      });
      await getAllGroupsDetails();
      print('ALL CONTACTS====>${allContacts.length}');
      _allContactsStreamController.add(allContacts);
    } catch (e) {}
  }

  removeGroupContact(GroupContactsModel item) async {
    try {
      length = 0;
      if (selectedGroupContacts.isNotEmpty) {
        selectedGroupContacts.forEach((groupContact) {
          if (groupContact.contactType == ContactsType.CONTACT) {
            length++;
          } else if (groupContact.contactType == ContactsType.GROUP) {
            length = length + groupContact.group.members.length;
          }
        });
      }

      for (GroupContactsModel groupContact in selectedGroupContacts) {
        if ((groupContact.toString() == item.toString())) {
          int index = selectedGroupContacts.indexOf(groupContact);
          selectedGroupContacts.removeAt(index);
          break;
        }
      }
      if (item.contactType == ContactsType.CONTACT) {
        length--;
      } else if (item.contactType == ContactsType.GROUP) {
        length -= item.group.members.length;
      }

      selectedContactsSink.add(selectedGroupContacts);
    } catch (e) {}
  }

  addGroupContact(GroupContactsModel item) {
    try {
      bool isSelected = false;
      length = 0;
      if (selectedGroupContacts.isNotEmpty) {
        selectedGroupContacts.forEach((groupContact) {
          if (groupContact.contactType == ContactsType.CONTACT) {
            length++;
          } else if (groupContact.contactType == ContactsType.GROUP) {
            length = length + groupContact.group.members.length;
          }
        });
      }

      for (GroupContactsModel groupContact in selectedGroupContacts) {
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

      if (item.contactType == ContactsType.CONTACT) {
        length++;
      } else if (item.contactType == ContactsType.GROUP) {
        length += item.group.members.length;
      }

      selectedContactsSink.add(selectedGroupContacts);
    } catch (e) {}
  }

  // updateGroupWithoutNameChange(
  //     BuildContext context, AtGroup group, String newGroupName) async {
  //   group.name = newGroupName;
  //   var result = await updateGroup(group);
  //   if (result is AtGroup) {
  //     Navigator.of(context).pop();
  //   } else if (result == null) {
  //     CustomToast().show(TextConstants().SERVICE_ERROR, context);
  //   } else {
  //     CustomToast().show(result.toString(), context);
  //   }
  // }

  // updateGroupWithNameChange(
  //     BuildContext context, AtGroup group, String newGroupName) async {
  //   AtGroup newGroup = new AtGroup(
  //     newGroupName,
  //     description: group.description,
  //     groupPicture: group.groupPicture,
  //     members: group.members,
  //     tags: group.tags,
  //     createdOn: group.createdOn,
  //     createdBy: group.createdBy,
  //     updatedOn: group.updatedOn,
  //     updatedBy: group.updatedBy,
  //   );

  //   // creating new group
  //   var createGroupResult = await createGroup(newGroup);
  //   if (createGroupResult is AtGroup) {
  //     //deleting previous group
  //     var deleteGroupResult = await deleteGroup(group);
  //     if (deleteGroupResult is bool) {
  //       // updating streams
  //       await updateGroupStreams(newGroup);
  //       Navigator.of(context).pop();
  //     } else if (deleteGroupResult != null) {
  //       CustomToast().show(deleteGroupResult.toString(), context);
  //     } else {
  //       CustomToast().show(TextConstants().SERVICE_ERROR, context);
  //     }
  //   } else if (createGroupResult != null) {
  //     CustomToast().show(createGroupResult.toString(), context);
  //   } else {
  //     CustomToast().show(TextConstants().SERVICE_ERROR, context);
  //   }
  // }

  void dispose() {
    _atGroupStreamController.close();
    _groupViewStreamController.close();
    _allContactsStreamController.close();
    _selectedContactsStreamController.close();
  }
}
