import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_location_flutter/common_components/bottom_sheet.dart';
import 'package:at_location_flutter/common_components/tasks.dart';
import 'package:at_location_flutter/screens/request_location/request_location_sheet.dart';
import 'package:at_location_flutter/screens/share_location/share_location_sheet.dart';
import 'package:at_location_flutter/service/my_location.dart';
import 'package:at_location_flutter/show_location.dart';
import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PanelController pc = PanelController();
  LatLng myLatLng;

  @override
  void initState() {
    super.initState();
    getMyLocation();
  }

  getMyLocation() async {
    LatLng newMyLatLng = await MyLocation().myLocation();
    if ((newMyLatLng != null) || (newMyLatLng != LatLng(0, 0)))
      setState(() {
        myLatLng = newMyLatLng;
      });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SafeArea(
      child: Scaffold(
          body: Stack(
        children: [
          (myLatLng != null)
              ? ShowLocation(UniqueKey(), location: myLatLng)
              : ShowLocation(
                  UniqueKey(),
                ),
          Positioned(bottom: 264.toHeight, child: header()),
          SlidingUpPanel(
            controller: pc,
            minHeight: 267.toHeight,
            maxHeight: 530.toHeight,
            panel: collapsedContent(false),
          )
        ],
      )),
    );
  }

  Widget collapsedContent(bool isExpanded) {}

  Widget header() {
    return Container(
      height: 77.toHeight,
      width: 356.toWidth,
      margin:
          EdgeInsets.symmetric(horizontal: 10.toWidth, vertical: 10.toHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AllColors().DARK_GREY,
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: Offset(0.0, 0.0),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Tasks(
              task: 'Request Location',
              icon: Icons.refresh,
              onTap: () async {
                bottomSheet(context, RequestLocationSheet(),
                    SizeConfig().screenHeight * 0.5);
              }),
          Tasks(
              task: 'Share Location',
              icon: Icons.person_add,
              onTap: () {
                bottomSheet(context, ShareLocationSheet(),
                    SizeConfig().screenHeight * 0.6);
              })
        ],
      ),
    );
  }
}
