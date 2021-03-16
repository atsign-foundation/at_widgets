/// A custom list tile to display the contacts
/// takes in a function @param [onTap] to define what happens on tap of the tile
/// @param [onTrailingPresses] to set the behaviour for trailing icon
/// @param [asSelectionTile] to toggle whether the tile is selectable to select contacts
/// @param [contact] for details of the contact
/// @param [contactService] to get an instance of [AtContactsImpl]

import 'dart:typed_data';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/images.dart';
import 'package:at_contacts_flutter/widgets/contacts_initials.dart';
import 'package:at_contacts_flutter/widgets/custom_circle_avatar.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/utils/images.dart';

import 'package:flutter/material.dart';

class CustomListTile extends StatefulWidget {
  final Function onTap;
  final Function onTrailingPressed;
  final bool asSelectionTile;
  final GroupContactsModel item;
  final bool selectSingle;
  final ValueChanged<List<GroupContactsModel>> selectedList;

  const CustomListTile({
    Key key,
    this.onTap,
    this.onTrailingPressed,
    this.asSelectionTile = false,
    this.item,
    this.selectSingle = false,
    this.selectedList,
  }) : super(key: key);
  @override
  _CustomListTileState createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  bool isSelected = false;
  bool isLoading = false;
  GroupService _groupService;
  AtContact localContact;
  AtGroup localGroup;
  @override
  void initState() {
    _groupService = GroupService();
    // if (!widget.selectSingle) {
    for (GroupContactsModel groupContact
        in _groupService.selectedGroupContacts) {
      if (widget.item.toString() == groupContact.toString()) {
        isSelected = true;
        break;
      } else {
        isSelected = false;
      }
    }
    // }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _groupService = GroupService();

    // if (!widget.selectSingle) {
    for (GroupContactsModel groupContact
        in _groupService.selectedGroupContacts) {
      if (widget.item.toString() == groupContact.toString()) {
        isSelected = true;
        break;
      } else {
        isSelected = false;
      }
    }
    // }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Widget contactImage;
    if ((widget?.item?.contact?.tags != null &&
        widget?.item?.contact?.tags['image'] != null)) {
      List<int> intList = widget?.item?.contact?.tags['image'].cast<int>();
      Uint8List image = Uint8List.fromList(intList);
      contactImage = CustomCircleAvatar(
        byteImage: image,
        nonAsset: true,
      );
    } else {
      contactImage = ContactInitial(
        initials: widget?.item?.contact?.atSign?.substring(1, 3) ??
            widget?.item?.group?.groupName?.substring(0, 2),
      );
    }
    return StreamBuilder<List<GroupContactsModel>>(
        initialData: _groupService.selectedGroupContacts,
        stream: _groupService.selectedContactsStream,
        builder: (context, snapshot) {
          // if (!widget.selectSingle) {
          for (GroupContactsModel groupContact
              in _groupService.selectedGroupContacts) {
            if (widget.item.toString() == groupContact.toString()) {
              isSelected = true;
              break;
            } else {
              isSelected = false;
            }
          }
          if (_groupService.selectedGroupContacts.isEmpty) {
            isSelected = false;
          }

          return ListTile(
            onTap: () {
              if (widget.asSelectionTile) {
                if (widget.selectSingle) {
                  _groupService.selectedGroupContacts = [];
                  _groupService.addGroupContact(widget.item);
                  widget.selectedList([widget.item]);
                  // if (widget.item.contactType == ContactsType.CONTACT) {
                  //   widget.selectedList([widget.item.contact]);
                  // } else if (widget.item.contactType == ContactsType.GROUP) {
                  //   widget.selectedList(widget.item.group.members.toList());
                  // }
                  Navigator.pop(context);
                } else if (!widget.selectSingle) {
                  setState(() {
                    if (isSelected) {
                      _groupService.removeGroupContact(widget.item);
                    } else {
                      _groupService.addGroupContact(widget.item);
                    }
                    isSelected = !isSelected;
                  });
                }
              } else {
                widget?.onTap();
              }
            },
            title: Text(
              ((widget?.item?.contact?.tags != null &&
                      widget?.item?.contact?.tags['name'] != null))
                  ? widget?.item?.contact?.tags['name']
                  : widget?.item?.contact?.atSign?.substring(1) ??
                      widget?.item?.group?.groupName?.substring(0),
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.toFont,
              ),
            ),
            subtitle: Text(
              widget?.item?.contact?.atSign ??
                  '${widget?.item?.group?.members?.length} Members',
              style: TextStyle(
                color: AllColors().FADED_TEXT,
                fontSize: 14.toFont,
              ),
            ),
            leading: Container(
                height: 40.toWidth,
                width: 40.toWidth,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: contactImage),
            trailing: IconButton(
              onPressed: selectRemoveContact(),
              icon: (widget.asSelectionTile ?? false)
                  ? (isSelected)
                      ? Icon(Icons.close)
                      : Icon(Icons.add)
                  : Image.asset(
                      AllImages().SEND,
                      width: 21.toWidth,
                      height: 18.toHeight,
                      // package: 'atsign_contacts',
                    ),
            ),
          );
        });
  }

  selectRemoveContact() {}
}
