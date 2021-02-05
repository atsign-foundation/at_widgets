import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:at_chat_flutter/widgets/contacts_initials.dart';
import 'package:at_events_flutter/common_components/custom_circle_avatar.dart';
import 'package:at_events_flutter/utils/colors.dart';
import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:at_location_flutter/service/location_service.dart';

import 'package:flutter/material.dart';

class DisplayTile extends StatefulWidget {
  final String title, semiTitle, subTitle, atsignCreator, invitedBy;
  final int number;
  final Widget action;
  DisplayTile(
      {@required this.title,
      this.atsignCreator,
      @required this.subTitle,
      this.semiTitle,
      this.invitedBy,
      this.number,
      this.action});

  @override
  _DisplayTileState createState() => _DisplayTileState();
}

class _DisplayTileState extends State<DisplayTile> {
  Uint8List image;
  AtContact contact;
  AtContactsImpl atContact;
  @override
  void initState() {
    super.initState();
    getEventCreator();
  }

  getEventCreator() async {
    atContact = await AtContactsImpl.getInstance(LocationService().getAtSign());
    contact = await atContact.get(widget.atsignCreator);
    if (contact != null) {
      if (contact.tags != null && contact.tags['image'] != null) {
        List<int> intList = contact.tags['image'].cast<int>();
        if (Uint8List.fromList(intList) != null) {
          setState(() {
            image = Uint8List.fromList(intList);
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
              // CustomCircleAvatar(
              //   image: widget.image,
              //   size: 46,
              // ),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).primaryTextTheme.headline3,
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
