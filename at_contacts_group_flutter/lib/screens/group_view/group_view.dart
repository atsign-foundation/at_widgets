import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/screens/contacts_screen.dart';
import 'package:at_contacts_group_flutter/screens/edit/group_edit.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/utils/images.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/utils/text_styles.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:at_contacts_group_flutter/widgets/error_screen.dart';
import 'package:at_contacts_group_flutter/widgets/person_vertical_tile.dart';
import 'package:at_contacts_group_flutter/widgets/confirmation-dialog.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/at_common_flutter.dart';

class GroupView extends StatefulWidget {
  final AtGroup group;
  GroupView({@required this.group});

  @override
  _GroupViewState createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  // List<AtContact> selectedContactList = GroupService().selecteContactList;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      GroupService().showLoaderSink.add(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AllColors().WHITE
            : AllColors().Black,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                children: [
                  StreamBuilder(
                    stream: GroupService().groupViewStream,
                    builder: (context, AsyncSnapshot<AtGroup> snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          if (snapshot.data.groupPicture != null) {
                            List<int> intList =
                                snapshot.data.groupPicture.cast<int>();
                            Uint8List groupPicture =
                                Uint8List.fromList(intList);

                            return Image.memory(
                              groupPicture,
                              height: 272.toHeight,
                              width: double.infinity,
                              fit: BoxFit.fill,
                            );
                          } else {
                            return Image.asset(
                              AllImages().GROUP_PHOTO,
                              height: 272.toHeight,
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                            );
                          }
                        } else {
                          return SizedBox();
                        }
                      } else {
                        return Image.asset(
                          AllImages().GROUP_PHOTO,
                          height: 272.toHeight,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: 60.toHeight,
                  ),
                  Container(
                    child: StreamBuilder(
                      stream: GroupService().showLoaderStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.data == true)
                            return CircularProgressIndicator();
                          else
                            return SizedBox();
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.toWidth, vertical: 0.toHeight),
                      child: StreamBuilder(
                        stream: GroupService().groupViewStream,
                        builder: (context, AsyncSnapshot<AtGroup> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            if (snapshot.hasError) {
                              return ErrorScreen(
                                onPressed: () {
                                  GroupService()
                                      .updateGroupStreams(widget.group);
                                },
                              );
                            } else {
                              if (snapshot.hasData) {
                                AtGroup groupData = snapshot.data;
                                return GridView.count(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  crossAxisCount: 4,
                                  childAspectRatio:
                                      ((SizeConfig().screenWidth * 0.25) /
                                          (SizeConfig().screenHeight * 0.2)),
                                  children: List.generate(
                                      groupData.members.length, (index) {
                                    return InkWell(
                                      onTap: () {
                                        if (index < groupData.members.length) {
                                          return showMyDialog(
                                              context,
                                              groupData.members
                                                  .elementAt(index),
                                              widget.group);
                                        } else {
                                          GroupService()
                                              .updateGroupStreams(widget.group);
                                        }
                                      },
                                      child: CustomPersonVerticalTile(
                                        imageLocation: null,
                                        title: groupData.members
                                                    .elementAt(index)
                                                    .tags !=
                                                null
                                            ? groupData.members
                                                .elementAt(index)
                                                .tags['name']
                                            : null,
                                        subTitle: groupData.members
                                            .elementAt(index)
                                            .atSign,
                                        isAssetImage: false,
                                        atsign: groupData.members
                                            .elementAt(index)
                                            .atSign,
                                      ),
                                    );
                                  }),
                                );
                              } else {
                                return SizedBox();
                              }
                            }
                          } else
                            return SizedBox();
                        },
                      )),
                ],
              ),
              Positioned(
                top: 240.toHeight,
                child: Container(
                  height: 80.toHeight,
                  width: 343.toWidth,
                  margin: EdgeInsets.symmetric(
                      horizontal: 15.toWidth, vertical: 0.toHeight),
                  padding: EdgeInsets.symmetric(
                      horizontal: 15.toWidth, vertical: 10.toHeight),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).brightness == Brightness.light
                        ? AllColors().WHITE
                        : AllColors().Black,
                    boxShadow: [
                      BoxShadow(
                        color: AllColors().DARK_GREY,
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StreamBuilder(
                              stream: GroupService().groupViewStream,
                              builder:
                                  (context, AsyncSnapshot<AtGroup> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.active) {
                                  AtGroup groupData = snapshot.data;
                                  return Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 250.toWidth,
                                          child: Text(
                                            groupData.displayName,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            // softWrap: false,
                                            style: TextStyle(
                                              color: AllColors().GREY,
                                              fontSize: 16.toFont,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${groupData.members.length} members',
                                          style: CustomTextStyles().grey14,
                                        ),
                                      ],
                                    ),
                                  );
                                } else
                                  return SizedBox();
                              }),
                        ],
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContactsScreen(
                                asSelectionScreen: true,
                                context: context,
                                selectedList: (selectedList) async {
                                  GroupService().selecteContactList =
                                      selectedList;
                                },
                                saveGroup: () async {
                                  if (GroupService().selecteContactList.length >
                                      0) {
                                    GroupService().showLoaderSink.add(true);

                                    var result = await GroupService()
                                        .addGroupMembers([
                                      ...GroupService().selecteContactList
                                    ], widget.group);

                                    GroupService().showLoaderSink.add(false);
                                    if (result == null) {
                                      CustomToast().show(
                                          TextConstants().SERVICE_ERROR,
                                          context);
                                    } else if (result is bool && result) {
                                      // CustomToast().show(
                                      //     TextConstants().MEMBER_ADDED,
                                      //     context);

                                    } else
                                      CustomToast().show(
                                          TextConstants().SERVICE_ERROR,
                                          context);
                                  }
                                },
                              ),
                            ),
                          );
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
              Positioned(
                  top: 30.toHeight,
                  left: 10.toWidth,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back,
                      color: AllColors().Black,
                    ),
                  )),
              Positioned(
                top: 30.toHeight,
                right: 10.toWidth,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GroupEdit(group: widget.group)),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: AllColors().Black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showMyDialog(
      BuildContext context, AtContact contact, AtGroup group) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: contact.atSign,
          heading: 'Are you sure you want to remove from the group?',
          onYesPressed: () async {
            var result =
                await GroupService().deletGroupMembers([contact], widget.group);

            if (result is bool) {
              result ? Navigator.of(context).pop() : null;
            } else if (result == null) {
              CustomToast().show(TextConstants().SERVICE_ERROR, context);
            } else {
              CustomToast().show(result.toString(), context);
            }
          },
        );
      },
    );
  }
}
