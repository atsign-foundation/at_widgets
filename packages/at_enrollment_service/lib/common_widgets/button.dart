import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final Function()? onPressed;

  final String buttonText;

  final double? height;

  final double? width;

  final Color buttonColor;

  final TextStyle titleStyle;

  final double? borderRadius;

  final BoxBorder? border;

  final Widget? prefix;

  final Widget? suffix;

  const Button({
    super.key,
    this.onPressed,
    required this.buttonText,
    this.height,
    this.width,
    required this.buttonColor,
    required this.titleStyle,
    this.borderRadius,
    this.border,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      child: Container(
        width: width ?? 158.toWidth,
        height: height ?? (50.toHeight),
        padding: EdgeInsets.symmetric(horizontal: 10.toWidth),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 30.toWidth),
          color: buttonColor,
          border: border,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prefix != null) prefix!,
            Text(
              buttonText,
              textAlign: TextAlign.center,
              style: titleStyle,
            ),
            if (suffix != null) suffix!,
          ],
        ),
      ),
    );
  }
}
