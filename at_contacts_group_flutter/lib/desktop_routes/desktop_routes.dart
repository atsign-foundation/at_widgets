import 'package:at_contacts_flutter/desktop_screens/desktop_contacts_screen.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';
import 'package:at_contacts_group_flutter/desktop_screens/desktop_empty_group.dart';
import 'package:at_contacts_group_flutter/desktop_screens/desktop_group_detail.dart';
import 'package:at_contacts_group_flutter/desktop_screens/desktop_group_list.dart';
import 'package:at_contacts_group_flutter/desktop_screens/desktop_group_view.dart';
import 'package:at_contacts_group_flutter/desktop_screens/desktop_new_group.dart';
import 'package:at_contacts_group_flutter/screens/group_contact_view/group_contact_view.dart';
import 'package:at_contacts_group_flutter/services/group_service.dart';
import 'package:flutter/material.dart';

import 'desktop_route_names.dart';

class DesktopSetupRoutes {
  // static Map<String, WidgetBuilder> routeBuilders(
  //     BuildContext context, RouteSettings routeSettings) {
  //   return {
  //     DesktopRoutes.DESKTOP_HOME_NESTED_INITIAL: (context) =>
  //         WelcomeScreenHome(),
  //     DesktopRoutes.DESKTOP_HISTORY: (context) => DesktopHistoryScreen(),
  //     DesktopRoutes.DEKSTOP_MYFILES: (context) => DesktopMyFiles(),
  //     DesktopRoutes.DEKSTOP_CONTACTS_SCREEN: (context) {
  //       return DesktopContactsScreen(
  //         UniqueKey(),
  //         () {
  //           DesktopSetupRoutes.nested_pop();
  //         },
  //       );
  //     },
  //     DesktopRoutes.DEKSTOP_BLOCKED_CONTACTS_SCREEN: (context) {
  //       Map<String, dynamic> args =
  //           routeSettings.arguments as Map<String, dynamic>;
  //       return DesktopContactsScreen(
  //         UniqueKey(),
  //         () {
  //           DesktopSetupRoutes.nested_pop();
  //         },
  //         isBlockedScreen: args['isBlockedScreen'],
  //       );
  //     },
  //     DesktopRoutes.DESKTOP_TRUSTED_SENDER: (context) => DesktopTrustedSender(),
  //     DesktopRoutes.DESKTOP_EMPTY_TRUSTED_SENDER: (context) =>
  //         DesktopEmptySender(),
  //     DesktopRoutes.DESKTOP_GROUP: (context) {
  //       Map<String, dynamic> args =
  //           ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
  //       return GroupList();
  //     },
  //     // =>  DesktopEmptyGroup(),
  //     DesktopRoutes.DESKTOP_GROUP_VIEW: (context) => DesktopGroupView(),
  //     DesktopRoutes.DESKT_FAQ: (context) => WebsiteScreen(
  //           title: 'FAQ',
  //           url: '${MixedConstants.WEBSITE_URL}/faqs',
  //         )
  //   };
  // }

  static Map<String, WidgetBuilder> groupLeftRouteBuilders(
      BuildContext context, RouteSettings routeSettings, var _data) {
    return {
      DesktopRoutes.DESKTOP_GROUP_LEFT_INITIAL: (context) {
        if (_data.length == 0) {
          return DesktopEmptyGroup(false, () {});
        } else {
          return DesktopGroupList(() {}, _data);
        }
      },
      DesktopRoutes.DESKTOP_GROUP_LIST: (context) {
        var args = routeSettings.arguments as Map<String, dynamic>;
        return DesktopGroupList(args['onAdd'], _data);
      },
    };
  }

  static Map<String, WidgetBuilder> groupRightRouteBuilders(
    BuildContext context,
    RouteSettings routeSettings,
    var _data, {
    required Function initialRouteOnArrowBackTap,
    required Function initialRouteOnDoneTap,
  }) {
    return {
      DesktopRoutes.DESKTOP_GROUP_RIGHT_INITIAL: (context) {
        if (_data.length == 0) {
          return GroupContactView(
              asSelectionScreen: true,
              singleSelection: false,
              showGroups: false,
              showContacts: true,
              isDesktop: true,
              selectedList: (selectedContactList) {
                // setState(() {
                //   _selectedList = _list;
                // });
                GroupService().setSelectedContacts(
                    selectedContactList.map((e) => e?.contact).toList());
              },
              onBackArrowTap: () {
                initialRouteOnArrowBackTap();
              },
              onDoneTap: () {
                // setState(() {
                //   _currentScreen = CurrentScreen.SelectedItems;
                // });
                initialRouteOnDoneTap();
              });
        } else {
          return DesktopGroupDetail(_data[0]);
        }
      },
      DesktopRoutes.DESKTOP_NEW_GROUP: (context) {
        var args = routeSettings.arguments as Map<String, dynamic>;
        return DesktopNewGroup(
          onPop: args['onPop'],
          onDone: args['onDone'],
        );
      },
      DesktopRoutes.DESKTOP_GROUP_DETAIL: (context) {
        var args = routeSettings.arguments as Map<String, dynamic>;
        return DesktopGroupDetail(args['group']);
      },
      DesktopRoutes.DESKTOP_GROUP_CONTACT_VIEW: (context) {
        var args = routeSettings.arguments as Map<String, dynamic>;
        return GroupContactView(
            asSelectionScreen: true,
            singleSelection: false,
            showGroups: false,
            showContacts: true,
            isDesktop: true,
            selectedList: (selectedContactList) {
              GroupService().setSelectedContacts(
                  selectedContactList.map((e) => e?.contact).toList());
            },
            onBackArrowTap: () {
              args['initialRouteOnArrowBackTap'];
            },
            onDoneTap: () {
              args['initialRouteOnDoneTap'];
            });
      }
    };
  }
}
