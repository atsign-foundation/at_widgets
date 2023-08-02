// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_commons/at_commons.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_route_names.dart';

import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/services/navigation_service.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/utils/images.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/utils/text_styles.dart';
import 'package:at_contacts_group_flutter/widgets/circular_contacts.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_cover_image_picker.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_floating_add_contact_button.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_group_contacts_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// This widget gives a screen view for displaying contacts and group details
// ignore: must_be_immutable
class DesktopGroupContactView extends StatefulWidget {
  /// Boolean flag to set view to show contacts
  final bool showContacts;

  /// Boolean flag to set view to show groups
  final bool showGroups;

  /// Boolean flag to set view to show single selection
  final bool singleSelection;

  /// Boolean flag to set view as selection screen
  final bool asSelectionScreen;

  Function(List<GroupContactsModel?>?)? onBackArrowTap;
  Function? onDoneTap;

  /// Callback to get the list of selected contacts back to the app
  final ValueChanged<List<GroupContactsModel?>>? selectedList;

  /// When contacts are tapped, the selected list is sent to app
  final ValueChanged<List<GroupContactsModel?>>? onContactsTap;

  /// to show already selected contacts.
  final List<GroupContactsModel>? contactSelectedHistory;

  DesktopGroupContactView(
      {Key? key,
      this.showContacts = false,
      this.showGroups = false,
      this.singleSelection = false,
      this.asSelectionScreen = true,
      this.selectedList,
      this.onBackArrowTap,
      this.onDoneTap,
      this.contactSelectedHistory,
      this.onContactsTap})
      : super(key: key);

  @override
  _DesktopGroupContactViewState createState() =>
      _DesktopGroupContactViewState();
}

class _DesktopGroupContactViewState extends State<DesktopGroupContactView> {
  /// Instance of group service
  late GroupService _groupService;

  /// Text from the search field
  String searchText = '';

  /// Boolean indicator of blocking action in progress
  bool blockingContact = false;

  /// List to hold the last saved contacts of a group
  List<GroupContactsModel?> unmodifiedSelectedGroupContacts = [];

  /// Instance of contact service
  late ContactService _contactService;

  /// Boolean indicator of deleting action in progress
  bool deletingContact = false;
  ContactTabs contactTabs = ContactTabs.ALL;

  /// Controller of group name field
  late TextEditingController groupNameController;

  Uint8List? selectedImageByteData;

  bool processing = false;

  @override
  void initState() {
    _groupService = GroupService();
    _contactService = ContactService();
    groupNameController = TextEditingController();
    _groupService.fetchGroupsAndContacts(isDesktop: true);
    unmodifiedSelectedGroupContacts =
        List.from(_groupService.selectedGroupContacts);

    if (widget.contactSelectedHistory != null) {
      _groupService.selectedGroupContacts = [...widget.contactSelectedHistory!];
    }

    super.initState();
  }

