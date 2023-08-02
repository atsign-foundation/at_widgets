import 'dart:typed_data';

import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:at_contacts_flutter/widgets/contacts_initials.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_route_names.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_routes.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/services/navigation_service.dart';
import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/utils/images.dart';
import 'package:at_contacts_group_flutter/utils/text_styles.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_header.dart';
import 'package:at_contacts_group_flutter/widgets/icon_button_widget.dart';
import 'package:flutter/material.dart';

class DesktopGroupList extends StatefulWidget {
  final List<AtGroup> groups;
  final int expandIndex;
  final bool showBackButton;
  final Function(bool) onCallback;

  const DesktopGroupList(
    this.groups, {
    Key? key,
    this.expandIndex = 0,
    this.showBackButton = true,
    required this.onCallback,
  }) : super(key: key);

  @override
  _DesktopGroupListState createState() => _DesktopGroupListState();
}

class _DesktopGroupListState extends State<DesktopGroupList> {
  String searchText = '';
  bool showBackIcon = true;
  List<AtGroup> _filteredList = [];
  bool isSearching = false;

  @override
  void initState() {
    showBackIcon = GroupService().groupPreferece.showBackButton;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (searchText != '') {
      _filteredList = widget.groups.where((grp) {
        return grp.displayName!.contains(searchText);
      }).toList();
    } else {
      _filteredList = widget.groups;
    }
    return Container(
      color: const Color(0xFFF8F8F8),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          DesktopHeader(
            title: 'Groups',
            isTitleCentered: false,
            showBackIcon: showBackIcon,
            onBackTap: () {
              DesktopGroupSetupRoutes.exitGroupPackage();
            },
            actions: [
              isSearching
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        height: 40,
                        width: 308,
                        color: Colors.white,
                        child: TextField(
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 8),
                            border: InputBorder.none,
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              color: AllColors().searchHintTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    searchText = '';
                                    isSearching = false;
                                  });
                                },
                                child: const Icon(Icons.close)),
                          ),
                        ),
                      ),
                    )
                  : IconButtonWidget(
                      icon: AllImages().search,
                      onTap: () {
                        setState(() {
                          isSearching = true;
                        });
                      },
                    ),
              const SizedBox(width: 12),
              IconButtonWidget(
                icon: AllImages().refresh,
                onTap: () {
                  setState(() async {
                    await GroupService().getAllGroupsDetails();
                  });
                },
              ),
              const SizedBox(width: 12),
              buildAddGroupButton(),
            ],
          ),
          Expanded(
            child: _filteredList.isEmpty
                ? Center(
                    child: Text(
                      TextStrings().noContactsFound,
                      style: TextStyle(
                        fontSize: 15.toFont,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  )
                : ListView(
                    physics: const ClampingScrollPhysics(),
                    children: buildGroupList(),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildGroupList() {
    final List<Widget> result = [];
    if (_filteredList.isNotEmpty) {
      final List<AtGroup> sortedList = sortGroupAlphabetical();
      bool isSameCharWithPrev(int i) =>
          (((sortedList[i].displayName ?? '').isNotEmpty
                  ? sortedList[i].displayName![0]
                  : ' ') !=
              ((sortedList[i - 1].displayName ?? '').isNotEmpty
                  ? sortedList[i - 1].displayName![0]
                  : ' '));

      bool isPrevCharacter(int i) => RegExp(r'^[a-z]+$').hasMatch(
          (((sortedList[i - 1].displayName ?? '').isNotEmpty
                  ? sortedList[i - 1].displayName![0]
                  : ' '))[0]
              .toLowerCase());

      for (int i = 0; i < sortedList.length; i++) {
        if (i == 0 || (isSameCharWithPrev(i) && isPrevCharacter(i))) {
          result.add(buildAlphabeticalTitle(
              (sortedList[i].displayName ?? '').isNotEmpty
                  ? sortedList[i].displayName![0]
                  : ''));
        }
        result.add(
          buildGroupCard(
            index: i,
            data: sortedList[i],
          ),
        );
      }
    }
    return result;
  }

  Widget buildGroupCard({
    required AtGroup data,
    required int index,
  }) {
    return InkWell(
      onTap: () {
        widget.onCallback(true);
        Navigator.of(NavService.groupPckgRightHalfNavKey.currentContext!)
            .pushNamed(DesktopRoutes.DESKTOP_GROUP_DETAIL, arguments: {
          'group': data,
          'currentIndex': index,
          'onBackArrowTap': () {
            Navigator.of(NavService.groupPckgRightHalfNavKey.currentContext!)
                .pop();
            widget.onCallback(false);
          },
        });
      },
      child: Container(
        height: 72,
        margin: const EdgeInsets.only(
          bottom: 12,
          left: 80,
          right: 80,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: data.groupPicture != null
                      ? Image.memory(
                          Uint8List.fromList(data.groupPicture.cast<int>()),
                          fit: BoxFit.cover,
                          width: 72,
                        )
                      : ContactInitial(
                          size: 72,
                          isDesktop: true,
                          initials: ((data.displayName ?? '').isNotEmpty &&
                                  RegExp(r'^[a-z]+$').hasMatch(
                                      (data.displayName ?? '')[0]
                                          .toLowerCase()))
                              ? data.displayName!
                              : 'UG',
                        ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.displayName ?? '',
                      style: CustomTextStyles.blackW60013,
                    ),
                    Text(
                      '${data.members?.length} Members',
                      style: CustomTextStyles.blackW40011,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {},
                  child: Image.asset(
                    AllImages().sendGroup,
                    width: 20,
                    height: 20,
                    fit: BoxFit.cover,
                    package: 'at_contacts_group_flutter',
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {},
                  child: Image.asset(
                    AllImages().more,
                    width: 20,
                    height: 24,
                    fit: BoxFit.fitWidth,
                    package: 'at_contacts_group_flutter',
                  ),
                ),
                const SizedBox(width: 32),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildAlphabeticalTitle(String char) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
        left: 52,
        right: 52,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          char.isNotEmpty && RegExp(r'^[a-z]+$').hasMatch(char.toLowerCase())
              ? Text(
                  char.toUpperCase(),
                  style: CustomTextStyles.alphabeticalTextBold20,
                )
              : Text(
                  'Others',
                  style: CustomTextStyles.alphabeticalTextBold20,
                ),
          Divider(
            height: 1.toHeight,
            color: AllColors().dividerColor,
          )
        ],
      ),
    );
  }

  List<AtGroup> sortGroupAlphabetical() {
    final List<AtGroup> emptyTitleGroup = _filteredList
        .where((e) =>
            (e.displayName ?? '').isEmpty ||
            !RegExp(r'^[a-z]+$').hasMatch(
              (e.displayName ?? '')[0].toLowerCase(),
            ))
        .toList();
    final List<AtGroup> nonEmptyTitleGroup = _filteredList
        .where((e) =>
            (e.displayName ?? '').isNotEmpty &&
            RegExp(r'^[a-z]+$').hasMatch(
              (e.displayName ?? '')[0].toLowerCase(),
            ))
        .toList();
    nonEmptyTitleGroup.sort(
      (a, b) => (a.displayName?[0] ?? '').compareTo(
        (b.displayName?[0] ?? ''),
      ),
    );
    return [...nonEmptyTitleGroup, ...emptyTitleGroup];
  }

  Widget buildAddGroupButton() {
    return InkWell(
      onTap: () {
        widget.onCallback(true);
        Navigator.of(NavService.groupPckgRightHalfNavKey.currentContext!)
            .pushNamed(DesktopRoutes.DESKTOP_GROUP_CONTACT_VIEW, arguments: {
          'onBackArrowTap': (selectedGroupContacts) {
            Navigator.of(NavService.groupPckgRightHalfNavKey.currentContext!)
                .pop();
            widget.onCallback(false);
          },
          'onDoneTap': () {
            Navigator.of(NavService.groupPckgRightHalfNavKey.currentContext!)
                .pushNamed(DesktopRoutes.DESKTOP_NEW_GROUP, arguments: {
              'onPop': () {
                Navigator.of(
                        NavService.groupPckgRightHalfNavKey.currentContext!)
                    .pop();
                widget.onCallback(false);
              },
              'onDone': () {},
            });
          },
          'contactSelectedHistory':
              <GroupContactsModel>[] // will always be empty
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(46),
          color: AllColors().buttonColor,
        ),
        child: Text(
          'Add groups',
          style: CustomTextStyles.whiteW50015,
        ),
      ),
    );
  }
}
