import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/services/size_config.dart';

class CustomTextStyles {
  CustomTextStyles._();
  static final CustomTextStyles _instance = CustomTextStyles._();
  factory CustomTextStyles() => _instance;

  static TextStyle primaryBold18 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontSize: 18.toFont,
    fontWeight: FontWeight.w700,
  );

  static TextStyle primaryRegular16 = TextStyle(
      color: ColorConstants.fontPrimary,
      fontSize: 16.toFont,
      fontWeight: FontWeight.normal);

  static TextStyle secondaryRegular12 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 12.toFont,
      fontWeight: FontWeight.normal);

  static TextStyle blueRegular14 = TextStyle(
      color: ColorConstants.appBarCloseColor,
      fontSize: 14.toFont,
      fontWeight: FontWeight.normal);

  static TextStyle whiteBold16 = TextStyle(
    color: Colors.white,
    fontSize: 16.toFont,
    fontWeight: FontWeight.w700,
  );

  static TextStyle primaryMedium14 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontSize: 14.toFont,
    fontWeight: FontWeight.w500,
  );

  static TextStyle secondaryRegular16 = TextStyle(
      color: ColorConstants.fontSecondary,
      fontSize: 16.toFont,
      fontWeight: FontWeight.normal);

  static TextStyle primaryBold16 = TextStyle(
    color: ColorConstants.fontPrimary,
    fontSize: 16.toFont,
    fontWeight: FontWeight.w700,
  );
}
