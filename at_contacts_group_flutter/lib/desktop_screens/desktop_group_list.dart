import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_route_names.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_routes.dart';
import 'package:at_contacts_group_flutter/services/navigation_service.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_custom_input_field.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_header.dart';
import 'package:at_contacts_group_flutter/widgets/desktop_person_horizontal_tile.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class DesktopGroupList extends StatefulWidget {
  final List<AtGroup> groups;
  final int expandIndex;
  Key? key;
  DesktopGroupList(this.groups, {this.key, this.expandIndex = 0})
      : super(key: key);
  @override
  _DesktopGroupListState createState() => _DesktopGroupListState();
}

class _DesktopGroupListState extends State<DesktopGroupList> {
  int _selectedIndex = 0;
  String searchText = '';
  var _filteredList = <AtGroup>[];

  @override
  void initState() {
    _selectedIndex = widget.expandIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (searchText != '') {
      _filteredList = widget.groups.where((grp) {
        return grp.groupName!.contains(searchText);
      }).toList();
    } else {
      _filteredList = widget.groups;
    }

    return Container(
      color: Color(0xFFF7F7FF),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          DesktopHeader(
            title: 'Groups',
            isTitleCentered: false,
            onBackTap: () {
              DesktopGroupSetupRoutes.exitGroupPackage();
            },
            actions: [
              Expanded(
                child: DesktopCustomInputField(
                  backgroundColor: Colors.white,
                  hintText: 'Search...',
                  icon: Icons.search,
                  height: 45,
                  iconColor: ColorConstants.greyText,
                  value: (str) {
                    setState(() {
                      searchText = str;
                    });
                  },
                  initialValue: searchText,
                ),
              ),
              SizedBox(width: 15),
              TextButton(
                onPressed: () {
                  Navigator.of(
                          NavService.groupPckgRightHalfNavKey.currentContext!)
                      .pushNamed(DesktopRoutes.DESKTOP_GROUP_CONTACT_VIEW,
                          arguments: {
                        'onBackArrowTap': () {
                          Navigator.of(NavService
                                  .groupPckgRightHalfNavKey.currentContext!)
                              .pop();
                        },
                        'onDoneTap': () {
                          Navigator.of(NavService
                                  .groupPckgRightHalfNavKey.currentContext!)
                              .pushNamed(DesktopRoutes.DESKTOP_NEW_GROUP,
                                  arguments: {
                                'onPop': () {
                                  Navigator.of(NavService
                                          .groupPckgRightHalfNavKey
                                          .currentContext!)
                                      .pop();
                                },
                                'onDone': () {},
                              });
                        },
                      });
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
              itemCount: _filteredList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                    DesktopGroupSetupRoutes.navigator(
                        DesktopRoutes.DESKTOP_GROUP_DETAIL,
                        arguments: {
                          'group': _filteredList[index],
                        })();
                  },
                  child: Container(
                    color: index == _selectedIndex
                        ? Color(0xffF86060).withAlpha(20)
                        : Colors.transparent,
                    child: Row(
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
                              title: _filteredList[index].groupName,
                              subTitle: _filteredList[index]
                                  .members!
                                  .length
                                  .toString(),
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
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

// class _DesktopGroupListState extends State<DesktopGroupList> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Color(0xFFF7F7FF),
//       child: StreamBuilder(
//         stream: GroupService().atGroupStream,
//         builder: (BuildContext context, AsyncSnapshot<List<AtGroup>> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else {
//             if (snapshot.hasError) {
//               return ErrorScreen(onPressed: () {
//                 GroupService().getAllGroupsDetails();
//               });
//             } else {
//               if (snapshot.hasData) {
//                 if (snapshot.data!.isEmpty) {
//                   return Text('Empty');
//                 } else {
//                   return Column(
//                     children: <Widget>[
//                       SizedBox(
//                         height: 10,
//                       ),
//                       DesktopHeader(
//                         title: 'Groups',
//                         isTitleCentered: true,
//                         actions: [
//                           DesktopCustomInputField(
//                             backgroundColor: Colors.white,
//                             hintText: 'Search...',
//                             icon: Icons.search,
//                             height: 45,
//                             iconColor: ColorConstants.greyText,
//                           ),
//                           SizedBox(width: 15),
//                           TextButton(
//                             onPressed: () {
//                               // widget.onAdd();
//                               Navigator.of(NavService
//                                       .groupPckgRightHalfNavKey.currentContext!)
//                                   .pushNamed(
//                                       DesktopRoutes.DESKTOP_GROUP_CONTACT_VIEW,
//                                       arguments: {
//                                     'onBackArrowTap': () {
//                                       Navigator.of(NavService
//                                               .groupPckgRightHalfNavKey
//                                               .currentContext!)
//                                           .pop();
//                                     },
//                                     'onDoneTap': () {
//                                       Navigator.of(NavService
//                                               .groupPckgRightHalfNavKey
//                                               .currentContext!)
//                                           .pushNamed(
//                                               DesktopRoutes.DESKTOP_NEW_GROUP,
//                                               arguments: {
//                                             'onPop': () {
//                                               Navigator.of(NavService
//                                                       .groupPckgRightHalfNavKey
//                                                       .currentContext!)
//                                                   .pop();
//                                             },
//                                           });
//                                     },
//                                   });
//                             },
//                             style: ButtonStyle(backgroundColor:
//                                 MaterialStateProperty.resolveWith<Color>(
//                               (Set<MaterialState> states) {
//                                 return ColorConstants.orangeColor;
//                               },
//                             ), fixedSize:
//                                 MaterialStateProperty.resolveWith<Size>(
//                               (Set<MaterialState> states) {
//                                 return Size(100, 40);
//                               },
//                             )),
//                             child: Text(
//                               'Add',
//                               style: TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 10)
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                       Expanded(
//                         child: ListView.builder(
//                           itemCount: snapshot.data!.length,
//                           itemBuilder: (context, index) {
//                             return Row(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(
//                                     top: 8.0,
//                                     right: 15,
//                                     left: 20,
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(
//                                         top: 15.0,
//                                         bottom: 15,
//                                         left: 15,
//                                         right: 15),
//                                     child: DesktopCustomPersonHorizontalTile(
//                                       title: snapshot.data![0].groupName,
//                                       subTitle: snapshot.data![0].members.length
//                                           .toString(),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       Padding(
//                                         padding:
//                                             const EdgeInsets.only(right: 15.0),
//                                         child: Transform.rotate(
//                                           angle: 180 * math.pi / 340,
//                                           child: Icon(Icons.keyboard_arrow_up),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             );
//                           },
//                         ),
//                       )
//                     ],
//                   );
//                 }
//               } else {
//                 return Text('Empty');
//               }
//             }
//           }
//         },
//       ),
//     );
//   }
// }

