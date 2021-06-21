import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_group_flutter/desktop_screens/desktop_empty_group.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:at_contacts_group_flutter/services/navigation_service.dart';
import 'package:at_contacts_group_flutter/utils/text_constants.dart';
import 'package:at_contacts_group_flutter/widgets/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_route_names.dart';
import 'package:at_contacts_group_flutter/desktop_routes/desktop_routes.dart';

class DesktopGroupInitialScreen extends StatefulWidget {
  DesktopGroupInitialScreen({Key? key}) : super(key: key);

  @override
  State<DesktopGroupInitialScreen> createState() =>
      _DesktopGroupInitialScreenState();
}

class _DesktopGroupInitialScreenState extends State<DesktopGroupInitialScreen> {
  bool createBtnTapped = false;
  List<AtContact?> selectedContactList = [];
  bool showAddGroupIcon = false, errorOcurred = false;

  @override
  void initState() {
    try {
      super.initState();
      GroupService().getAllGroupsDetails();
      GroupService().atGroupStream.listen((groupList) {
        if (groupList.isNotEmpty) {
          showAddGroupIcon = true;
        } else {
          showAddGroupIcon = false;
        }
        if (mounted) setState(() {});
      });
    } catch (e) {
      print('Error in init of Group_list $e');
      if (mounted) {
        setState(() {
          errorOcurred = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      width: SizeConfig().screenWidth - TextConstants.SIDEBAR_WIDTH,
      color: Color(0xFFF7F7FF),
      child: StreamBuilder(
        stream: GroupService().atGroupStream,
        builder: (BuildContext context, AsyncSnapshot<List<AtGroup>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return ErrorScreen(onPressed: () {
                GroupService().getAllGroupsDetails();
              });
            } else {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  print('snapshot.data!.isEmpty');
                  showAddGroupIcon = false;
                  return createBtnTapped
                      ? nestednavigators(snapshot.data)
                      : DesktopEmptyGroup(createBtnTapped, () {
                          setState(() {
                            createBtnTapped = true;
                          });
                        });
                } else {
                  print('!snapshot.data!.isEmpty');
                  return nestednavigators(snapshot.data);
                }
              } else {
                return DesktopEmptyGroup(createBtnTapped, () {
                  setState(() {
                    createBtnTapped = true;
                  });
                });
              }
            }
          }
        },
      ),
    );
  }

  Widget nestednavigators(_data) {
    return SizedBox(
      width: SizeConfig().screenWidth - TextConstants.SIDEBAR_WIDTH,
      child: Row(
        children: [
          Expanded(
            child: Navigator(
              key: NavService.groupPckgLeftHalfNavKey,
              initialRoute: DesktopRoutes.DESKTOP_GROUP_LEFT_INITIAL,
              onGenerateRoute: (routeSettings) {
                var routeBuilders = DesktopSetupRoutes.groupLeftRouteBuilders(
                  context,
                  routeSettings,
                  _data,
                );
                return MaterialPageRoute(builder: (context) {
                  return routeBuilders[routeSettings.name]!(context);
                });
              },
            ),
          ),
          Expanded(
            child: Navigator(
              key: NavService.groupPckgRightHalfNavKey,
              initialRoute: DesktopRoutes.DESKTOP_GROUP_RIGHT_INITIAL,
              onGenerateRoute: (routeSettings) {
                var routeBuilders = DesktopSetupRoutes.groupRightRouteBuilders(
                  context,
                  routeSettings,
                  _data,
                  initialRouteOnArrowBackTap: () {
                    setState(() {
                      createBtnTapped = false;
                    });
                  },
                  initialRouteOnDoneTap: DesktopSetupRoutes.navigator(
                      DesktopRoutes.DESKTOP_NEW_GROUP),
                );
                return MaterialPageRoute(builder: (context) {
                  return routeBuilders[routeSettings.name]!(context);
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
