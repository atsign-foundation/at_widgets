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

/// Service to handle CRUD operations on groups
class GroupService {
  /// Singleton instance of the service
  GroupService._();
  static final GroupService _instance = GroupService._();
  factory GroupService() => _instance;

  /// current atsign
  late String _atsign;

  /// selected contact list for the group
  List<AtContact?>? selecteContactList;

  /// List of all the contacts for the atsign
  List<GroupContactsModel?> allContacts = [],

      /// List of contacts of the selected group
      selectedGroupContacts = [];

  /// Details of the selected group
  AtGroup? selectedGroup;

  /// Instance of AtClientManager
  late AtClientManager atClientManager;

  /// Instance of AtContactsImpl
  late AtContactsImpl atContactImpl;

  /// Root domain to use
  String? rootDomain;

  /// Root port to use
  int? rootPort;
  int length = 0;

  /// Boolean flag to control loader
  bool? showLoader;

  /// Controller for group list stream
  final _atGroupStreamController = StreamController<List<AtGroup>>.broadcast();

  /// Group list stream
  Stream<List<AtGroup>> get atGroupStream => _atGroupStreamController.stream;

  /// Sink for group list stream
  StreamSink<List<AtGroup>> get atGroupSink => _atGroupStreamController.sink;

  /// Controller for group view stream
  final _groupViewStreamController = StreamController<AtGroup>.broadcast();

  /// Group view stream
  Stream<AtGroup> get groupViewStream => _groupViewStreamController.stream;

  /// Sink for group view stream
  StreamSink<AtGroup> get groupViewSink => _groupViewStreamController.sink;

  /// Controller for all contacts stream
  final StreamController<List<GroupContactsModel?>>
      _allContactsStreamController =
      StreamController<List<GroupContactsModel?>>.broadcast();

  /// all contacts stream
  Stream<List<GroupContactsModel?>> get allContactsStream =>
      _allContactsStreamController.stream;

  /// Sink for all contacts stream
  StreamSink<List<GroupContactsModel?>> get allContactsSink =>
      _allContactsStreamController.sink;

  /// Controller for selected group contact stream
  final _selectedContactsStreamController =
      StreamController<List<GroupContactsModel?>>.broadcast();

  /// Selected group contact stream
  Stream<List<GroupContactsModel?>> get selectedContactsStream =>
      _selectedContactsStreamController.stream;

  /// Sink for selected group contact stream
  StreamSink<List<GroupContactsModel?>> get selectedContactsSink =>
      _selectedContactsStreamController.sink;

  // show loader stream
  final _showLoaderStreamController = StreamController<bool>.broadcast();
  Stream<bool> get showLoaderStream => _showLoaderStreamController.stream;
  StreamSink<bool> get showLoaderSink => _showLoaderStreamController.sink;

  String? get currentAtsign => _atsign;

  AtGroup? get currentSelectedGroup => selectedGroup;

  // ignore: always_declare_return_types
  setSelectedContacts(List<AtContact?>? list) {
    selecteContactList = list;
  }

  List<AtContact?>? get selectedContactList => selecteContactList;

  /// initialise the service with details from app
  void init(String rootDomainFromApp, int rootPortFromApp) async {
    atClientManager = AtClientManager.getInstance();
    _atsign = atClientManager.atClient.getCurrentAtSign()!;
    rootDomain = rootDomainFromApp;
    rootPort = rootPortFromApp;
    atContactImpl = await AtContactsImpl.getInstance(_atsign);
    await fetchGroupsAndContacts();
  }

