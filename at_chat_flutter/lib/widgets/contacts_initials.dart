/// This is a widget to display the initials of an atsign which does not have a profile picture
/// it takes in @param [size] as a double and
/// @param [initials] as String and display those initials in a circular avatar with random colors

import 'package:at_chat_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class ContactInitial extends StatelessWidget {
  final double size;
  final String? initials;
  final Color backgroundColor;

  const ContactInitial(
      {Key? key,
      this.size = 50,
      this.initials,
      this.backgroundColor = CustomColors.defaultColor})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.toFont,
      width: size.toFont,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size.toWidth),
      ),
      // border: Border.all(width: 0.5, color: ColorConstants.fontSecondary)),
      child: Center(
        child:
            Text(initials?.toUpperCase() != null ? initials!.toUpperCase() : '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.toFont,
                  fontWeight: FontWeight.w700,
                )),
      ),
    );
  }
}
