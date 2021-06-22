import 'package:at_common_flutter/at_common_flutter.dart';
// ignore: import_of_legacy_library_into_null_safe
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
  bool shouldUpdate = false;
  List<AtGroup>? previousData;

  @override
  void initState() {
    try {
      super.initState();
      GroupService().getAllGroupsDetails();
    } catch (e) {
      print('Error in init of Group_list $e');
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
                if ((previousData == null) ||
                    (previousData?.length != snapshot.data?.length)) {
                  shouldUpdate = true;
                } else {
                  shouldUpdate = false;
                }

                previousData = snapshot.data;

                if (snapshot.data!.isEmpty) {
                  return createBtnTapped
                      ? NestedNavigators(
                          snapshot.data!,
                          () {
                            setState(() {
                              createBtnTapped = false;
                            });
                          },
                          shouldUpdate: shouldUpdate,
                          key: UniqueKey(),
                        )
                      : DesktopEmptyGroup(createBtnTapped, () {
                          setState(() {
                            createBtnTapped = true;
                          });
                        });
                } else {
                  return NestedNavigators(
                    snapshot.data!,
                    () {
                      setState(() {
                        createBtnTapped = false;
                      });
                    },
                    shouldUpdate: shouldUpdate,
                    key: UniqueKey(),
                  );
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
}

class NestedNavigators extends StatefulWidget {
  final List<AtGroup> data;
  final Function initialRouteOnArrowBackTap;
  final bool shouldUpdate;
  NestedNavigators(this.data, this.initialRouteOnArrowBackTap,
      {Key? key, this.shouldUpdate = false})
      : super(key: key);

  @override
  _NestedNavigatorsState createState() => _NestedNavigatorsState();
}

class _NestedNavigatorsState extends State<NestedNavigators> {
  @override
  void initState() {
    print('widget.shouldUpdate ${widget.shouldUpdate}');
    if (widget.shouldUpdate) {
      NavService.resetKeys();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig().screenWidth - TextConstants.SIDEBAR_WIDTH,
      child: Row(
        children: [
          Expanded(
            key: UniqueKey(),
            child: Navigator(
              key: NavService.groupPckgLeftHalfNavKey,
              initialRoute: DesktopRoutes.DESKTOP_GROUP_LEFT_INITIAL,
              onGenerateRoute: (routeSettings) {
                var routeBuilders = DesktopSetupRoutes.groupLeftRouteBuilders(
                  context,
                  routeSettings,
                  widget.data,
                );
                return MaterialPageRoute(builder: (context) {
                  return routeBuilders[routeSettings.name]!(context);
                });
              },
            ),
          ),
          Expanded(
            key: UniqueKey(),
            child: Navigator(
              key: NavService.groupPckgRightHalfNavKey,
              initialRoute: DesktopRoutes.DESKTOP_GROUP_RIGHT_INITIAL,
              onGenerateRoute: (routeSettings) {
                var routeBuilders = DesktopSetupRoutes.groupRightRouteBuilders(
                  context,
                  routeSettings,
                  widget.data,
                  initialRouteOnArrowBackTap: widget.initialRouteOnArrowBackTap,
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
