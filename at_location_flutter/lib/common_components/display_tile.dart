import 'dart:typed_data';
import 'package:at_contact/at_contact.dart';
import 'package:at_location_flutter/service/contact_service.dart';
import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:at_location_flutter/utils/constants/text_styles.dart';

import 'package:flutter/material.dart';

import 'contacts_initial.dart';
import 'custom_circle_avatar.dart';

class DisplayTile extends StatefulWidget {
  final String title, semiTitle, subTitle, atsignCreator, invitedBy;
  final int number;
  final Widget action;
  final bool showName;
  DisplayTile(
      {@required this.title,
      this.atsignCreator,
      @required this.subTitle,
      this.semiTitle,
      this.invitedBy,
      this.number,
      this.showName = false,
      this.action});

  @override
  _DisplayTileState createState() => _DisplayTileState();
}

class _DisplayTileState extends State<DisplayTile> {
  Uint8List image;
  AtContact contact;
  AtContactsImpl atContact;
  String name;
  @override
  void initState() {
    super.initState();
    getEventCreator();
  }

  void getEventCreator() async {
    var contact = await getAtSignDetails(widget.atsignCreator);
    if (contact != null) {
      if (contact.tags != null && contact.tags['image'] != null) {
        List<int> intList = contact.tags['image'].cast<int>();
        if (mounted) {
          setState(() {
            image = Uint8List.fromList(intList);
            if (widget.showName) name = contact.tags['name'].toString();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.5),
      child: Row(
        children: [
          Stack(
            children: [
              (image != null)
                  ? CustomCircleAvatar(
                      byteImage: image, nonAsset: true, size: 30)
                  : widget.atsignCreator != null
                      ? ContactInitial(
                          initials: widget.atsignCreator.substring(1, 3))
                      : SizedBox(),
              widget.number != null
                  ? Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        alignment: Alignment.center,
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: AllColors().BLUE),
                        child: Text(
                          '+${widget.number}',
                          style: CustomTextStyles().black10,
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Column(
              mainAxisAlignment: widget.semiTitle != null
                  ? MainAxisAlignment.spaceEvenly
                  : MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? widget.title,
                  style: CustomTextStyles().black14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 3,
                ),
                widget.semiTitle != null
                    ? Text(
                        widget.semiTitle,
                        style: (widget.semiTitle == 'Action required' ||
                                    widget.semiTitle == 'Request declined') ||
                                (widget.semiTitle == 'Cancelled')
                            ? CustomTextStyles().orange12
                            : CustomTextStyles().darkGrey12,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : SizedBox(),
                SizedBox(
                  height: 3,
                ),
                Text(
                  widget.subTitle,
                  style: CustomTextStyles().darkGrey12,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                widget.invitedBy != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(widget.invitedBy,
                            style: CustomTextStyles().grey14),
                      )
                    : SizedBox()
              ],
            ),
          )),
          widget.action ?? SizedBox()
        ],
      ),
    );
  }
}
