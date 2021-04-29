/// A custom list tile to display the contacts
/// takes in a function @param [onTap] to define what happens on tap of the tile
/// @param [onTrailingPresses] to set the behaviour for trailing icon
/// @param [asSelectionTile] to toggle whether the tile is selectable to select contacts
/// @param [contact] for details of the contact
/// @param [contactService] to get an instance of [AtContactsImpl]

import 'dart:typed_data';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_flutter/utils/images.dart';
import 'package:at_contacts_flutter/widgets/contacts_initials.dart';
import 'package:at_contacts_flutter/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class CustomListTile extends StatefulWidget {
  final Function? onTap;
  final Function? onTrailingPressed;
  final bool asSelectionTile;
  final bool asSingleSelectionTile;
  final AtContact? contact;
  final ContactService? contactService;
  final ValueChanged<List<AtContact?>?>? selectedList;

  const CustomListTile(
      {Key? key,
      this.onTap,
      this.onTrailingPressed,
      this.asSelectionTile = false,
      this.asSingleSelectionTile = false,
      this.contact,
      this.contactService,
      this.selectedList})
      : super(key: key);
  @override
  _CustomListTileState createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    Widget contactImage;
    if (widget.contact!.tags != null && widget.contact!.tags['image'] != null) {
      List<int> intList = widget.contact!.tags['image'].cast<int>();
      Uint8List image = Uint8List.fromList(intList);
      contactImage = CustomCircleAvatar(
        byteImage: image,
        nonAsset: true,
      );
    } else {
      contactImage = ContactInitial(
        initials: widget.contact!.atSign.substring(1, 3),
      );
    }
    return StreamBuilder<List<AtContact?>>(
        initialData: widget.contactService!.selectedContacts,
        stream: widget.contactService!.selectedContactStream,
        builder: (context, snapshot) {
          for (AtContact? contact in widget.contactService!.selectedContacts) {
            if (contact == widget.contact ||
                contact!.atSign == widget.contact!.atSign) {
              isSelected = true;
              break;
            } else {
              isSelected = false;
            }
          }
          if (widget.contactService!.selectedContacts.isEmpty) {
            isSelected = false;
          }
          return ListTile(
            onTap: () {
              if (widget.asSelectionTile) {
                setState(() {
                  if (isSelected) {
                    widget.contactService!.removeSelectedAtSign(widget.contact);
                  } else {
                    if (widget.asSingleSelectionTile) {
                      widget.contactService!.clearAtSigns();
                      Navigator.pop(context);
                    }
                    widget.contactService!.selectAtSign(widget.contact);
                  }
                  isSelected = !isSelected;
                });

                widget.selectedList!(widget.contactService!.selectedContacts);
              } else {
                widget.onTap!();
              }
            },
            title: Text(
              widget.contact!.tags != null &&
                      widget.contact!.tags['name'] != null
                  ? widget.contact!.tags['name']
                  : widget.contact!.atSign.substring(1),
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.toFont,
              ),
            ),
            subtitle: Text(
              widget.contact!.atSign,
              style: TextStyle(
                color: ColorConstants.fadedText,
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
                child: contactImage),
            trailing: IconButton(
              onPressed: widget.asSelectionTile
                  ? selectRemoveContact()
                  : () {
                      if (widget.onTrailingPressed != null) {
                        widget.onTrailingPressed!(widget.contact!.atSign);
                      }
                    },
              icon: (widget.asSelectionTile)
                  ? (isSelected)
                      ? Icon(Icons.close)
                      : Icon(Icons.add)
                  : Image.asset(
                      ImageConstants.sendIcon,
                      width: 21.toWidth,
                      height: 18.toHeight,
                      package: 'at_contacts_flutter',
                    ),
            ),
          );
        });
  }

  selectRemoveContact() {}
}
