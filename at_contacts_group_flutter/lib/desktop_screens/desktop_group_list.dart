import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_route_names.dart';
import 'package:at_contacts_group_flutter/services/navigation_service.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_custom_input_field.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_header.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_person_horizontal_tile.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class DesktopGroupList extends StatefulWidget {
  final Function onAdd;
  final List<AtGroup> groups;
  DesktopGroupList(this.onAdd, this.groups);
  @override
  _DesktopGroupListState createState() => _DesktopGroupListState();
}

class _DesktopGroupListState extends State<DesktopGroupList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF7F7FF),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          DesktopHeader(
            title: 'Groups',
            isTitleCentered: true,
            actions: [
              DesktopCustomInputField(
                backgroundColor: Colors.white,
                hintText: 'Search...',
                icon: Icons.search,
                height: 45,
                iconColor: ColorConstants.greyText,
              ),
              SizedBox(width: 15),
              TextButton(
                onPressed: () {
                  // widget.onAdd();
                  // Navigator.of(
                  //         NavService.groupPckgRightHalfNavKey.currentContext!)
                  //     .pushNamed(DesktopRoutes.DESKTOP_GROUP_CONTACT_VIEW);
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return ColorConstants.orangeColor;
                  },
                ), fixedSize: MaterialStateProperty.resolveWith<Size>(
                  (Set<MaterialState> states) {
                    return Size(100, 40);
                  },
                )),
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 10)
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: widget.groups.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        right: 15,
                        left: 20,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 15.0, bottom: 15, left: 15, right: 15),
                        child: DesktopCustomPersonHorizontalTile(
                          title: widget.groups[0].groupName,
                          subTitle: widget.groups[0].members.length.toString(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: Transform.rotate(
                              angle: 180 * math.pi / 340,
                              child: Icon(Icons.keyboard_arrow_up),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
