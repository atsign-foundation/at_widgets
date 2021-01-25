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

  @override
  void initState() {
    super.initState();
    isLoading = false;
    if (widget.group != null) groupName = widget.group.displayName;

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
            child: GestureDetector(
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: Theme.of(context).primaryColor, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          showTrailingIcon: true,
          showTitle: false,
          titleText: '',
          trailingIcon: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : Text('Done',
                    style: TextStyle(
                        color: Theme.of(context).accentColor, fontSize: 18)),
          ),
          onTrailingIconPressed: () async {
            if (groupName != null) {
              if (groupName.trim().length > 0) {
                AtGroup group = widget.group;
                group.displayName = groupName;
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
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 27.toWidth, vertical: 2.toHeight),
              child: Text(
                'Group Name',
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 27.toWidth, vertical: 2.toHeight),
              child: CustomInputField(
                icon: Icons.emoji_emotions_outlined,
                width: double.infinity,
                initialValue: groupName,
                value: (String val) {
                  groupName = val;
                },
              ),
            )
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
            decoration: new BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: new BorderRadius.only(
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
                      style: Theme.of(context).textTheme.headline3,
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
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
