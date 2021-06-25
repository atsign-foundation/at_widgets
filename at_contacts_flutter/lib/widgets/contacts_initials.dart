import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class ContactInitial extends StatelessWidget {
  final double size;
  final String initials;
  int? index;
  Key? key;

  ContactInitial({
    this.size = 40,
    this.key,
    required this.initials,
    this.index,
  });
  @override
  Widget build(BuildContext context) {
    if (initials.length < 3) {
      index = initials.length;
    } else {
      index = 3;
    }

    return Container(
      height: size.toFont,
      width: size.toFont,
      decoration: BoxDecoration(
        color: ContactInitialsColors.getColor(initials),
        borderRadius: BorderRadius.circular((size.toWidth)),
      ),
      child: Center(
        child: Text(
          initials.substring((index == 1) ? 0 : 1, index).toUpperCase(),
          style: CustomTextStyles.whiteBold(
            size: (size ~/ 3).toInt(),
          ),
        ),
      ),
    );
  }
}
