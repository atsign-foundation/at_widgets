import 'package:at_common_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String hintText, initialValue;
  final double width, height;
  final IconData icon;
  final Function onTap, onSubmitted;
  final Color iconColor;
  final ValueChanged<String> value;
  final bool isReadOnly;

  final textController = TextEditingController();

  CustomInputField(
      {this.hintText = '',
      this.height = 50,
      this.width = 300,
      this.iconColor,
      this.icon,
      this.onTap,
      this.value,
      this.initialValue = '',
      this.onSubmitted,
      this.isReadOnly = false});

  @override
  Widget build(BuildContext context) {
    textController.text = initialValue;
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
              decoration: InputDecoration(
                hintText: hintText,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
                hintStyle: TextStyle(color: ColorConstants.darkGrey),
              ),
              onTap: onTap ?? null,
              onChanged: (val) {
                value(val);
              },
              controller: textController,
              onSubmitted: (str) {
                if (onSubmitted != null) {
                  onSubmitted(str);
                }
              },
            ),
          ),
          icon != null
              ? Icon(
                  icon,
                  color: iconColor ?? ColorConstants.darkGrey,
                )
              : SizedBox()
        ],
      ),
    );
  }
}
