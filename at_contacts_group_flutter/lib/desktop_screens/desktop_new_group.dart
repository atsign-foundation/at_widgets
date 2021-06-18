import 'dart:typed_data';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_flutter/widgets/common_button.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/utils/text_styles.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:at_contacts_group_flutter/widgets/dektop_custom_person_tile.dart';
import 'package:flutter/material.dart';

class DesktopNewGroup extends StatefulWidget {
  final Function? onPop, onDone;
  DesktopNewGroup({this.onPop, @required this.onDone});
  @override
  _DesktopNewGroupState createState() => _DesktopNewGroupState();
}

class _DesktopNewGroupState extends State<DesktopNewGroup> {
  List<AtContact?>? selectedContacts;
  String groupName = '';
  Uint8List? selectedImageByteData;
  bool isKeyBoardVisible = false, showEmojiPicker = false;
  TextEditingController textController = TextEditingController();
  UniqueKey key = UniqueKey();
  FocusNode textFieldFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  // ignore: always_declare_return_types
  getContacts() {
    if (GroupService().selecteContactList!.isNotEmpty) {
      selectedContacts = GroupService().selecteContactList;
    } else {
      selectedContacts = [];
    }
  }

  createGroup() async {
    groupName = textController.text;
    // ignore: unnecessary_null_comparison
    if (groupName != null) {
      // if (groupName.contains(RegExp(TextConstants().GROUP_NAME_REGEX))) {
      //   CustomToast().show(TextConstants().INVALID_NAME, context);
      //   return;
      // }

      if (groupName.trim().isNotEmpty) {
        var group = AtGroup(
          groupName,
          description: 'group desc',
          displayName: groupName,
          members: Set.from(selectedContacts!),
          createdBy: GroupService().currentAtsign,
          updatedBy: GroupService().currentAtsign,
        );

        if (selectedImageByteData != null) {
          group.groupPicture = selectedImageByteData;
        }

        var result = await GroupService().createGroup(group);

        if (result is AtGroup) {
          // Navigator.of(context).pop();
          widget.onDone!();
        } else if (result != null) {
          if (result.runtimeType == AlreadyExistsException) {
            CustomToast().show(TextConstants().GROUP_ALREADY_EXISTS, context,
                gravity: 0);
          } else if (result.runtimeType == InvalidAtSignException) {
            CustomToast().show(result.message, context, gravity: 0);
          } else {
            CustomToast()
                .show(TextConstants().SERVICE_ERROR, context, gravity: 0);
          }
        } else {
          CustomToast()
              .show(TextConstants().SERVICE_ERROR, context, gravity: 0);
        }
      } else {
        CustomToast().show(TextConstants().EMPTY_NAME, context, gravity: 0);
      }
    } else {
      CustomToast().show(TextConstants().EMPTY_NAME, context, gravity: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorConstants.listBackground,
        persistentFooterButtons: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${selectedContacts!.length} Contacts Selected',
                  style: CustomTextStyles.primaryRegular20,
                ),
                CommonButton(
                  'Done',
                  () async {
                    await createGroup();
                    widget.onDone!();
                  },
                  color: ColorConstants.orangeColor,
                  border: 3,
                  height: 45,
                  width: 130,
                  fontSize: 20,
                  removePadding: true,
                ),
              ],
            ),
          )
        ],
        body: Stack(
          children: [
            Column(
              children: <Widget>[
                SizedBox(height: 20.toHeight),
                GestureDetector(
                  onTap: () async {},
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 15),
                        width: 100.toWidth,
                        height: 100.toWidth,
                        decoration: BoxDecoration(
                          color: ColorConstants.dividerColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: false
                              ? SizedBox(
                                  width: 68.toWidth,
                                  height: 68.toWidth,
                                  // child: CircleAvatar(
                                  //   backgroundImage:
                                  //       Image.memory().image,
                                  // ),
                                )
                              : SizedBox(),
                        ),
                      ),
                      Positioned(
                          bottom: -5,
                          right: -5,
                          child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: ColorConstants.fadedbackground,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.image)))
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 15.toWidth,
                    ),
                    SizedBox(width: 10.toWidth),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: Container(
                              width: ((SizeConfig().screenWidth -
                                          TextConstants.SIDEBAR_WIDTH) /
                                      2) -
                                  150,
                              height: 50.toHeight,
                              decoration: BoxDecoration(
                                color: ColorConstants.listBackground,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      readOnly: false,
                                      style: TextStyle(
                                        fontSize: 15.toFont,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Enter Group Name',
                                        enabledBorder: UnderlineInputBorder(),
                                        border: UnderlineInputBorder(),
                                        hintStyle:
                                            TextStyle(fontSize: 15.toFont),
                                      ),
                                      onTap: () {},
                                      onChanged: (val) {},
                                      controller: textController,
                                      onSubmitted: (str) {},
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {},
                                    child: Icon(
                                      Icons.emoji_emotions_outlined,
                                      color: Colors.grey,
                                      size: 20.toFont,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 13.toHeight),
                Divider(),
                SizedBox(height: 13.toHeight),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(right: 15, left: 15),
                    child: SingleChildScrollView(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        runSpacing: 10.0,
                        spacing: 50.0,
                        children:
                            List.generate(selectedContacts!.length, (index) {
                          return DesktopCustomPersonVerticalTile(
                            title: selectedContacts![index]!.atSign,
                            subTitle: selectedContacts![index]!.atSign,
                            showCancelIcon: true,
                            onRemovePress: () {
                              setState(() {
                                selectedContacts!.removeAt(index);
                              });
                            },
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            widget.onPop != null
                ? Positioned(
                    top: 20,
                    left: 20,
                    child: InkWell(
                        onTap: () {
                          widget.onPop!();
                        },
                        child: Icon(Icons.arrow_back,
                            size: 25, color: Colors.black)),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
