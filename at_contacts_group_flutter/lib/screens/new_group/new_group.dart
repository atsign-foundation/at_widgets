import 'dart:typed_data';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/services/image_picker.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/widgets/bottom_sheet.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:at_contacts_group_flutter/widgets/person_vertical_tile.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_commons/src/exception/at_exceptions.dart';
import 'package:emoji_picker/emoji_picker.dart';

class NewGroup extends StatefulWidget {
  @override
  _NewGroupState createState() => _NewGroupState();
}

class _NewGroupState extends State<NewGroup> {
  List<AtContact> selectedContacts;
  String groupName = '';
  Uint8List selectedImageByteData;
  bool isKeyBoardVisible = false, showEmojiPicker = false;
  TextEditingController textController = TextEditingController();
  UniqueKey key = UniqueKey();
  FocusNode textFieldFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  getContacts() {
    if (GroupService().selecteContactList.isNotEmpty) {
      selectedContacts = GroupService().selecteContactList;
    } else {
      selectedContacts = [];
    }
  }

  createGroup() async {
    bool isKeyboardOpen =
        MediaQuery.of(context).viewInsets.bottom != 0 ? true : false;
    groupName = textController.text;
    if (groupName != null) {
      // if (groupName.contains(RegExp(TextConstants().GROUP_NAME_REGEX))) {
      //   CustomToast().show(TextConstants().INVALID_NAME, context);
      //   return;
      // }

      if (groupName.trim().isNotEmpty) {
        AtGroup group = AtGroup(
          groupName,
          description: 'group desc',
          displayName: groupName,
          members: Set.from(selectedContacts),
          createdBy: GroupService().currentAtsign,
          updatedBy: GroupService().currentAtsign,
        );

        if (this.selectedImageByteData != null) {
          group.groupPicture = this.selectedImageByteData;
        }

        var result = await GroupService().createGroup(group);

        isKeyboardOpen =
            MediaQuery.of(context).viewInsets.bottom != 0 ? true : false;

        if (result is AtGroup) {
          Navigator.of(context).pop();
        } else if (result != null) {
          if (result.runtimeType == AlreadyExistsException) {
            CustomToast().show(TextConstants().GROUP_ALREADY_EXISTS, context,
                gravity: isKeyboardOpen ? 2 : 0);
          } else if (result.runtimeType == InvalidAtSignException) {
            CustomToast()
                .show(result.message, context, gravity: isKeyboardOpen ? 2 : 0);
          } else {
            CustomToast().show(TextConstants().SERVICE_ERROR, context,
                gravity: isKeyboardOpen ? 2 : 0);
          }
        } else {
          CustomToast().show(TextConstants().SERVICE_ERROR, context,
              gravity: isKeyboardOpen ? 2 : 0);
        }
      } else {
        CustomToast().show(TextConstants().EMPTY_NAME, context,
            gravity: isKeyboardOpen ? 2 : 0);
      }
    } else {
      CustomToast().show(TextConstants().EMPTY_NAME, context,
          gravity: isKeyboardOpen ? 2 : 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AllColors().WHITE
            : AllColors().Black,
        bottomSheet: GroupBottomSheet(
          onPressed: createGroup,
          message: '${selectedContacts.length} Contacts Selected',
          buttontext: 'Done',
        ),
        appBar: CustomAppBar(
            titleText: 'New Group',
            showTitle: true,
            showBackButton: true,
            showLeadingIcon: true),
        body: Column(
          children: <Widget>[
            SizedBox(height: 20.toHeight),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 15.toWidth,
                ),
                InkWell(
                  onTap: () async {
                    var image = await ImagePicker().pickImage();
                    setState(() {
                      selectedImageByteData = image;
                    });
                  },
                  child: Container(
                    width: 68.toWidth,
                    height: 68.toWidth,
                    decoration: BoxDecoration(
                      color: AllColors().MILD_GREY,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: this.selectedImageByteData != null
                          ? SizedBox(
                              width: 68.toWidth,
                              height: 68.toWidth,
                              child: CircleAvatar(
                                backgroundImage:
                                    Image.memory(this.selectedImageByteData)
                                        .image,
                              ),
                            )
                          : Icon(Icons.add, color: AllColors().ORANGE),
                    ),
                  ),
                ),
                SizedBox(width: 10.toWidth),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Group name', style: TextStyle(fontSize: 18.toFont)),
                      SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Container(
                          width: 330.toWidth,
                          height: 50.toHeight,
                          decoration: BoxDecoration(
                            color: AllColors().INPUT_FIELD_COLOR,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  readOnly: false,
                                  focusNode: textFieldFocus,
                                  style: TextStyle(
                                    fontSize: 15.toFont,
                                  ),
                                  decoration: InputDecoration(
                                    // hintText: hintText,
                                    enabledBorder: InputBorder.none,
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                        color: AllColors().INPUT_FIELD_COLOR,
                                        fontSize: 15.toFont),
                                  ),
                                  onTap: () {
                                    if (showEmojiPicker) {
                                      setState(() {
                                        showEmojiPicker = false;
                                      });
                                    }
                                  },
                                  onChanged: (val) {},
                                  controller: textController,
                                  onSubmitted: (str) {},
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  showEmojiPicker = !showEmojiPicker;
                                  if (showEmojiPicker) {
                                    textFieldFocus.unfocus();
                                  }

                                  setState(() {});
                                },
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
                  child: GridView.count(
                    physics: ScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    childAspectRatio: ((SizeConfig().screenWidth * 0.25) /
                        (SizeConfig().screenHeight * 0.2)),
                    children: List.generate(selectedContacts.length, (index) {
                      return CustomPersonVerticalTile(
                        imageLocation: null,
                        title: selectedContacts[index].atSign,
                        subTitle: selectedContacts[index].atSign,
                        icon: Icons.close,
                        isTopRight: true,
                        atsign: selectedContacts[index].atSign,
                        onCrossPressed: () {
                          setState(() {
                            selectedContacts.removeAt(index);
                          });
                        },
                      );
                    }),
                  ),
                ),
              ),
            ),
            showEmojiPicker
                ? Container(
                    margin: EdgeInsets.only(bottom: 70.toHeight),
                    child: EmojiPicker(
                      key: UniqueKey(),
                      rows: 5,
                      columns: 8,
                      buttonMode: ButtonMode.MATERIAL,
                      numRecommended: 10,
                      onEmojiSelected: (emoji, category) {
                        textController.text += emoji.emoji;
                      },
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }
}
