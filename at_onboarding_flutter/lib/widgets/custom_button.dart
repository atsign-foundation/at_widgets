import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:at_onboarding_flutter/utils/custom_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';

/// Custom button widget [isInverted] toggles between black and white button,
/// [isInverted=false] by default, if true bg color and border color goes [white]
/// from [black], text color goes [black] from [white].
class CustomButton extends StatelessWidget {
  final bool isInverted;

  final Function()? onPressed;
  final String? buttonText;
  final double? width;
  final double? height;
  CustomButton(
      {Key? key,
      this.isInverted = false,
      this.buttonText,
      this.height,
      this.width,
      this.onPressed})
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
            color: (isInverted) ? Colors.white : ColorConstants.appColor),
        child: Center(
          child: Text(
            buttonText!,
            textAlign: TextAlign.center,
            style: (isInverted)
                ? CustomTextStyles.fontBold16primary
                : CustomTextStyles.fontBold16light,
          ),
        ),
      ),
    );
  }
}
