/// A custom list tile to display the contacts
/// takes in a function @param [onTap] to define what happens on tap of the tile
/// @param [onTrailingPresses] to set the behaviour for trailing icon
/// @param [asSelectionTile] to toggle whether the tile is selectable to select contacts
/// @param [contact] for details of the contact
/// @param [contactService] to get an instance of [AtContactsImpl]

import 'dart:io';
import 'dart:typed_data';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/at_common_flutter.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/widgets/contacts_initials.dart';
import 'package:at_contacts_flutter/widgets/custom_circle_avatar.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/utils/images.dart';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CustomListTile extends StatefulWidget {
  final Function? onTap;
  final Function? onTrailingPressed;
  final bool asSelectionTile;
  final GroupContactsModel? item;
  final bool selectSingle;
  final ValueChanged<List<GroupContactsModel?>>? selectedList;

  const CustomListTile({
    Key? key,
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
  late GroupService _groupService;
  AtContact? localContact;
  AtGroup? localGroup;
  @override
  void initState() {
    _groupService = GroupService();
    // if (!widget.selectSingle) {
    // ignore: omit_local_variable_types
    for (GroupContactsModel? groupContact
        in _groupService.selectedGroupContacts) {
      if (widget.item.toString() == groupContact.toString()) {
        isSelected = true;
        break;
      } else {
        isSelected = false;
      }
    }
    getImage();
    // }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _groupService = GroupService();

    // if (!widget.selectSingle) {
    // ignore: omit_local_variable_types
    for (GroupContactsModel? groupContact
        in _groupService.selectedGroupContacts) {
      if (widget.item.toString() == groupContact.toString()) {
        isSelected = true;
        break;
      } else {
        isSelected = false;
      }
    }
    getImage();
    // }
    super.didChangeDependencies();
  }

  Widget? contactImage;

  // ignore: always_declare_return_types
  getImage() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    Uint8List? image;

    if (widget.item!.contact == null) {
      if (widget.item?.group?.groupName == null) {
        contactImage = ContactInitial(
            initials: (widget.item!.group!.displayName!.length > 3
                ? widget.item?.group?.displayName?.substring(0, 2)
                : widget.item?.group?.displayName ?? 'UG')!);
      } else {
        contactImage = ContactInitial(
            initials: (widget.item!.group!.groupName!.length > 3
                ? widget.item?.group?.groupName?.substring(0, 2)
                : widget.item?.group?.groupName ?? 'UG')!);
      }
    } else {
      if ((widget.item?.contact?.tags != null &&
          widget.item?.contact?.tags!['image'] != null)) {
        try {
          List<int> intList = widget.item?.contact?.tags!['image'].cast<int>();
          image = Uint8List.fromList(intList);
        } catch (e) {
          print('error in converting image: $e');
        }

        if ((Platform.isAndroid || Platform.isIOS) && image != null) {
          image = await FlutterImageCompress.compressWithList(
            image,
            minWidth: 400,
            minHeight: 200,
          );

          contactImage = CustomCircleAvatar(
            byteImage: image,
            nonAsset: true,
          );
        } else {
          getContactInitial();
        }
      } else {
        getContactInitial();
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  getContactInitial() {
    String initial;
    if (widget.item?.contact?.atSign == null) {
      initial = '    ';
    } else {
      initial = widget.item!.contact!.atSign!;
    }
    contactImage = ContactInitial(initials: initial);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<GroupContactsModel?>>(
        initialData: _groupService.selectedGroupContacts,
        stream: _groupService.selectedContactsStream,
        builder: (context, snapshot) {
          // if (!widget.selectSingle) {
          // ignore: omit_local_variable_types
          for (GroupContactsModel? groupContact
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
                  widget.selectedList!([widget.item]);
                  Navigator.pop(context);
                } else if (!widget.selectSingle) {
                  if (mounted) {
                    setState(() {
                      if (isSelected) {
                        _groupService.removeGroupContact(widget.item);
                      } else {
                        _groupService.addGroupContact(widget.item);
                      }
                      isSelected = !isSelected;
                    });
                  }
                }
              } else {
                widget.onTap!();
              }
            },
            title: Text(
              widget.item!.contact == null
                  // ignore: prefer_if_null_operators
                  ? widget.item!.group!.displayName == null
                      ? widget.item!.group!.groupName
                      : widget.item!.group!.displayName
                  // ignore: prefer_if_null_operators
                  : widget.item!.contact!.tags!['name'] == null
                      ? widget.item!.contact!.atSign!.substring(1)
                      : widget.item!.contact!.tags!['name'],
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.toFont,
              ),
            ),
            subtitle: Text(
              widget.item?.contact?.atSign ??
                  '${widget.item?.group?.members?.length} Members',
              style: TextStyle(
                color: AllColors().FADED_TEXT,
                fontSize: 14.toFont,
              ),
            ),
            leading: Container(
                height: 40.toHeight,
                width: 40.toHeight,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child:
                    (isLoading) ? CircularProgressIndicator() : contactImage),
            trailing: IconButton(
              onPressed: (widget.asSelectionTile == false &&
                      widget.onTrailingPressed != null)
                  ? widget.onTrailingPressed as void Function()?
                  : selectRemoveContact(),
              icon: (widget.asSelectionTile)
                  ? (isSelected)
                      ? Icon(Icons.close)
                      : Icon(Icons.add)
                  : Image.asset(
                      AllImages().SEND,
                      width: 21.toWidth,
                      height: 18.toHeight,
                      package: 'at_contacts_group_flutter',
                    ),
            ),
          );
        });
  }

  // ignore: always_declare_return_types
  selectRemoveContact() {}
}
