import 'dart:typed_data';

import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/screens/group_contact/group_list_contact.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/services/image_picker.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/widgets/custom_toast.dart';
import 'package:flutter/material.dart';

class CreateGroupScreen extends StatefulWidget {
  final List<AtContact>? trustContacts;

  const CreateGroupScreen({
    Key? key,
    this.trustContacts,
  }) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  List<AtContact> listContact = [];
  late TextEditingController groupNameController;
  Uint8List? selectedImageByteData;
  late GroupService _groupService;
  bool isLoading = false;

  @override
  void initState() {
    groupNameController = TextEditingController();
    _groupService = GroupService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(27, 24, 27, 0),
                    child: Row(
                      children: [
                        Container(
                          height: 2,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 31,
                              alignment: Alignment.topRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AllColors().DARK_GRAY,
                                ),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Center(
                                child: Text(
                                  "Close",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AllColors().DARK_GRAY,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 27),
                            child: Text(
                              "New Group",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            height: 48,
                            margin: const EdgeInsets.symmetric(horizontal: 27),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AllColors().DARK_GRAY,
                              ),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Center(
                              child: TextField(
                                controller: groupNameController,
                                decoration: InputDecoration.collapsed(
                                  hintText: 'Group Name',
                                  hintStyle: TextStyle(
                                    color: AllColors().DARK_GRAY,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          _buildImage(),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8, bottom: 15, left: 27),
                            child: Text(
                              "Select Members ${listContact.isNotEmpty ? listContact.length : ''}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Flexible(
                            child: GroupListContact(
                              trustedContacts: widget.trustContacts,
                              isSelectMultiContacts: true,
                              onSelectContacts: (contacts) {
                                setState(() {
                                  listContact = [];
                                  for (var element in contacts) {
                                    listContact.add(element.contact!);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24, top: 18),
                      child: InkWell(
                        onTap: () {
                          createGroup();
                        },
                        child: Container(
                          height: 67,
                          margin: const EdgeInsets.symmetric(horizontal: 27),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AllColors().BUTTON_GREY,
                            gradient: groupNameController.text.isNotEmpty &&
                                    listContact.isNotEmpty
                                ? LinearGradient(
                                    colors: [
                                      AllColors().INDICATOR_ORANGE,
                                      AllColors().YELLOW.withOpacity(0.65),
                                    ],
                                  )
                                : null,
                          ),
                          child: const Center(
                            child: Text(
                              "Create Group",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              isLoading
                  ? Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AllColors().INDICATOR_ORANGE,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return InkWell(
      onTap: () async {
        var image = await ImagePicker().pickImage();
        setState(() {
          selectedImageByteData = image;
        });
      },
      child: Container(
        height: 117,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: 27,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AllColors().GRAY,
          image: selectedImageByteData != null
              ? DecorationImage(
                  image: Image.memory(selectedImageByteData!).image,
                  fit: BoxFit.cover,
                )
              : null,
          border: Border.all(
            color: AllColors().DARK_GRAY,
          ),
        ),
        child: selectedImageByteData != null
            ? const SizedBox()
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Insert Cover Image",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AllColors().DARK_GRAY,
                      ),
                    ),
                    const Icon(
                      Icons.image_rounded,
                      size: 60,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void createGroup() async {
    if (groupNameController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      var group = AtGroup(
        groupNameController.text.trim(),
        description: 'group desc',
        displayName: groupNameController.text.trim(),
        members: Set.from(listContact),
        createdBy: _groupService.currentAtsign,
        updatedBy: _groupService.currentAtsign,
      );

      if (selectedImageByteData != null) {
        group.groupPicture = selectedImageByteData;
      }

      var result = await _groupService.createGroup(group);

      setState(() {
        isLoading = false;
      });

      if (result is AtGroup) {
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } else if (result != null) {
        if (result.runtimeType == AlreadyExistsException) {
          if (!mounted) return;
          CustomToast().show(TextConstants().GROUP_ALREADY_EXISTS, context);
        } else if (result.runtimeType == InvalidAtSignException) {
          CustomToast().show(result.message, context);
        } else {
          if (!mounted) return;
          CustomToast().show(TextConstants().SERVICE_ERROR, context);
        }
      } else {
        if (!mounted) return;
        CustomToast().show(TextConstants().SERVICE_ERROR, context);
      }
    } else {
      if (!mounted) return;
      CustomToast().show(TextConstants().EMPTY_NAME, context);
    }
  }
}
