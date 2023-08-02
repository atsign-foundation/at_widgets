// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_common_flutter/widgets/custom_app_bar.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/utils/images.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/utils/text_styles.dart';
import 'package:at_contacts_group_flutter/widgets/confirmation_dialog.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_cover_image_picker.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_group_contacts_list.dart';
import 'package:at_contacts_group_flutter/widgets/icon_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';

// ignore: must_be_immutable
class DesktopGroupDetail extends StatefulWidget {
  AtGroup group;
  int currentIndex;
  Function()? onBackArrowTap;

  DesktopGroupDetail({
    Key? key,
    required this.group,
    required this.currentIndex,
    this.onBackArrowTap,
  }) : super(key: key);

  @override
  _DesktopGroupDetailState createState() => _DesktopGroupDetailState();
}

class _DesktopGroupDetailState extends State<DesktopGroupDetail> {
  bool isEditingName = false, updatingName = false, updatingImage = false;
  TextEditingController? textController;
  Uint8List? groupImage;

  @override
  void initState() {
    textController = TextEditingController.fromValue(
      TextEditingValue(
        text: widget.group.groupName ?? '',
        selection: const TextSelection.collapsed(offset: -1),
      ),
    );
    if (widget.group.groupPicture != null) {
      groupImage = Uint8List.fromList(
        widget.group.groupPicture.cast<int>(),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          isDesktop: true,
          showTitle: true,
          centerTitle: false,
          titleText: widget.group.displayName,
          titleTextStyle: CustomTextStyles.blackW50020,
          leadingIcon: InkWell(
            onTap: () {
              if (widget.onBackArrowTap != null) {
                widget.onBackArrowTap!();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.asset(
                AllImages().back,
                width: 8,
                height: 20,
                package: 'at_contacts_group_flutter',
              ),
            ),
          ),
          showLeadingIcon: true,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            DesktopCoverImagePicker(
              selectedImage: groupImage,
              isEdit: false,
              onSelected: (value) {
                updateImage(value);
              },
            ),
            SizedBox(height: 20.toHeight),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Transfer File ",
                      style: CustomTextStyles.whiteBold12,
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      AllImages().enter,
                      width: 16,
                      height: 12,
                      fit: BoxFit.cover,
                      package: 'at_contacts_group_flutter',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButtonWidget(
                  icon: AllImages().edit,
                  backgroundColor: AllColors().iconButtonColor,
                  onTap: () {},
                ),
                const SizedBox(width: 24),
                IconButtonWidget(
                  icon: AllImages().delete,
                  backgroundColor: AllColors().iconButtonColor,
                  onTap: () async {
                    await showMyDialog(context, widget.group);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            DesktopGroupContactsList(
              initialData: widget.group.members
                  ?.map((e) => GroupContactsModel(
                        contact: e,
                      ))
                  .toList(),
            ),
          ],
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
    var result = await GroupService().updateGroupData(_group, context,
        isDesktop: true, expandIndex: widget.currentIndex);

    if (result is AtGroup) {
      // ignore: todo
      // TODO: Doubt
      widget.group = _group;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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

  Future<void> showMyDialog(BuildContext context, AtGroup group) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        Uint8List? groupPicture;
        if (group.groupPicture != null) {
          List<int> intList = group.groupPicture.cast<int>();
          groupPicture = Uint8List.fromList(intList);
        }
        return ConfirmationDialog(
          title: '${group.displayName}',
          heading: 'Are you sure you want to delete this group?',
          onYesPressed: () async {
            var result = await GroupService().deleteGroup(group);

            if (!mounted) return;
            if (result != null && result) {
              Navigator.of(context).pop();
            } else {
              CustomToast().show(TextConstants().SERVICE_ERROR, context);
            }
          },
          image: groupPicture,
        );
      },
    );
  }
}