  List<AtContact> selectedList = [];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        isDesktop: true,
        showTitle: true,
        centerTitle: false,
        titleText: 'Add New Group',
        titleTextStyle: CustomTextStyles.blackW50020,
        leadingIcon: InkWell(
          onTap: () {
            if (widget.onBackArrowTap != null) {
              widget.onBackArrowTap!(_groupService.selectedGroupContacts);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Image.asset(
              AllImages().back,
              width: 8,
              height: 20,
              package: 'at_contacts_group_flutter',
            ),
          ),
        ),
        showLeadingIcon: true,
        showTrailingIcon: true,
        trailingIcon: InkWell(
          onTap: () async {
            await createGroup();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 8),
            margin: const EdgeInsets.only(right: 28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(46),
              color: AllColors().buttonColor,
            ),
            child: Text(
              'Save',
              style: CustomTextStyles.whiteW50015,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
                left: 24.toHeight, right: 24.toHeight, bottom: 12.toHeight),
            height: double.infinity,
            child: ListView(
              children: [
                TextField(
                  style: TextStyle(
                    fontSize: 14.toFont,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Group Name',
                    enabledBorder: const UnderlineInputBorder(),
                    filled: true,
                    fillColor: AllColors().textFieldFillColor,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 24),
                    border: const UnderlineInputBorder(),
                    hintStyle: TextStyle(
                      fontSize: 14.toFont,
                      fontWeight: FontWeight.w500,
                      color: AllColors().hintTextColor,
                    ),
                  ),
                  controller: groupNameController,
                ),
                SizedBox(height: 20.toHeight),
                DesktopCoverImagePicker(
                  selectedImage: selectedImageByteData,
                  onSelected: (value) {
                    setState(() {
                      selectedImageByteData = value;
                    });
                  },
                  isEdit: true,
                ),
                SizedBox(height: 20.toHeight),
                DesktopGroupContactsList(
                  asSelectionScreen: widget.asSelectionScreen,
                  singleSelection: widget.singleSelection,
                  onContactsTap: widget.onContactsTap,
                  selectedList: widget.selectedList,
                  showContacts: widget.showContacts,
                  showGroups: widget.showGroups,
                ),
              ],
            ),
          ),
          const DesktopFloatingAddContactButton(),
        ],
      ),
    );
  }

  Widget buildSearchField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TextField(
        textInputAction: TextInputAction.search,
        onChanged: (text) => setState(() {
          searchText = text;
        }),
        decoration: InputDecoration(
          filled: true,
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(
            fontSize: 14.toFont,
            color: AllColors().searchHintTextColor,
            fontWeight: FontWeight.w500,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 24, top: 20, bottom: 20),
            child: Image.asset(
              AllImages().search,
              width: 20,
              height: 20,
              color: AllColors().searchHintTextColor,
              fit: BoxFit.cover,
              package: 'at_contacts_group_flutter',
            ),
          ),
        ),
        style: TextStyle(
          fontSize: 14.toFont,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget gridViewContactList(
      List<GroupContactsModel?> contactsForAlphabet, BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: SizeConfig().isTablet(context) ? 4 : 3,
          childAspectRatio: 1 / (SizeConfig().isTablet(context) ? 1.2 : 1.3)),
      shrinkWrap: true,
      itemCount: contactsForAlphabet.length,
      itemBuilder: (context, alphabetIndex) {
        return CircularContacts(
          asSelectionTile: widget.asSelectionScreen,
          selectSingle: widget.singleSelection,
          selectedList: (s) {
            widget.selectedList!(s);
          },
          onTap: () {
            if (contactsForAlphabet[alphabetIndex]!.group != null) {
              Navigator.pop(context);
              _groupService.addGroupContact(contactsForAlphabet[alphabetIndex]);
              widget.selectedList!(GroupService().selectedGroupContacts);
            }
          },
          onLongPressed: () {
            showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                builder: (builder) {
                  return Container(
                    height: 200.0,
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: const Text('Delete'),
                            onTap: () {
                              deleteAtSign(
                                contactsForAlphabet[alphabetIndex]!.contact!,
                                closeBottomSheet: true,
                              );
                            },
                            leading: const Icon(Icons.delete),
                          ),
                          const Divider(),
                          ListTile(
                            title: const Text('Block'),
                            onTap: () {
                              blockUnblockContact(
                                contactsForAlphabet[alphabetIndex]!.contact!,
                                closeBottomSheet: true,
                              );
                            },
                            leading: const Icon(Icons.block),
                          )
                        ],
                      ),
                    ),
                  );
                });
          },
          onCrossPressed: () {
            if (contactsForAlphabet[alphabetIndex]!.group != null) {
              Navigator.pop(context);
              _groupService.addGroupContact(contactsForAlphabet[alphabetIndex]);
              widget.selectedList!(GroupService().selectedGroupContacts);
            }
          },
          groupContact: contactsForAlphabet[alphabetIndex],
        );
      },
    );
  }

  blockUnblockContact(AtContact contact,
      {bool closeBottomSheet = false}) async {
    setState(() {
      blockingContact = true;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(TextStrings().blockContact),
        ),
        content: SizedBox(
          height: 100.toHeight,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
    var _res = await _contactService.blockUnblockContact(
        contact: contact, blockAction: true);
    await _groupService.fetchGroupsAndContacts();
    setState(() {
      blockingContact = true;
      Navigator.pop(context);
    });

    if (_res && closeBottomSheet) {
      if (mounted) {
        /// to close bottomsheet
        Navigator.pop(context);
      }
    }
  }

  deleteAtSign(AtContact contact, {bool closeBottomSheet = false}) async {
    setState(() {
      deletingContact = true;
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(TextStrings().deleteContact),
        ),
        content: SizedBox(
          height: 100.toHeight,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
    var _res = await _contactService.deleteAtSign(atSign: contact.atSign!);
    if (_res) {
      await _groupService.removeContact(contact.atSign!);
    }
    setState(() {
      deletingContact = false;
      Navigator.pop(context);
    });

    if (_res && closeBottomSheet) {
      if (mounted) {
        /// to close bottomsheet
        Navigator.pop(context);
      }
    }
  }

// creates a list of contacts by merging atsigns and groups.

  List<GroupContactsModel?> filterFavContacts(
      List<GroupContactsModel?> _filteredList) {
    _filteredList.removeWhere((groupContact) {
      if (groupContact != null && groupContact.contact != null) {
        return groupContact.contact!.favourite == false;
      } else if (groupContact != null && groupContact.contact == null) {
        return true;
      } else {
        return false;
      }
    });

    return _filteredList;
  }

  createGroup() async {
    String groupName = groupNameController.text;
    // ignore: unnecessary_null_comparison
    if (groupName != null) {
      setState(() {
        processing = true;
      });

      // if (groupName.contains(RegExp(TextConstants().GROUP_NAME_REGEX))) {
      //   CustomToast().show(TextConstants().INVALID_NAME, context);
      //   return;
      // }

      if (groupName.trim().isNotEmpty) {
        var group = AtGroup(
          groupName,
          description: 'group desc',
          displayName: groupName,
          members: Set.from(GroupService()
              .selectedGroupContacts
              .map((element) => element?.contact)),
          createdBy: GroupService().currentAtsign,
          updatedBy: GroupService().currentAtsign,
        );

        if (selectedImageByteData != null) {
          group.groupPicture = selectedImageByteData;
        }

        var result = await GroupService().createGroup(group);
        if (result is AtGroup) {
          //ignore: across_async_gaps
          if (context.mounted) Navigator.of(context).pop();

          // widget.onDone!();

          setState(() {
            processing = false;
          });

          GroupService().setSelectedContacts([]);

          await Navigator.of(
                  NavService.groupPckgRightHalfNavKey.currentContext!)
              .pushReplacementNamed(DesktopRoutes.DESKTOP_GROUP_DETAIL,
                  arguments: {
                'group': result,
              });
          await Navigator.of(NavService.groupPckgLeftHalfNavKey.currentContext!)
              .pushReplacementNamed(
            DesktopRoutes.DESKTOP_GROUP_LIST,
            arguments: {
              'group': result,
            },
          );
        } else if (result != null) {
          if (mounted) {
            if (result.runtimeType == AlreadyExistsException) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(TextConstants().GROUP_ALREADY_EXISTS)));
            } else if (result.runtimeType == InvalidAtSignException) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(result.message)));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(TextConstants().SERVICE_ERROR)));
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(TextConstants().SERVICE_ERROR)));
          }
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(TextConstants().EMPTY_NAME)));
      }

      setState(() {
        processing = false;
      });
    } else {
      CustomToast().show(TextConstants().EMPTY_NAME, context, gravity: 0);
    }
  }
}
