/// This is a custom button
/// @param [onPressed] defines what to execute on press of this button
/// @param [buttonText] is a [String] to display on this button
/// @param [height] in [double] sets the height of the button
/// @param [width] in [double] sets the width of the button
/// @param [buttonColor] sets the fill color of the button
/// @param [fontColor] sets the font color for [buttonText] text

import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_common_flutter/utils/colors.dart';
import 'package:at_common_flutter/utils/text_styles.dart';

class CustomButton extends StatelessWidget {
  final Function() onPressed;
  final String buttonText;
  final double height;
  final double width;
  final Color buttonColor;
  final Color fontColor;

  const CustomButton({
    Key key,
    this.onPressed,
    this.buttonText = '',
    this.height,
    this.width,
    this.buttonColor = Colors.black,
    this.fontColor = ColorConstants.fontPrimary,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? 158.toWidth,
        height: height ?? (50.toHeight),
        padding: EdgeInsets.symmetric(horizontal: 10.toWidth),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.toWidth),
            color: buttonColor),
        child: Center(
          child: Text(
            buttonText,
            textAlign: TextAlign.center,
            style: CustomTextStyles.primaryBold16(fontColor),
          ),
        ),
      ),
    );
  }
}
