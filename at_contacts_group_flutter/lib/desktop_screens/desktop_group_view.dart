import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:flutter/material.dart';

import 'desktop_group_detail.dart';

class DesktopGroupView extends StatefulWidget {
  @override
  _DesktopGroupViewState createState() => _DesktopGroupViewState();
}

class _DesktopGroupViewState extends State<DesktopGroupView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig().screenWidth,
      child: Row(
        children: [
          // Container(
          //   width: SizeConfig().screenWidth / 2 - 35,
          //   child: DesktopGroupList(),
          // ),
          Container(
              width: SizeConfig().screenWidth / 2 - 35, child: Text('Commented')
              // DesktopGroupDetail(),
              )
        ],
      ),
    );
  }
}
