import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_location_flutter/common_components/bottom_sheet.dart';
import 'package:at_location_flutter/common_components/display_tile.dart';
import 'package:at_location_flutter/common_components/floating_icon.dart';
import 'package:at_location_flutter/common_components/tasks.dart';
import 'package:at_location_flutter/location_modal/key_location_model.dart';
import 'package:at_location_flutter/map_content/flutter_map/flutter_map.dart';
import 'package:at_location_flutter/screens/request_location/request_location_sheet.dart';
import 'package:at_location_flutter/screens/share_location/share_location_sheet.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:at_location_flutter/service/home_screen_service.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:at_location_flutter/service/send_location_notification.dart';
import 'package:at_location_flutter/show_location.dart';
import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:at_location_flutter/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeScreen extends StatefulWidget {
  final bool showList;
  HomeScreen({this.showList = true});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PanelController pc = PanelController();
  LatLng? myLatLng;

  @override
  void initState() {
    super.initState();
    _getMyLocation();
    KeyStreamService().init(AtLocationNotificationListener().atClientInstance);
  }

  Future<void> _getMyLocation() async {
    LatLng? newMyLatLng = await getMyLocation();
    if (newMyLatLng != null) {
      if (mounted) {
        setState(() {
          myLatLng = newMyLatLng;
        });
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (((permission == LocationPermission.always) || (permission == LocationPermission.whileInUse))) {
      Geolocator.getPositionStream(distanceFilter: 2).listen((Position locationStream) async {
        setState(() {
          myLatLng = LatLng(locationStream.latitude, locationStream.longitude);
        });
      });
    }
  }

  MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
          body: Stack(
        children: <Widget>[
          (myLatLng != null)
              ? showLocation(UniqueKey(), mapController, location: myLatLng)
              : showLocation(
                  UniqueKey(),
                  mapController,
                ),
          Positioned(
            top: 30,
            right: 0,
            child: FloatingIcon(
              icon: Icons.location_off,
              isTopLeft: false,
              onPressed: () => SendLocationNotification().deleteAllLocationKey(),
            ),
          ),
          widget.showList ? Positioned(bottom: 264.toHeight, child: header()) : const SizedBox(),
          widget.showList
              ? StreamBuilder<List<KeyLocationModel>>(
                  stream: KeyStreamService().atNotificationsStream,
                  builder: (BuildContext context, AsyncSnapshot<List<KeyLocationModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasError) {
                        return SlidingUpPanel(
                            controller: pc,
                            minHeight: 267.toHeight,
                            maxHeight: 530.toHeight,
                            panelBuilder: (ScrollController scrollController) =>
                                collapsedContent(false, scrollController, emptyWidget('Something went wrong!!')));
                      } else {
                        return SlidingUpPanel(
                          controller: pc,
                          minHeight: 267.toHeight,
                          maxHeight: 530.toHeight,
                          panelBuilder: (ScrollController scrollController) {
                            if (snapshot.data!.isNotEmpty) {
                              return collapsedContent(
                                  false, scrollController, getListView(snapshot.data!, scrollController));
                            } else {
                              return collapsedContent(false, scrollController, emptyWidget('No Data Found!!'));
                            }
                          },
                        );
                      }
                    } else {
                      return SlidingUpPanel(
                        controller: pc,
                        minHeight: 267.toHeight,
                        maxHeight: 530.toHeight,
                        panelBuilder: (ScrollController scrollController) {
                          return collapsedContent(false, scrollController, emptyWidget('No Data Found!!'));
                        },
                      );
                    }
                  })
              : const SizedBox(),
        ],
      )),
    );
  }

  Widget collapsedContent(bool isExpanded, ScrollController slidingScrollController, dynamic T) {
    return Container(
        height: !isExpanded ? 260.toHeight : 530.toHeight,
        padding: EdgeInsets.fromLTRB(15.toWidth, 7.toHeight, 0, 0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AllColors().DARK_GREY,
              blurRadius: 10.0,
              spreadRadius: 1.0,
              offset: const Offset(0.0, 0.0),
            )
          ],
        ),
        child: T);
  }

  Widget getListView(List<KeyLocationModel> allNotifications, ScrollController slidingScrollController) {
    return ListView(
      children: allNotifications.map((KeyLocationModel notification) {
        return Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                HomeScreenService()
                    .onLocationModelTap(notification.locationNotificationModel!, notification.haveResponded!);
              },
              child: DisplayTile(
                atsignCreator: notification.locationNotificationModel!.atsignCreator ==
                        AtLocationNotificationListener().currentAtSign
                    ? notification.locationNotificationModel!.receiver
                    : notification.locationNotificationModel!.atsignCreator,
                title: getTitle(notification.locationNotificationModel!),
                subTitle: getSubTitle(notification.locationNotificationModel!),
                semiTitle: getSemiTitle(notification.locationNotificationModel!, notification.haveResponded!),
                showRetry: calculateShowRetry(notification),
                onRetryTapped: () {
                  HomeScreenService().onLocationModelTap(notification.locationNotificationModel!, false);
                },
              ),
            ),
            const Divider()
          ],
        );
      }).toList(),
    );
  }

  Widget header() {
    return Container(
      height: 77.toHeight,
      width: 356.toWidth,
      margin: EdgeInsets.symmetric(horizontal: 10.toWidth, vertical: 10.toHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AllColors().DARK_GREY,
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: const Offset(0.0, 0.0),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: Tasks(
                task: 'Request Location',
                icon: Icons.sync,
                angle: (-3.14 / 2),
                onTap: () async {
                  await bottomSheet(context, RequestLocationSheet(), SizeConfig().screenHeight * 0.5);
                }),
          ),
          Expanded(
            child: Tasks(
                task: 'Share Location',
                icon: Icons.person_add,
                onTap: () {
                  bottomSheet(context, ShareLocationSheet(), SizeConfig().screenHeight * 0.6);
                }),
          )
        ],
      ),
    );
  }

  Widget emptyWidget(String title) {
    return Column(
      children: <Widget>[
        Image.asset(
          'packages/at_location_flutter/assets/images/empty_group.png',
          width: 181.toWidth,
          height: 181.toWidth,
          fit: BoxFit.cover,
        ),
        SizedBox(
          height: 15.toHeight,
        ),
        Text(title, style: CustomTextStyles().grey16),
        SizedBox(
          height: 5.toHeight,
        ),
      ],
    );
  }
}
