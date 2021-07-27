import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_common_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

/// This is a custom input field to have common functionalities of the app
// ignore: must_be_immutable
class CustomInputField extends StatelessWidget {
  /// The string to display if the input field is empty.
  final String hintText;

  /// A string to pre-populate the input field.
  final String initialValue;

  /// sets the width of the input field.
  final double width;

  /// sets the height of the input field.
  final double height;

  /// The trailing icon on the input field and calls the [onIconTap] or [onTap] when tapped.
  final IconData? icon;

  /// defines the function to execute on tap on the input field.
  final Function? onTap;

  /// defines the function to execute on tap on the [icon].
  final Function? onIconTap;

  /// defines the to execute on submit in the input field.
  final Function? onSubmitted;

  /// The color to fill the [icon].
  final Color? iconColor;

  /// The observable value of the input field.
  final ValueChanged<String>? value;

  /// makes the input field to be read only.
  final bool isReadOnly;

  TextEditingController textController = TextEditingController();

  CustomInputField(
      {this.hintText = '',
      this.height = 50,
      this.width = 300,
      this.iconColor,
      this.icon,
      this.onTap,
      this.onIconTap,
      this.value,
      this.initialValue = '',
      this.onSubmitted,
      this.isReadOnly = false});

  @override
  Widget build(BuildContext context) {
    textController = TextEditingController.fromValue(TextEditingValue(
        text: initialValue != null ? initialValue : '',
        selection: TextSelection.collapsed(
            offset: initialValue != null ? initialValue.length : -1)));
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: ColorConstants.inputFieldGrey,
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              readOnly: isReadOnly,
              style: TextStyle(
                fontSize: 15.toFont,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
                hintStyle: TextStyle(
                    color: ColorConstants.darkGrey, fontSize: 15.toFont),
              ),
              onTap: onTap as void Function()? ?? () {},
              onChanged: (val) {
                value!(val);
              },
              controller: textController,
              onSubmitted: (str) {
                if (onSubmitted != null) {
                  onSubmitted!(str);
                }
              },
            ),
          ),
          icon != null
              ? InkWell(
                  onTap: onIconTap as void Function()? ??
                      onTap as void Function()?,
                  child: Icon(
                    icon,
                    color: iconColor ?? ColorConstants.darkGrey,
                  ),
                )
              : SizedBox()
        ],
      ),
    );
  }
}
