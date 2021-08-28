import 'package:at_common_flutter/utils/colors.dart';
import 'package:at_common_flutter/utils/text_strings.dart';
import 'package:at_common_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

/// This is a custom app bar.
///
/// used to reduce the common widgets that are passed to the material appbar.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// A string to display the title of the appbar.
  final String? titleText;

  /// This toggles the display of the center aligned title.
  final bool showTitle;

  /// This automatically implies leading functionality, with [Icons.arrow_back]
  /// if set to `false` it displays a `CLOSE` String instead of [Icons.arrow_back].
  final bool showBackButton;

  /// This toggles the visibility of `CLOSE` and [Icons.arrow_back] and displays the [leadingIcon] widget instead.
  final bool showLeadingIcon;

  /// This toggles the visibility of trailing icon,
  /// if set to `false` nothing is displayed.
  final bool showTrailingIcon;

  /// This displays `CLOSE` instead of trailing icon.
  final bool closeOnRight;

  /// takes in a trailing widget.
  final Widget? trailingIcon;

  /// takes in a leading widget.
  final Widget? leadingIcon;

  /// defines the function to execute on press of [trailingIcon].
  final Function? onTrailingIconPressed;

  /// sets the appBar elevation.
  final double elevation;

  /// sets the appBar color.
  final Color? appBarColor;

  /// sets the textStyle for `CLOSE` text.
  final TextStyle? backTextStyle;

  /// sets the textStyle for the [titleText].
  final TextStyle? titleTextStyle;

  /// defines the function to execute on press of [leadingIcon].
  final Function? onLeadingIconPressed;

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
      elevation: elevation,
      centerTitle: true,
      leadingWidth: 90,
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
                      onLeadingIconPressed!();
                    }
                  })
              : leadingIcon
          : Container(),
      title: Row(
        children: <Widget>[
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
                      titleText!,
                      style: titleTextStyle ?? CustomTextStyles.primaryBold18,
                    ),
                  )
                : Container(),
          ),
        ],
      ),
      actions: <Widget>[
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
                            onTrailingIconPressed!();
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
