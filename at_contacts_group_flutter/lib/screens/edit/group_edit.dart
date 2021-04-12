import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/services/image_picker.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/utils/images.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/utils/text_styles.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'dart:typed_data';
import 'package:emoji_picker/emoji_picker.dart';

class GroupEdit extends StatefulWidget {
  final AtGroup group;
  GroupEdit({@required this.group});

  @override
  _GroupEditState createState() => _GroupEditState();
}

class _GroupEditState extends State<GroupEdit> {
  String groupName;
  bool isLoading;
  Uint8List groupPicture;
  bool isKeyBoardVisible = false, showEmojiPicker = false;
  TextEditingController textController;
  FocusNode textFieldFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    isLoading = false;
    if (widget.group != null) groupName = widget.group.displayName;

    textController = TextEditingController.fromValue(
      TextEditingValue(
        text: groupName != null ? groupName : '',
        selection: TextSelection.collapsed(offset: -1),
      ),
    );

    if (widget.group.groupPicture != null) {
      List<int> intList = widget.group.groupPicture.cast<int>();
      groupPicture = Uint8List.fromList(intList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          showLeadingIcon: true,
          leadingIcon: Center(
            child: Container(
              padding: EdgeInsets.only(left: 10),
              child: GestureDetector(
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AllColors().Black
                          : AllColors().Black,
                      fontSize: 14.toFont),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          showTrailingIcon: true,
          showTitle: false,
          titleText: '',
          trailingIcon: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 20.toHeight,
                      height: 20.toHeight,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Text('Done',
                    style: TextStyle(
                        color: AllColors().ORANGE, fontSize: 15.toFont)),
          ),
          onTrailingIconPressed: () async {
            groupName = textController.text;
            if (groupName != null) {
              if (groupName.trim().isNotEmpty) {
                AtGroup group = widget.group;
                group.displayName = groupName;
                group.groupName = groupName;
                setState(() {
                  isLoading = true;
                });

                await GroupService().updateGroupData(group, context);
              } else {
                CustomToast().show(TextConstants().INVALID_NAME, context);
              }
            } else {
              CustomToast().show(TextConstants().INVALID_NAME, context);
            }

            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (widget.group.groupPicture != null && groupPicture != null)
                ? Image.memory(
                    groupPicture,
                    width: double.infinity,
                    height: 272.toHeight,
                    fit: BoxFit.fill,
                  )
                : Image.asset(
                    AllImages().GROUP_PHOTO,
                    height: 272.toHeight,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    package: 'at_contacts_group_flutter',
                  ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 27.toWidth, vertical: 15.toHeight),
              child: InkWell(
                onTap: () => bottomSheetContent(
                  context,
                  119.toHeight,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Edit group Picture',
                      style: CustomTextStyles().orange12,
                    ),
                    SizedBox(
                      width: 5.toWidth,
                    ),
                    Icon(
                      Icons.edit,
                      color: AllColors().ORANGE,
                      size: 20.toFont,
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 27.toWidth, vertical: 2.toHeight),
                      child: Text(
                        'Group Name',
                        style: CustomTextStyles().grey16,
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 27.toWidth, vertical: 2.toHeight),
                        child: Container(
                          width: double.infinity,
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
                                  style: TextStyle(fontSize: 15.toFont),
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
                                ),
                              )
                            ],
                          ),
                        )),
                    showEmojiPicker
                        ? Stack(children: [
                            Container(
                              // bottom: 0,
                              child: EmojiPicker(
                                key: UniqueKey(),
                                rows: 5,
                                columns: 8,
                                buttonMode: ButtonMode.MATERIAL,
                                // recommendKeywords: ["happy", "sad"],
                                numRecommended: 10,
                                onEmojiSelected: (emoji, category) {
                                  textController.text += emoji.emoji;
                                },
                              ),
                            ),
                          ])
                        : SizedBox()
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void bottomSheetContent(BuildContext context, double height) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: StadiumBorder(),
        builder: (BuildContext context) {
          return Container(
            height: 119.toHeight,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? AllColors().WHITE
                  : AllColors().Black,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12.0),
                topRight: const Radius.circular(12.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      var image = await ImagePicker().pickImage();
                      setState(() {
                        widget.group.groupPicture = image;
                        groupPicture = image;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Change Group Photo',
                      style: CustomTextStyles().grey16,
                    ),
                  ),
                  Divider(),
                  InkWell(
                    onTap: () {
                      setState(() {
                        widget.group.groupPicture = null;
                        groupPicture = null;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Remove Group Photo',
                      style: CustomTextStyles().grey16,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