  /// Function to create a group
  Future<dynamic> createGroup(AtGroup atGroup) async {
    try {
      var group = await atContactImpl.createGroup(atGroup);
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
      var groupIds = await atContactImpl.listGroupIds();
      var groupList = <AtGroup>[];

      for (var i = 0; i < groupIds.length; i++) {
        var groupDetail = await (getGroupDetail(groupIds[i]!));
        // ignore: unnecessary_null_comparison
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

  // ignore: always_declare_return_types
  listAllGroupNames() async {
    try {
      var groupNames = await atContactImpl.listGroupNames();
      return groupNames;
    } catch (e) {
      return e;
    }
  }

  /// Function to get group details for a group ID
  Future<AtGroup?> getGroupDetail(String groupId) async {
    try {
      var group = await atContactImpl.getGroup(groupId);
      return group;
    } catch (e) {
      print('error in getting group details : $e');
      return null;
    }
  }

  /// Function to delete members of a group
  Future<dynamic> deletGroupMembers(
      List<AtContact> contacts, AtGroup group) async {
    try {
      var result = await atContactImpl.deleteMembers(Set.from(contacts), group);
      if (result is bool) {
        await updateGroupStreams(group);
        return result;
      }
    } catch (e) {
      print('error in deleting group members:$e');
      return e;
    }
  }

  /// Function to add members to a group
  Future<dynamic> addGroupMembers(
      List<AtContact?> contacts, AtGroup group) async {
    try {
      var result = await atContactImpl.addMembers(Set.from(contacts), group);
      if (result is bool) {
        await updateGroupStreams(group);
        return result;
      }
    } catch (e) {
      print('error in adding members: $e');
      return e;
    }
  }

  /// Function to update group details
  Future<dynamic> updateGroup(AtGroup group) async {
    try {
      var updatedGroup = await atContactImpl.updateGroup(group);
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
    var groupDetail = await (getGroupDetail(group.groupId!));
    if (groupDetail is AtGroup) groupViewSink.add(groupDetail);
    await getAllGroupsDetails();
  }

  /// Function to delete a group
  Future<bool?> deleteGroup(AtGroup group) async {
    try {
      var result = await atContactImpl.deleteGroup(group);
      await getAllGroupsDetails(); //updating group list sink
      return result;
    } catch (e) {
      print('error in deleting group: $e');
      return null;
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
  // ignore: always_declare_return_types
  fetchGroupsAndContacts() async {
    try {
      allContacts = [];
      var contactList = await fetchContacts();
      // print('CONT====>$contactList');
      contactList.forEach((AtContact? contact) {
        allContacts.add(GroupContactsModel(
            contact: contact, contactType: ContactsType.CONTACT));
      });
      await getAllGroupsDetails();
      // print('ALL CONTACTS====>${allContacts[8]}');
      _allContactsStreamController.add(allContacts);
    } catch (e) {
      print(e);
    }
  }

  // ignore: always_declare_return_types
  removeGroupContact(GroupContactsModel? item) async {
    try {
      length = 0;
      if (selectedGroupContacts.isNotEmpty) {
        selectedGroupContacts.forEach((groupContact) {
          if (groupContact!.contactType == ContactsType.CONTACT) {
            length++;
          } else if (groupContact.contactType == ContactsType.GROUP) {
            length = length + groupContact.group!.members!.length;
          }
        });
      }

      // ignore: omit_local_variable_types
      for (GroupContactsModel? groupContact in selectedGroupContacts) {
        if ((groupContact.toString() == item.toString())) {
          var index = selectedGroupContacts.indexOf(groupContact);
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

  // ignore: always_declare_return_types
  addGroupContact(GroupContactsModel? item) {
    try {
      var isSelected = false;
      length = 0;
      if (selectedGroupContacts.isNotEmpty) {
        selectedGroupContacts.forEach((groupContact) {
          if (groupContact!.contactType == ContactsType.CONTACT) {
            length++;
          } else if (groupContact.contactType == ContactsType.GROUP) {
            length = length + groupContact.group!.members!.length;
          }
        });
      }

      // ignore: omit_local_variable_types
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

  /// Function to reset all data related to groups
  void resetData() {
    allContacts = [];
    selectedGroupContacts = [];
    selectedContactsSink.add(selectedGroupContacts);
    atGroupSink.add([]);
    allContactsSink.add([]);
    showLoaderSink.add(false);
  }

  /// Function to dispose all declared stream controllers
  void dispose() {
    _atGroupStreamController.close();
    _groupViewStreamController.close();
    _allContactsStreamController.close();
    _selectedContactsStreamController.close();
  }
}
