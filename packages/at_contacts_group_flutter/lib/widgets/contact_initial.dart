import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

// ignore: must_be_immutable
class ContactInitial extends StatelessWidget {
  /// Size of the circular profile placeholder
  final double size;
  final double? maxSize, minSize;

  /// Initials of the atsign
  final String initials;

  /// Index in the list of atsigns
  int? index;

  final double? borderRadius;

  ContactInitial({
    Key? key,
    this.size = 40,
    required this.initials,
    this.index,
    this.maxSize,
    this.minSize,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var encodedInitials = initials.runes;
    if (encodedInitials.length < 3) {
      index = encodedInitials.length;
    } else {
      index = 3;
    }

    return Container(
      height: size.toFont,
      width: size.toFont,
      decoration: BoxDecoration(
        color: ContactInitialsColors.getColor(initials),
        borderRadius: BorderRadius.circular((borderRadius ?? size)),
      ),
      child: Center(
        child: Text(
          String.fromCharCodes(encodedInitials, (index == 1) ? 0 : 1, index)
              .toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.toFont,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
