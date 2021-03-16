import 'package:at_follows_flutter/screens/notifications.dart';
import 'package:at_follows_flutter/screens/qrscan.dart';
import 'package:at_follows_flutter/utils/color_constants.dart';
import 'package:at_follows_flutter/utils/custom_textstyles.dart';
import 'package:at_follows_flutter/utils/images.dart';
import 'package:at_follows_flutter/utils/strings.dart';
import 'package:flutter/material.dart';
import 'package:at_follows_flutter/services/size_config.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final bool showTitle;
  final bool showQr;
  final bool showNotifications;
  final String title;
  final showBackButton;

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
      actions: [
        // PopupMenuButton(itemBuilder: (builder){
        //   return PopupMenuItems(child: null)
        // })
        if (this.showNotifications)
          GestureDetector(
              onTap: () {
                print('inside notifications');
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Notifications();
                }));
              },
              child: Stack(
                children: [
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
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6)),
                        constraints: BoxConstraints(
                          minHeight: 14,
                          minWidth: 14,
                        ),
                        child: Text('1', textAlign: TextAlign.center)),
                  )
                ],
              )),
        // SizedBox(width: 10.toFont),
        if (this.showQr)
          GestureDetector(
            onTap: () {
              print('Asked for scanning QRcode');
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => QrScan()));
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
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            fit: FlexFit.loose,
            flex: 2,
            child: GestureDetector(
                child:
                    // Icon(Icons.arrow_back, color: ColorConstants.primary),
                    Text(Strings.BackButton,
                        style: CustomTextStyles.fontR14primary),
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
                    this.title ?? Strings.Title,
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
