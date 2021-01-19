/// Custom button widget [isInverted] toggles between black and white button,
/// [isInverted=false] by default, if true bg color and border color goes [white]
/// from [black], text color goes [black] from [white].

import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_common_flutter/utils/colors.dart';
import 'package:at_common_flutter/utils/text_styles.dart';

class CustomButton extends StatelessWidget {
  final bool isInverted;
  final Function() onPressed;
  final String buttonText;
  final double height;
  final double width;
  final Color buttonColor;

  const CustomButton(
      {Key key,
      this.isInverted = false,
      this.onPressed,
      this.buttonText = '',
      this.height,
      this.width,
      this.buttonColor = ColorConstants.orange})
      : super(key: key);
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
            color: (isInverted) ? buttonColor : Colors.black),
        child: Center(
          child: Text(
            buttonText,
            textAlign: TextAlign.center,
            style: (isInverted)
                ? CustomTextStyles.primaryBold16
                : CustomTextStyles.whiteBold16,
          ),
        ),
      ),
    );
  }
}
