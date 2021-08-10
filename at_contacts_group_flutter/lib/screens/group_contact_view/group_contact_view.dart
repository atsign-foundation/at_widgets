// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/at_common_flutter.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/widgets/custom_app_bar.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';

import 'package:at_contacts_flutter/widgets/custom_search_field.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/widgets/add_contacts_group_dialog.dart';
import 'package:at_contacts_group_flutter/widgets/contacts_selction_bottom_sheet.dart';
import 'package:at_contacts_group_flutter/widgets/custom_list_tile.dart';
import 'package:at_contacts_group_flutter/widgets/horizontal_circular_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class GroupContactView extends StatefulWidget {
  final bool showContacts;
  final bool showGroups;
  final bool singleSelection;
  final bool asSelectionScreen;

  final ValueChanged<List<GroupContactsModel?>>? selectedList;

  const GroupContactView(
      {Key? key,
      this.showContacts = false,
      this.showGroups = false,
      this.singleSelection = false,
      this.asSelectionScreen = true,
      this.selectedList})
      : super(key: key);
  @override
  _GroupContactViewState createState() => _GroupContactViewState();
}

class _GroupContactViewState extends State<GroupContactView> {
  late GroupService _groupService;
  String searchText = '';
  bool blockingContact = false;
  List<GroupContactsModel?> unmodifiedSelectedGroupContacts = [];
  late ContactService _contactService;
  bool deletingContact = false;

  @override
  void initState() {
    _groupService = GroupService();
    _contactService = ContactService();
    _groupService.fetchGroupsAndContacts();
    unmodifiedSelectedGroupContacts =
        List.from(_groupService.selectedGroupContacts);

    super.initState();
  }

