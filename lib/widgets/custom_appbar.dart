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
              child: Container(
                // color: Colors.black,
                height: 20.toHeight,
                width: 30.toWidth,
                margin: EdgeInsets.only(right: 16.0.toWidth),
                child: ColorFiltered(
                  colorFilter:
                      ColorFilter.mode(ColorConstants.light, BlendMode.color),
                  child: Image.asset(
                    Images.qrscan,
                    // fit: BoxFit.fill,
                    // height: 5.0.toHeight,
                    package: Strings.package,
                  ),
                ),
              ))
      ],
      title: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
              child:
                  // Icon(Icons.arrow_back, color: ColorConstants.primary),
                  Text(Strings.BackButton,
                      style: CustomTextStyles.fontR14primary),
              onTap: () {
                Navigator.pop(context);
              }),
          SizedBox(width: SizeConfig().screenWidth * 0.25),
          if (showTitle)
            Flexible(
                // flex: 4,
                child: Text(
              this.title ?? Strings.Title,
              style: CustomTextStyles.fontBold18primary,
              textAlign: TextAlign.center,
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
