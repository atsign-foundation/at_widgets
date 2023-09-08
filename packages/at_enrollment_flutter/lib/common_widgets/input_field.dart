import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatelessWidget {
  Widget? prefix;
  Widget? suffix;
  String hintText;
  bool isNumpad;
  int? maxLength;
  Function(String) onChange;
  EdgeInsetsGeometry padding;
  BorderRadius borderRadius;
  TextStyle? hintStyle;
  TextStyle? style;
  bool isCenter;

  InputField({
    super.key,
    this.prefix,
    this.suffix,
    required this.onChange,
    this.maxLength,
    this.isNumpad = false,
    this.hintText = '',
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(25)),
    this.hintStyle,
    this.style,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          prefix ?? const SizedBox.shrink(),
          Expanded(
            child: TextField(
              maxLength: maxLength,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              maxLines: 1,
              textAlign: isCenter ? TextAlign.center : TextAlign.start,
              keyboardType:
                  isNumpad ? TextInputType.number : TextInputType.text,
              style: style,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: hintStyle,
                  counterText: "",
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
              onChanged: (String val) {
                onChange(val);
              },
            ),
          ),
          suffix ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