  List<AtContact> selectedList = [];
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      bottomSheet: (widget.singleSelection)
          ? Container(
              height: 0,
            )
          : (widget.asSelectionScreen)
              ? ContactSelectionBottomSheet(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  selectedList: (s) {
                    widget.selectedList!(s);
                  },
                )
              : Container(
                  height: 0,
                ),
      appBar: CustomAppBar(
        showTitle: true,
        titleText: 'Contacts',
        onLeadingIconPressed: () {
          _groupService.selectedGroupContacts = unmodifiedSelectedGroupContacts;
          widget.selectedList!(unmodifiedSelectedGroupContacts);
        },
        showBackButton: true,
        showLeadingIcon: true,
        // showTrailingIcon: widget.asSelectionScreen == null ||
        //         widget.asSelectionScreen == false
        //     ? true
        //     : false,
        showTrailingIcon: true,
        trailingIcon: Icon(Icons.add),
        onTrailingIconPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddContactDialog(),
          );
        },
      ),
      body: Container(
        padding: EdgeInsets.all(16.toHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ContactSearchField(
              TextStrings().searchContact,
              (text) => setState(() {
                searchText = text;
              }),
            ),
            SizedBox(
              height: 15.toHeight,
            ),
            (widget.asSelectionScreen)
                ? (widget.singleSelection)
                    ? Container()
                    : HorizontalCircularList()
                : Container(),
            Expanded(
                child: StreamBuilder<List<GroupContactsModel?>>(
              stream: _groupService.allContactsStream,
              initialData: _groupService.allContacts,
              builder: (context, snapshot) {
                return (snapshot.connectionState == ConnectionState.waiting)
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : (snapshot.data == null || snapshot.data!.isEmpty)
                        ? Center(
                            child: Text(TextStrings().noContacts),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.only(bottom: 80.toHeight),
                            itemCount: 27,
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, alphabetIndex) {
                              var _filteredList = <GroupContactsModel?>[];
                              snapshot.data!.forEach((c) {
                                if (widget.showContacts &&
                                    c!.contact != null &&
                                    c.contact!.atSign
                                        .toString()
                                        .toUpperCase()
                                        .contains(searchText.toUpperCase())) {
                                  _filteredList.add(c);
                                }
                                if (widget.showGroups &&
                                    c!.group != null &&
                                    c.group!.displayName != null &&
                                    c.group!.displayName!
                                        .toUpperCase()
                                        .contains(searchText.toUpperCase())) {
                                  _filteredList.add(c);
                                }
                              });
                              var contactsForAlphabet = <GroupContactsModel?>[];
                              var currentChar =
                                  String.fromCharCode(alphabetIndex + 65)
                                      .toUpperCase();

                              if (alphabetIndex == 26) {
                                currentChar = 'Others';
                                _filteredList.forEach((c) {
                                  if (widget.showContacts &&
                                      c!.contact != null &&
                                      int.tryParse(c.contact!.atSign![1]) !=
                                          null) {
                                    contactsForAlphabet.add(c);
                                  }
                                });
                                _filteredList.forEach((c) {
                                  if (widget.showGroups &&
                                      c!.group != null &&
                                      int.tryParse(c.group!.displayName![0]) !=
                                          null) {
                                    contactsForAlphabet.add(c);
                                  }
                                });
                              } else {
                                _filteredList.forEach((c) {
                                  if (widget.showContacts &&
                                      c!.contact != null &&
                                      c.contact?.atSign![1].toUpperCase() ==
                                          currentChar) {
                                    contactsForAlphabet.add(c);
                                  }
                                });
                                _filteredList.forEach((c) {
                                  if (widget.showGroups &&
                                      c!.group != null &&
                                      c.group?.displayName![0].toUpperCase() ==
                                          currentChar) {
                                    contactsForAlphabet.add(c);
                                  }
                                });
                              }

                              if (contactsForAlphabet.isEmpty) {
                                return Container();
                              }

                              return Container(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          currentChar,
                                          style: TextStyle(
                                            color: AllColors().BLUE_TEXT,
                                            fontSize: 16.toFont,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 4.toWidth),
                                        Expanded(
                                          child: Divider(
                                            color: AllColors()
                                                .DIVIDER_COLOR
                                                .withOpacity(0.2),
                                            height: 1.toHeight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ListView.separated(
                                        itemCount: contactsForAlphabet.length,
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        separatorBuilder: (context, _) =>
                                            Divider(
                                              color: AllColors()
                                                  .DIVIDER_COLOR
                                                  .withOpacity(0.2),
                                              height: 1.toHeight,
                                            ),
                                        itemBuilder: (context, index) {
                                          return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                child: (contactsForAlphabet[
                                                                index]!
                                                            .contact !=
                                                        null)
                                                    ? Slidable(
                                                        actionPane:
                                                            SlidableDrawerActionPane(),
                                                        actionExtentRatio: 0.25,
                                                        secondaryActions: <
                                                            Widget>[
                                                          IconSlideAction(
                                                            caption:
                                                                TextStrings()
                                                                    .block,
                                                            color: ColorConstants
                                                                .inputFieldColor,
                                                            icon: Icons.block,
                                                            onTap: () async {
                                                              setState(() {
                                                                blockingContact =
                                                                    true;
                                                              });
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        AlertDialog(
                                                                  title: Center(
                                                                    child: Text(
                                                                        TextStrings()
                                                                            .blockContact),
                                                                  ),
                                                                  content:
                                                                      Container(
                                                                    height: 100
                                                                        .toHeight,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          CircularProgressIndicator(),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                              await _contactService.blockUnblockContact(
                                                                  contact: contactsForAlphabet[
                                                                          index]!
                                                                      .contact!,
                                                                  blockAction:
                                                                      true);
                                                              await _groupService
                                                                  .fetchGroupsAndContacts();
                                                              setState(() {
                                                                blockingContact =
                                                                    true;
                                                                Navigator.pop(
                                                                    context);
                                                              });
                                                            },
                                                          ),
                                                          IconSlideAction(
                                                            caption:
                                                                TextStrings()
                                                                    .delete,
                                                            color: Colors.red,
                                                            icon: Icons.delete,
                                                            onTap: () async {
                                                              setState(() {
                                                                deletingContact =
                                                                    true;
                                                              });
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        AlertDialog(
                                                                  title: Center(
                                                                    child: Text(
                                                                        TextStrings()
                                                                            .deleteContact),
                                                                  ),
                                                                  content:
                                                                      Container(
                                                                    height: 100
                                                                        .toHeight,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          CircularProgressIndicator(),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                              await _contactService.deleteAtSign(
                                                                  atSign: contactsForAlphabet[
                                                                          index]!
                                                                      .contact!
                                                                      .atSign!);
                                                              await _groupService
                                                                  .fetchGroupsAndContacts();
                                                              setState(() {
                                                                deletingContact =
                                                                    false;
                                                                Navigator.pop(
                                                                    context);
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                        child: Container(
                                                          child: CustomListTile(
                                                            onTap: () {},
                                                            asSelectionTile: widget
                                                                .asSelectionScreen,
                                                            selectSingle: widget
                                                                .singleSelection,
                                                            item:
                                                                contactsForAlphabet[
                                                                    index],
                                                            selectedList: (s) {
                                                              widget.selectedList!(
                                                                  s);
                                                            },
                                                            onTrailingPressed:
                                                                () {
                                                              if (contactsForAlphabet[
                                                                          index]!
                                                                      .contact !=
                                                                  null) {
                                                                Navigator.pop(
                                                                    context);

                                                                _groupService
                                                                    .addGroupContact(
                                                                        contactsForAlphabet[
                                                                            index]);
                                                                widget.selectedList!(
                                                                    GroupService()
                                                                        .selectedGroupContacts);
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      )
                                                    : CustomListTile(
                                                        onTap: () {},
                                                        // asSelectionTile: widget
                                                        //     .asSelectionScreen,
                                                        // selectSingle: widget
                                                        //     .singleSelection,
                                                        asSelectionTile: widget
                                                            .asSelectionScreen,
                                                        selectSingle: widget
                                                            .singleSelection,
                                                        item:
                                                            contactsForAlphabet[
                                                                index],
                                                        selectedList: (s) {
                                                          widget
                                                              .selectedList!(s);
                                                        },
                                                        onTrailingPressed: () {
                                                          if (contactsForAlphabet[
                                                                      index]!
                                                                  .group !=
                                                              null) {
                                                            Navigator.pop(
                                                                context);

                                                            _groupService
                                                                .addGroupContact(
                                                                    contactsForAlphabet[
                                                                        index]);
                                                            widget.selectedList!(
                                                                GroupService()
                                                                    .selectedGroupContacts);
                                                          }
                                                        },
                                                      ),

                                                // child:,
                                              ));
                                        }),
                                  ],
                                ),
                              );
                            },
                          );
              },
            ))
          ],
        ),
      ),
    );
  }
}
