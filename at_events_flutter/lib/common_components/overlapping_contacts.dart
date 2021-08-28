import 'dart:typed_data';

/// This is a custom widget to display the selected contacts
/// in a row with overlapping profile pictures
import 'package:at_contact/at_contact.dart';
import 'package:at_events_flutter/common_components/contact_list_tile.dart';
import 'package:at_events_flutter/common_components/contacts_initials.dart';
import 'package:at_events_flutter/common_components/custom_circle_avatar.dart';
import 'package:at_events_flutter/services/event_services.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class OverlappingContacts extends StatefulWidget {
  final List<AtContact>? selectedList;
  const OverlappingContacts({Key? key, this.selectedList}) : super(key: key);
  @override
  _OverlappingContactsState createState() => _OverlappingContactsState();
}

class _OverlappingContactsState extends State<OverlappingContacts> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Container(
        height: (isExpanded) ? 300.toHeight : 55,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xffF7F7FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: <Widget>[
            Stack(
              children: List<Positioned>.generate(
                (widget.selectedList!.length > 3) ? 3 : widget.selectedList!.length,
                (int index) {
                  Uint8List? image;
                  if (widget.selectedList![index].tags != null && widget.selectedList![index].tags!['image'] != null) {
                    List<int> intList = widget.selectedList![index].tags!['image'].cast<int>();
                    image = Uint8List.fromList(intList);
                  }
                  return Positioned(
                    left: 5 + double.parse((index * 25).toString()),
                    top: 5.toHeight,
                    child: Container(
                      height: 28.toHeight,
                      width: 28.toHeight,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: (widget.selectedList![index].tags != null &&
                              widget.selectedList![index].tags!['image'] != null)
                          ? CustomCircleAvatar(
                              memoryImage: image,
                              isMemoryImage: true,
                            )
                          : ContactInitial(
                              initials: widget.selectedList![index].atSign,
                            ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 10.toHeight,
              left: 40 + double.parse((widget.selectedList!.length * 25).toString()),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  (widget.selectedList!.isEmpty)
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              width: 160.toWidth,
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 60.toWidth,
                                    child: Text(
                                      widget.selectedList![0].atSign!,
                                      // style:
                                      // CustomTextStyles.secondaryRegular14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    // width: 100.toWidth,
                                    child: Text(
                                      widget.selectedList!.length - 1 == 0
                                          ? ''
                                          : widget.selectedList!.length - 1 == 1
                                              ? ' and ${widget.selectedList!.length - 1} other'
                                              : ' and ${widget.selectedList!.length - 1} others',
                                      // style:
                                      // CustomTextStyles.secondaryRegular14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        width: 10.toWidth,
                      ),
                      // Expanded(child: Container()),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              top: 10.toHeight,
              right: 0,
              child: Container(
                width: 20.toWidth,
                child: Icon(
                  (isExpanded) ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 15.toFont,
                ),
              ),
            ),
            (isExpanded)
                ? Positioned(
                    top: 50.toHeight,
                    child: Container(
                      height: 200.toHeight,
                      width: SizeConfig().screenWidth - 60.toWidth,
                      child: ListView.builder(
                        itemCount: widget.selectedList!.length,
                        itemBuilder: (BuildContext context, int index) {
                          Uint8List? image;
                          if (widget.selectedList![index].tags != null &&
                              widget.selectedList![index].tags!['image'] != null) {
                            List<int> intList = widget.selectedList![index].tags!['image'].cast<int>();
                            image = Uint8List.fromList(intList);
                          }
                          return ContactListTile(
                            onlyRemoveMethod: true,
                            onTileTap: () {},
                            isSelected: widget.selectedList!.contains(widget.selectedList![index]),
                            onRemove: () {
                              EventService().removeSelectedContact(index);
                              EventService().update();
                            },
                            name: widget.selectedList![index].tags != null &&
                                    widget.selectedList![index].tags!['name'] != null
                                ? widget.selectedList![index].tags!['name']
                                : widget.selectedList![index].atSign!.substring(1),
                            atSign: widget.selectedList![index].atSign,
                            image: (widget.selectedList![index].tags != null &&
                                    widget.selectedList![index].tags!['image'] != null)
                                ? CustomCircleAvatar(
                                    memoryImage: image,
                                    isMemoryImage: true,
                                  )
                                : ContactInitial(
                                    initials: widget.selectedList![index].atSign,
                                  ),
                          );
                        },
                      ),
                    ),
                  )
                : Positioned(
                    top: 20.toHeight,
                    child: Container(),
                  )
          ],
        ),
      ),
    );
  }
}
