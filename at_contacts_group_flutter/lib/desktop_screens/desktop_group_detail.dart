import 'dart:typed_data';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_flutter/utils/images.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_route_names.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/services/navigation_service.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/utils/images.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/utils/text_styles.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_image_picker.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_person_vertical_tile.dart';
import 'package:at_contacts_group_flutter/widgets/remove_trusted_contact_dialog.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';

class DesktopGroupDetail extends StatefulWidget {
  AtGroup group;
  DesktopGroupDetail(this.group);

  @override
  _DesktopGroupDetailState createState() => _DesktopGroupDetailState();
}

class _DesktopGroupDetailState extends State<DesktopGroupDetail> {
  bool isEditingName = false, updatingName = false, updatingImage = false;
  TextEditingController? textController;

  @override
  void initState() {
    textController = TextEditingController.fromValue(
      TextEditingValue(
        text: widget.group.groupName,
        selection: TextSelection.collapsed(offset: -1),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  widget.group.groupPicture != null
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.memory(
                              Uint8List.fromList(
                                widget.group.groupPicture.cast<int>(),
                              ),
                              height: 272.toHeight,
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                            updatingImage
                                ? Positioned(
                                    child: Text('Updating image...',
                                        style: CustomTextStyles.primaryBold16),
                                  )
                                : SizedBox()
                          ],
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              AllImages().GROUP_PHOTO,
                              height: 272,
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                              package: 'at_contacts_group_flutter',
                            ),
                            updatingImage
                                ? Positioned(
                                    child: Text('Updating image...',
                                        style: CustomTextStyles.primaryBold16),
                                  )
                                : SizedBox()
                          ],
                        ),
                  SizedBox(
                    height: 60.toHeight,
                  ),
                  Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    runSpacing: 10.0,
                    spacing: 30.0,
                    children:
                        List.generate(widget.group.members.length, (index) {
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) => RemoveTrustedContact(
                              'Remove ${widget.group.members.elementAt(index).atSign}  ',
                              contact: AtContact(
                                  atSign: widget.group.members
                                      .elementAt(index)
                                      .atSign),
                              atGroup: widget.group,
                            ),
                          );
                        },
                        child: DesktopCustomPersonVerticalTile(
                          title: 'Title',
                          subTitle:
                              widget.group.members.elementAt(index).atSign,
                          isAssetImage: true,
                          atsign: widget.group.members.elementAt(index).atSign,
                        ),
                      );
                    }),
                  )
                ],
              ),
              Positioned(
                top: 240.toHeight,
                child: Container(
                  height: 80.toHeight,
                  width: (((SizeConfig().screenWidth -
                              TextConstants.SIDEBAR_WIDTH) /
                          2) -
                      30 -
                      30),
                  margin: EdgeInsets.symmetric(
                      horizontal: 15.toWidth, vertical: 0.toHeight),
                  padding: EdgeInsets.symmetric(
                      horizontal: 15.toWidth, vertical: 10.toHeight),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: ColorConstants.greyText,
                        blurRadius: 10.0,
                        spreadRadius: 1.0,
                        offset: Offset(0.0, 0.0),
                      )
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      isEditingName
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: TextField(
                                    textInputAction: TextInputAction.search,
                                    controller: textController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Change name',
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        color: ColorConstants.greyText,
                                      ),
                                      filled: true,
                                      // fillColor: ColorConstants.scaffoldColor,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 5),
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ColorConstants.fontPrimary,
                                    ),
                                    onChanged: (s) {},
                                  ),
                                ),
                                updatingName
                                    ? SizedBox(
                                        width: 35,
                                        height: 25,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () async {
                                          setState(() {
                                            updatingName = true;
                                          });

                                          if (textController!.text !=
                                              widget.group.groupName) {
                                            var _group = AtGroup(
                                              widget.group.groupName,
                                              groupId: widget.group.groupId,
                                              displayName:
                                                  widget.group.displayName,
                                              description:
                                                  widget.group.description,
                                              groupPicture:
                                                  widget.group.groupPicture,
                                              members: widget.group.members,
                                              tags: widget.group.tags,
                                              createdOn: widget.group.createdOn,
                                              updatedOn: widget.group.updatedOn,
                                              createdBy: widget.group.createdBy,
                                              updatedBy: widget.group.updatedBy,
                                            );

                                            _group.groupName =
                                                textController!.text;

                                            var result = await GroupService()
                                                .updateGroupData(
                                                    _group, context,
                                                    isDesktop: true);

                                            if (result is AtGroup) {
                                              // TODO: Doubt
                                              widget.group = _group;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Name updated')));
                                            } else if (result == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          TextConstants()
                                                              .SERVICE_ERROR)));
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          result.toString())));
                                            }
                                          }

                                          setState(() {
                                            updatingName = false;
                                            isEditingName = false;
                                          });
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Icon(
                                            Icons.done,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                        ),
                                      )
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 250.toWidth,
                                        child: RichText(
                                          text: TextSpan(
                                            text:
                                                '${widget.group.groupName}   ',
                                            style: TextStyle(
                                              color: ColorConstants.fontPrimary,
                                              fontSize: 16.toFont,
                                            ),
                                            children: [
                                              WidgetSpan(
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isEditingName = true;
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.edit,
                                                    color: Colors.black,
                                                    size: 20,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${widget.group.members.length} members',
                                        style: CustomTextStyles
                                            .desktopPrimaryRegular14,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                      InkWell(
                        onTap: () async {
                          await Navigator.pushNamed(
                              NavService
                                  .groupPckgRightHalfNavKey.currentContext!,
                              DesktopRoutes.DESKTOP_GROUP_CONTACT_VIEW,
                              arguments: {
                                'onBackArrowTap': () {
                                  Navigator.of(NavService
                                          .groupPckgRightHalfNavKey
                                          .currentContext!)
                                      .pop();
                                },
                                'onDoneTap': () async {
                                  var result = await GroupService()
                                      .addGroupMembers(
                                          GroupService().selecteContactList!,
                                          widget.group);

                                  Navigator.of(NavService
                                          .groupPckgRightHalfNavKey
                                          .currentContext!)
                                      .pop();
                                }
                              });
                        },
                        child: Icon(
                          Icons.add,
                          size: 30.toFont,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // Positioned(
              //     top: 30.toHeight,
              //     left: 10.toWidth,
              //     child: InkWell(
              //       onTap: () => Navigator.pop(context),
              //       child: Icon(
              //         Icons.arrow_back,
              //         color: Colors.black,
              //         size: 25.toFont,
              //       ),
              //     )),
              Positioned(
                top: 30.toHeight,
                right: 10.toWidth,
                child: InkWell(
                  onTap: () async {
                    var _imageBytes = await desktopImagePicker();
                    if (_imageBytes != null) {
                      updateImage(_imageBytes);
                    }
                  },
                  child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: ColorConstants.fadedbackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.image)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void updateImage(selectedImageByteData) async {
    setState(() {
      updatingImage = true;
    });

    var _group = AtGroup(
      widget.group.groupName,
      groupId: widget.group.groupId,
      displayName: widget.group.displayName,
      description: widget.group.description,
      groupPicture: widget.group.groupPicture,
      members: widget.group.members,
      tags: widget.group.tags,
      createdOn: widget.group.createdOn,
      updatedOn: widget.group.updatedOn,
      createdBy: widget.group.createdBy,
      updatedBy: widget.group.updatedBy,
    );

    _group.groupPicture = selectedImageByteData;
    var result =
        await GroupService().updateGroupData(_group, context, isDesktop: true);

    if (result is AtGroup) {
      // TODO: Doubt
      widget.group = _group;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Image updated',
        textAlign: TextAlign.center,
      )));
    } else if (result == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(TextConstants().SERVICE_ERROR)));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.toString())));
    }
    setState(() {
      updatingImage = false;
    });
  }
}
