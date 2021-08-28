import 'package:at_follows_flutter/screens/notifications.dart';
import 'package:at_follows_flutter/screens/qrscan.dart';
import 'package:at_follows_flutter/utils/color_constants.dart';
import 'package:at_follows_flutter/utils/custom_textstyles.dart';
import 'package:at_follows_flutter/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:at_follows_flutter/services/size_config.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final bool showTitle;
  final bool showQr;
  final bool showNotifications;
  final String? title;
  final bool showBackButton;

  CustomAppBar(
      {this.showTitle = false,
      this.showQr = false,
      this.showNotifications = false,
      this.showBackButton = false,
      this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      brightness: ColorConstants.brightness,
      elevation: 0,
      backgroundColor: ColorConstants.backgroundColor,
      leading: null,
      automaticallyImplyLeading: false,
      actions: <Widget>[
        if (showNotifications)
          GestureDetector(
              onTap: () {
                print('inside notifications');
                Navigator.push(context, MaterialPageRoute<Notifications>(builder: (BuildContext context) {
                  return Notifications();
                }));
              },
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding:
                        EdgeInsets.only(top: 10.0.toFont, right: 10.0.toFont),
                    child: Icon(Icons.notifications,
                        color: ColorConstants.primary, size: 28.toFont),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6)),
                        constraints: const BoxConstraints(
                          minHeight: 14,
                          minWidth: 14,
                        ),
                        child: const Text('1', textAlign: TextAlign.center)),
                  )
                ],
              )),
        // SizedBox(width: 10.toFont),
        if (showQr)
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute<QrScan>(builder: (BuildContext context) => QrScan()));
            },
            child: Padding(
              padding: EdgeInsets.only(right: 12.0.toFont),
              child: Icon(Icons.person_add,
                  color: ColorConstants.dark, size: 25.toFont),
            ),
          ),
        if (!showQr)
          Padding(
              padding: EdgeInsets.only(right: 12.0.toFont),
              child: SizedBox(width: 25.toFont))
      ],
      title: Row(
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose,
            flex: 2,
            child: GestureDetector(
                child: Text(Strings.backButton,
                    style: CustomTextStyles.fontR14dark),
                onTap: () {
                  Navigator.pop(context);
                }),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.10),
          if (showTitle)
            Flexible(
                // fit: FlexFit.tight,
                flex: 7,
                child: Center(
                  child: Text(
                    title ?? Strings.title,
                    maxLines: 3,
                    style: CustomTextStyles.fontBold18primary,
                    textAlign: TextAlign.center,
                  ),
                ))
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70.toHeight);
}

class ConnectionsPopUpMenu {
  String notifications = 'Notifications';
  String scanqr = ' Scan QR';
}
