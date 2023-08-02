import 'package:at_contacts_flutter/utils/colors.dart';
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
    fontWeight: FontWeight.normal,
  );

  TextStyle orange12 = TextStyle(
    color: AllColors().ORANGE,
    fontSize: 12.toFont,
    fontWeight: FontWeight.normal,
  );

  TextStyle orange14 = TextStyle(
    color: AllColors().ORANGE,
    fontSize: 14.toFont,
    fontWeight: FontWeight.normal,
  );

  TextStyle orange18 = TextStyle(
    color: AllColors().ORANGE,
    fontSize: 18.toFont,
    fontWeight: FontWeight.normal,
  );

  TextStyle primaryBold18 = TextStyle(
    color: AllColors().Black,
    fontWeight: FontWeight.w700,
    fontSize: 18.toFont,
  );

  static TextStyle primaryMedium14 = TextStyle(
    color: AllColors().DARK_GREY,
    fontSize: 14.toFont,
    fontWeight: FontWeight.w500,
  );

  TextStyle grey16 = TextStyle(
    color: AllColors().GREY,
    fontSize: 16.toFont,
    fontWeight: FontWeight.normal,
  );

  TextStyle grey14 = TextStyle(
    color: AllColors().GREY,
    fontSize: 14.toFont,
    fontWeight: FontWeight.normal,
  );

  //desktop
  static TextStyle desktopPrimaryRegular14 = const TextStyle(
      color: Colors.black,
      fontSize: 14,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle primaryRegular20 = TextStyle(
      color: ColorConstants.fontPrimary,
      fontSize: 20.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.bold);

  static TextStyle blackBold({int size = 16}) =>
      TextStyle(
        color: Colors.black,
        fontSize: size.toFont,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w700,
      );

  static TextStyle secondaryRegular12 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 12.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle secondaryRegular16 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 16.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle secondaryRegular14 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 14.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle primaryBold16 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontSize: 16.toFont,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w700,
  );

  static TextStyle error14 = TextStyle(
      color: ColorConstants.redText,
      fontSize: 14.toFont,
      letterSpacing: 0.1,
      fontWeight: FontWeight.normal);

  static TextStyle textBlackW60025 = TextStyle(
    color: AllColors().textBlack,
    fontSize: 25.toFont,
    fontWeight: FontWeight.w600,
  );

  static TextStyle blackW60013 = const TextStyle(
    color: Colors.black,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static TextStyle blackW40011 = const TextStyle(
    color: Colors.black,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );

  static TextStyle alphabeticalTextBold20 = TextStyle(
    color: AllColors().alphabeticalTextColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle whiteW50015 = const TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static TextStyle blackW50020 = const TextStyle(
    color: Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static TextStyle orangeW50014 = TextStyle(
      color: AllColors().buttonColor,
      fontSize: 14,
      fontWeight: FontWeight.w500
  );

  static TextStyle whiteBold16 = const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static TextStyle whiteBold12 = const TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );
}
