/// This is a custom app bar
/// @param [showTitle] toggles to display the center aligned title
/// @param [showBackButton] toggles the automatically implies leading functionality, with [Icons.arrow_back]
/// if set to [false] it displays a [Close] String instead of [Icons.arrow_back],
/// @param [showLeadingIcon] toggles the visibility of [Close] and [Icons.arrow_back] and displays the [leadingIcon] widget instead
/// @param [titleText] is a [String] to display the title of the appbar
/// @param [showTrailingIcon] toggles the visibility of trailing icon,
/// if set to [false] nothing is displayed
/// @param [trailingIcon] takes in the trailing widget
/// @param [leadingIcon] takes in the leading widget
/// @param [onTrailingIconPressed] defines what to execute on press of [trailingIcon]
/// @param [elevation] sets the appBar elevation
/// @param [backTextStyle] sets the textStyle for [Close] text
/// @param [titleTextStyle] sets the textStyle for the [titleText]
/// @param [appBarColor] sets the appBar color
/// @param [onLeadingIconPressed] defines what to execute on press of [leadingIcon]

import 'package:at_common_flutter/utils/colors.dart';
import 'package:at_common_flutter/utils/text_strings.dart';
import 'package:at_common_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final bool showTitle;
  final bool showBackButton;
  final bool showLeadingIcon;
  final bool showTrailingIcon;
  final bool closeOnRight;
  final Widget trailingIcon;
  final Widget leadingIcon;
  final Function onTrailingIconPressed;
  final double elevation;
  final Color appBarColor;
  final TextStyle backTextStyle;
  final TextStyle titleTextStyle;
  final Function onLeadingIconPressed;

  const CustomAppBar({
    this.titleText,
    this.showTitle = false,
    this.showBackButton = false,
    this.showLeadingIcon = false,
    this.showTrailingIcon = false,
    this.trailingIcon,
    this.elevation = 0,
    this.onTrailingIconPressed,
    this.leadingIcon,
    this.appBarColor,
    this.backTextStyle,
    this.titleTextStyle,
    this.onLeadingIconPressed,
    this.closeOnRight = false,
  });
  @override
  Size get preferredSize => Size.fromHeight(70.toHeight);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AppBar(
      elevation: elevation ?? 0,
      centerTitle: true,
      leading: (showLeadingIcon)
          ? (showBackButton)
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: ColorConstants.fontPrimary,
                    size: 15.toFont,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (onLeadingIconPressed != null) {
                      onLeadingIconPressed();
                    }
                  })
              : leadingIcon
          : Container(),
      title: Row(
        children: [
          // Container(
          //   height: 40.toHeight,
          //   margin: EdgeInsets.only(top: 5.toHeight),
          //   child: (!showBackButton && !showLeadingIcon)
          //       ? Center(
          //           child: GestureDetector(
          //             child: Icon(Icons.close),
          //             onTap: () {
          //               Navigator.pop(context);
          //             },
          //           ),
          //         )
          //       : Container(),
          // ),
          Expanded(
            child: (showTitle)
                ? Center(
                    child: Text(
                      titleText,
                      style: titleTextStyle ?? CustomTextStyles.primaryBold18,
                    ),
                  )
                : Container(),
          ),
        ],
      ),
      actions: [
        (closeOnRight)
            ? Center(
                child: Container(
                  padding: EdgeInsets.only(right: 20.toHeight),
                  child: GestureDetector(
                    child: Text(
                      TextStrings().buttonClose,
                      style: backTextStyle ??
                          TextStyle(
                              color: Colors.black,
                              fontFamily: 'HelveticaNeu',
                              fontSize: 22.toFont),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              )
            : Container(
                height: 22.toHeight,
                width: 62.toWidth,
                // margin: EdgeInsets.only(right: 20),
                child: (showTrailingIcon)
                    ? GestureDetector(
                        child: trailingIcon,
                        onTap: () {
                          if (onTrailingIconPressed != null) {
                            onTrailingIconPressed();
                          }
                        },
                      )
                    : Container())
      ],
      automaticallyImplyLeading: false,
      backgroundColor: appBarColor ?? ColorConstants.appBarColor,
    );
  }
}
