import 'package:at_contacts_group_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/at_common_flutter.dart';

class CustomTextStyles {
  CustomTextStyles._();
  static final CustomTextStyles _instance = CustomTextStyles._();
  factory CustomTextStyles() => _instance;

  TextStyle orange16 = TextStyle(
    color: AllColors().ORANGE,
    fontSize: 16.toFont,
  );

  TextStyle orange12 = TextStyle(
    color: AllColors().ORANGE,
    fontSize: 12.toFont,
  );

  TextStyle orange14 = TextStyle(
    color: AllColors().ORANGE,
    fontSize: 14.toFont,
  );

  TextStyle orange18 = TextStyle(
    color: AllColors().ORANGE,
    fontSize: 18.toFont,
  );

  TextStyle primaryBold18 = TextStyle(
    color: AllColors().Black,
    fontWeight: FontWeight.w700,
    fontSize: 18.toFont,
  );

  TextStyle primaryMedium14 = TextStyle(
    color: AllColors().DARK_GREY,
    fontSize: 14.toFont,
    fontWeight: FontWeight.w500,
  );

  TextStyle grey16 = TextStyle(color: AllColors().GREY, fontSize: 16.toFont);

  TextStyle grey14 = TextStyle(color: AllColors().GREY, fontSize: 14.toFont);
}
