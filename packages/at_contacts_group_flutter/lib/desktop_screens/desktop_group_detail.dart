// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:at_common_flutter/widgets/custom_app_bar.dart';
import 'package:at_commons/at_commons.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/utils/images.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/utils/text_styles.dart';
import 'package:at_contacts_group_flutter/widgets/confirmation_dialog.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_cover_image_picker.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_floating_add_contact_button.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_group_contacts_list.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_group_name_text_field.dart';
import 'package:at_contacts_group_flutter/widgets/icon_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:at_contact/at_contact.dart';

// ignore: must_be_immutable
class DesktopGroupDetail extends StatefulWidget {
  AtGroup group;
  int currentIndex;
  Function()? onBackArrowTap;
  bool isEditing;

  DesktopGroupDetail({
    Key? key,
    required this.group,
    required this.currentIndex,
    this.onBackArrowTap,
    this.isEditing = false,
  }) : super(key: key);

  @override
  _DesktopGroupDetailState createState() => _DesktopGroupDetailState();
}

class _DesktopGroupDetailState extends State<DesktopGroupDetail> {
  bool isEditingName = false, updatingName = false, updatingImage = false;
  TextEditingController? textController;
  Uint8List? groupImage;
  late bool isEditing;
  bool isAddingContacts = false;
  late TextEditingController groupNameController;

  @override
  void initState() {
    isEditing = widget.isEditing;
    groupNameController =
        TextEditingController(text: widget.group.displayName ?? '');
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
    if (isAddingContacts) {
      GroupService().fetchGroupsAndContacts(isDesktop: true);
      if ((widget.group.members ?? {}).isNotEmpty) {
        for (var i in widget.group.members ?? {}) {
          GroupService().addGroupContact(
            GroupContactsModel(
              contact: i,
              contactType: ContactsType.CONTACT,
            ),
          );
        }
      }
    } else {
      GroupService().selectedGroupContacts.clear();
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          isDesktop: true,
          showTitle: true,
          centerTitle: false,
          titleText: isEditing ? 'Edit' : widget.group.displayName,
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
          showTrailingIcon: isEditing,
          trailingIcon: InkWell(
            onTap: () async {
              await updateGroup();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 8),
              margin: const EdgeInsets.only(right: 28),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(46),
                color: AllColors().buttonColor,
              ),
              child: Text(
                'Save',
                style: CustomTextStyles.whiteW50015,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                if (isEditing) ...[
                  DesktopGroupNameTextField(
                    groupNameController: groupNameController,
                  ),
                  const SizedBox(height: 16),
                ],
                DesktopCoverImagePicker(
                  selectedImage: groupImage,
                  isEdit: isEditing,
                  onSelected: (value) {
                    setState(() {
                      groupImage = value;
                    });
                  },
                ),
                SizedBox(height: isEditing ? 16 : 20),
                buildDetailOptions(),
                const SizedBox(height: 12),
                DesktopGroupContactsList(
                  asSelectionScreen: isAddingContacts,
                  selectedList: (selectedContactList) {
                    GroupService().setSelectedContacts(
                        selectedContactList.map((e) => e?.contact).toList());
                  },
                  initialData: isAddingContacts
                      ? []
                      : widget.group.members
                          ?.map((e) => GroupContactsModel(
                                contact: e,
                              ))
                          .toList(),
                ),
              ],
            ),
            if (isAddingContacts) const DesktopFloatingAddContactButton(),
          ],
        ),
      ),
    );
  }

  Widget buildDetailOptions() {
    return isEditing
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButtonWidget(
                icon: AllImages().add,
                isSelected: isAddingContacts,
                onTap: () async {
                  setState(() {
                    isAddingContacts = !isAddingContacts;
                  });
                },
                backgroundColor: AllColors().iconButtonColor,
              ),
              const SizedBox(width: 20),
              IconButtonWidget(
                icon: AllImages().share,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                onTap: () {},
                backgroundColor: AllColors().iconButtonColor,
              ),
              const SizedBox(width: 20),
              IconButtonWidget(
                icon: AllImages().delete,
                onTap: () async {
                  await showMyDialog(context, widget.group);
                },
                backgroundColor: AllColors().iconButtonColor,
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.black,
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                    onTap: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
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
            ],
          );
  }

  // void updateImage(selectedImageByteData) async {
  //   setState(() {
  //     updatingImage = true;
  //   });
  //
  //   var _group = AtGroup(
  //     widget.group.groupName,
  //     groupId: widget.group.groupId,
  //     displayName: widget.group.displayName,
  //     description: widget.group.description,
  //     groupPicture: widget.group.groupPicture,
  //     members: widget.group.members,
  //     tags: widget.group.tags,
  //     createdOn: widget.group.createdOn,
  //     updatedOn: widget.group.updatedOn,
  //     createdBy: widget.group.createdBy,
  //     updatedBy: widget.group.updatedBy,
  //   );
  //
  //   _group.groupPicture = selectedImageByteData;
  //   var result = await GroupService().updateGroupData(_group, context,
  //       isDesktop: true, expandIndex: widget.currentIndex);
  //
  //   if (result is AtGroup) {
  //     // ignore: todo
  //     // TODO: Doubt
  //     widget.group = _group;
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text(
  //       'Image updated',
  //       textAlign: TextAlign.center,
  //     )));
  //   } else if (result == null) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text(TextConstants().SERVICE_ERROR)));
  //   } else {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text(result.toString())));
  //   }
  //   setState(() {
  //     updatingImage = false;
  //   });
  // }

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

  updateGroup() async {
    String groupName = groupNameController.text;
    // ignore: unnecessary_null_comparison
    if (groupName != null) {
      // if (groupName.contains(RegExp(TextConstants().GROUP_NAME_REGEX))) {
      //   CustomToast().show(TextConstants().INVALID_NAME, context);
      //   return;
      // }

      if (groupName.trim().isNotEmpty) {
        var group = AtGroup(
          groupName != widget.group.displayName
              ? groupName
              : widget.group.displayName,
          groupId: widget.group.groupId,
          description: widget.group.description,
          displayName: groupName != widget.group.displayName
              ? groupName
              : widget.group.displayName,
          groupPicture: groupImage != widget.group.groupPicture
              ? groupImage
              : widget.group.groupPicture,
          members: GroupService().selectedGroupContacts.isEmpty
              ? widget.group.members
              : Set.from(GroupService()
                  .selectedGroupContacts
                  .map((element) => element?.contact)),
          createdBy: GroupService().currentAtsign,
          updatedBy: GroupService().currentAtsign,
        );
        var result = await GroupService().updateGroup(group);
        if (result is AtGroup) {
          //ignore: across_async_gaps
          if (context.mounted) Navigator.of(context).pop();

          // widget.onDone!();

          GroupService().setSelectedContacts([]);

        } else if (result != null) {
          if (mounted) {
            if (result.runtimeType == AlreadyExistsException) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(TextConstants().GROUP_ALREADY_EXISTS)));
            } else if (result.runtimeType == InvalidAtSignException) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(result.message)));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(TextConstants().SERVICE_ERROR)));
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(TextConstants().SERVICE_ERROR)));
          }
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(TextConstants().EMPTY_NAME)));
      }
    } else {
      CustomToast().show(TextConstants().EMPTY_NAME, context, gravity: 0);
    }
  }
}
