import 'package:at_common_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String hintText;
  final double width, height;
  final IconData icon;
  final Function onTap;
  final Color iconColor;

  CustomInputField(
      {this.hintText = '',
      this.height = 50,
      this.width = 300,
      this.iconColor,
      this.icon,
      this.onTap});

  @override
  Widget build(BuildContext context) {
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
              decoration: InputDecoration(
                hintText: hintText,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
                hintStyle: TextStyle(color: ColorConstants.darkGrey),
              ),
              onTap: onTap ?? null,
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
