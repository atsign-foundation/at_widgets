import 'package:flutter/material.dart';
import 'package:at_follows_flutter/services/size_config.dart';
import 'package:at_follows_flutter/utils/color_constants.dart';

class CustomTextStyles {
  //regular textstyles
  static TextStyle fontR20light =
      TextStyle(fontSize: 20.0.toFont, color: ColorConstants.light);
  static TextStyle fontR18light =
      TextStyle(fontSize: 18.toFont, color: ColorConstants.light);
  static TextStyle fontR16light =
      TextStyle(fontSize: 16.toFont, color: ColorConstants.light);
  static TextStyle fontR14light =
      TextStyle(fontSize: 14.toFont, color: ColorConstants.light);

  //medium textstyles
  static TextStyle fontM20light = TextStyle(
      fontSize: 20.0.toFont,
      color: ColorConstants.light,
      fontWeight: FontWeight.w500);
  static TextStyle fontM18light = TextStyle(
      fontSize: 18.toFont,
      color: ColorConstants.light,
      fontWeight: FontWeight.w500);
  static TextStyle fontM16light = TextStyle(
      fontSize: 16.toFont,
      color: ColorConstants.light,
      fontWeight: FontWeight.w500);
  static TextStyle fontM14light = TextStyle(
      fontSize: 14.toFont,
      color: ColorConstants.light,
      fontWeight: FontWeight.w500);

  //bold TextStyles
  static TextStyle fontBold20light = TextStyle(
      fontSize: 20.0.toFont,
      color: ColorConstants.light,
      fontWeight: FontWeight.bold);
  static TextStyle fontBold18light = TextStyle(
      fontSize: 18.toFont,
      color: ColorConstants.light,
      fontWeight: FontWeight.bold);
  static TextStyle fontBold16light = TextStyle(
      fontSize: 16.toFont,
      color: ColorConstants.light,
      fontWeight: FontWeight.bold);
  static TextStyle fontBold14light = TextStyle(
      fontSize: 14.toFont,
      color: ColorConstants.light,
      fontWeight: FontWeight.bold);

  //regular textstyles
  static TextStyle fontR20dark =
      TextStyle(fontSize: 20.0.toFont, color: ColorConstants.dark);
  static TextStyle fontR18dark =
      TextStyle(fontSize: 18.toFont, color: ColorConstants.dark);
  static TextStyle fontR16dark =
      TextStyle(fontSize: 16.toFont, color: ColorConstants.dark);
  static TextStyle fontR14dark =
      TextStyle(fontSize: 14.toFont, color: ColorConstants.dark);

  //medium textstyles
  static TextStyle fontM20dark = TextStyle(
      fontSize: 20.0.toFont,
      color: ColorConstants.dark,
      fontWeight: FontWeight.w500);
  static TextStyle fontM18dark = TextStyle(
      fontSize: 18.toFont,
      color: ColorConstants.dark,
      fontWeight: FontWeight.w500);
  static TextStyle fontM16dark = TextStyle(
      fontSize: 16.toFont,
      color: ColorConstants.dark,
      fontWeight: FontWeight.w500);
  static TextStyle fontM14dark = TextStyle(
      fontSize: 14.toFont,
      color: ColorConstants.dark,
      fontWeight: FontWeight.w500);

  //bold TextStyles
  static TextStyle fontBold20dark = TextStyle(
      fontSize: 20.0.toFont,
      color: ColorConstants.dark,
      fontWeight: FontWeight.bold);
  static TextStyle fontBold18dark = TextStyle(
      fontSize: 18.toFont,
      color: ColorConstants.dark,
      fontWeight: FontWeight.bold);
  static TextStyle fontBold16dark = TextStyle(
      fontSize: 16.toFont,
      color: ColorConstants.dark,
      fontWeight: FontWeight.bold);
  static TextStyle fontBold14dark = TextStyle(
      fontSize: 14.toFont,
      color: ColorConstants.dark,
      fontWeight: FontWeight.bold);

  //regular textstyles
  static TextStyle fontR20primary =
      TextStyle(fontSize: 20.0.toFont, color: ColorConstants.primary);
  static TextStyle fontR18primary =
      TextStyle(fontSize: 18.toFont, color: ColorConstants.primary);
  static TextStyle fontR16primary =
      TextStyle(fontSize: 16.toFont, color: ColorConstants.primary);
  static TextStyle fontR14primary =
      TextStyle(fontSize: 14.toFont, color: ColorConstants.primary);

  //medium textstyles
  static TextStyle fontM20primary = TextStyle(
      fontSize: 20.0.toFont,
      color: ColorConstants.primary,
      fontWeight: FontWeight.w500);
  static TextStyle fontM18primary = TextStyle(
      fontSize: 18.toFont,
      color: ColorConstants.primary,
      fontWeight: FontWeight.w500);
  static TextStyle fontM16primary = TextStyle(
      fontSize: 16.toFont,
      color: ColorConstants.primary,
      fontWeight: FontWeight.w500);
  static TextStyle fontM14primary = TextStyle(
      fontSize: 14.toFont,
      color: ColorConstants.primary,
      fontWeight: FontWeight.w500);

  //bold TextStyles
  static TextStyle fontBold20primary = TextStyle(
      fontSize: 20.0.toFont,
      color: ColorConstants.primary,
      fontWeight: FontWeight.bold);
  static TextStyle fontBold18primary = TextStyle(
      fontSize: 18.toFont,
      color: ColorConstants.primary,
      fontWeight: FontWeight.bold);
  static TextStyle fontBold16primary = TextStyle(
      fontSize: 16.toFont,
      color: ColorConstants.primary,
      fontWeight: FontWeight.bold);
  static TextStyle fontBold14primary = TextStyle(
      fontSize: 14.toFont,
      color: ColorConstants.primary,
      fontWeight: FontWeight.bold);

  //regular textstyles
  static TextStyle fontR20secondary =
      TextStyle(fontSize: 20.0.toFont, color: ColorConstants.secondary);
  static TextStyle fontR18secondary =
      TextStyle(fontSize: 18.toFont, color: ColorConstants.secondary);
  static TextStyle fontR16secondary =
      TextStyle(fontSize: 16.toFont, color: ColorConstants.secondary);
  static TextStyle fontR14secondary =
      TextStyle(fontSize: 14.toFont, color: ColorConstants.secondary);

  //medium textstyles
  static TextStyle fontM20secondary = TextStyle(
      fontSize: 20.0.toFont,
      color: ColorConstants.secondary,
      fontWeight: FontWeight.w500);
  static TextStyle fontM18secondary = TextStyle(
      fontSize: 18.toFont,
      color: ColorConstants.secondary,
      fontWeight: FontWeight.w500);
  static TextStyle fontM16secondary = TextStyle(
      fontSize: 16.toFont,
      color: ColorConstants.secondary,
      fontWeight: FontWeight.w500);
  static TextStyle fontM14secondary = TextStyle(
      fontSize: 14.toFont,
      color: ColorConstants.secondary,
      fontWeight: FontWeight.w500);

  //bold TextStyles
  static TextStyle fontBold20secondary = TextStyle(
      fontSize: 20.0.toFont,
      color: ColorConstants.secondary,
      fontWeight: FontWeight.bold);
  static TextStyle fontBold18secondary = TextStyle(
      fontSize: 18.toFont,
      color: ColorConstants.secondary,
      fontWeight: FontWeight.bold);
  static TextStyle fontBold16secondary = TextStyle(
      fontSize: 16.toFont,
      color: ColorConstants.secondary,
      fontWeight: FontWeight.bold);
  static TextStyle fontBold14secondary = TextStyle(
      fontSize: 14.toFont,
      color: ColorConstants.secondary,
      fontWeight: FontWeight.bold);

  static void refresh() {
    if (!SizeConfig().isReady) {
      return;
    }

    //regular textstyles
    fontR20light =
        TextStyle(fontSize: 20.0.toFont, color: ColorConstants.light);
    fontR18light = TextStyle(fontSize: 18.toFont, color: ColorConstants.light);
    fontR16light = TextStyle(fontSize: 16.toFont, color: ColorConstants.light);
    fontR14light = TextStyle(fontSize: 14.toFont, color: ColorConstants.light);

    //medium textstyles
    fontM20light = TextStyle(
        fontSize: 20.0.toFont,
        color: ColorConstants.light,
        fontWeight: FontWeight.w500);
    fontM18light = TextStyle(
        fontSize: 18.toFont,
        color: ColorConstants.light,
        fontWeight: FontWeight.w500);
    fontM16light = TextStyle(
        fontSize: 16.toFont,
        color: ColorConstants.light,
        fontWeight: FontWeight.w500);
    fontM14light = TextStyle(
        fontSize: 14.toFont,
        color: ColorConstants.light,
        fontWeight: FontWeight.w500);

    //bold TextStyles
    fontBold20light = TextStyle(
        fontSize: 20.0.toFont,
        color: ColorConstants.light,
        fontWeight: FontWeight.bold);
    fontBold18light = TextStyle(
        fontSize: 18.toFont,
        color: ColorConstants.light,
        fontWeight: FontWeight.bold);
    fontBold16light = TextStyle(
        fontSize: 16.toFont,
        color: ColorConstants.light,
        fontWeight: FontWeight.bold);
    fontBold14light = TextStyle(
        fontSize: 14.toFont,
        color: ColorConstants.light,
        fontWeight: FontWeight.bold);

    //regular textstyles
    fontR20dark = TextStyle(fontSize: 20.0.toFont, color: ColorConstants.dark);
    fontR18dark = TextStyle(fontSize: 18.toFont, color: ColorConstants.dark);
    fontR16dark = TextStyle(fontSize: 16.toFont, color: ColorConstants.dark);
    fontR14dark = TextStyle(fontSize: 14.toFont, color: ColorConstants.dark);

    //medium textstyles
    fontM20dark = TextStyle(
        fontSize: 20.0.toFont,
        color: ColorConstants.dark,
        fontWeight: FontWeight.w500);
    fontM18dark = TextStyle(
        fontSize: 18.toFont,
        color: ColorConstants.dark,
        fontWeight: FontWeight.w500);
    fontM16dark = TextStyle(
        fontSize: 16.toFont,
        color: ColorConstants.dark,
        fontWeight: FontWeight.w500);
    fontM14dark = TextStyle(
        fontSize: 14.toFont,
        color: ColorConstants.dark,
        fontWeight: FontWeight.w500);

    //bold TextStyles
    fontBold20dark = TextStyle(
        fontSize: 20.0.toFont,
        color: ColorConstants.dark,
        fontWeight: FontWeight.bold);
    fontBold18dark = TextStyle(
        fontSize: 18.toFont,
        color: ColorConstants.dark,
        fontWeight: FontWeight.bold);
    fontBold16dark = TextStyle(
        fontSize: 16.toFont,
        color: ColorConstants.dark,
        fontWeight: FontWeight.bold);
    fontBold14dark = TextStyle(
        fontSize: 14.toFont,
        color: ColorConstants.dark,
        fontWeight: FontWeight.bold);

    //regular textstyles
    fontR20primary =
        TextStyle(fontSize: 20.0.toFont, color: ColorConstants.primary);
    fontR18primary =
        TextStyle(fontSize: 18.toFont, color: ColorConstants.primary);
    fontR16primary =
        TextStyle(fontSize: 16.toFont, color: ColorConstants.primary);
    fontR14primary =
        TextStyle(fontSize: 14.toFont, color: ColorConstants.primary);

    //medium textstyles
    fontM20primary = TextStyle(
        fontSize: 20.0.toFont,
        color: ColorConstants.primary,
        fontWeight: FontWeight.w500);
    fontM18primary = TextStyle(
        fontSize: 18.toFont,
        color: ColorConstants.primary,
        fontWeight: FontWeight.w500);
    fontM16primary = TextStyle(
        fontSize: 16.toFont,
        color: ColorConstants.primary,
        fontWeight: FontWeight.w500);
    fontM14primary = TextStyle(
        fontSize: 14.toFont,
        color: ColorConstants.primary,
        fontWeight: FontWeight.w500);

    //bold TextStyles
    fontBold20primary = TextStyle(
        fontSize: 20.0.toFont,
        color: ColorConstants.primary,
        fontWeight: FontWeight.bold);
    fontBold18primary = TextStyle(
        fontSize: 18.toFont,
        color: ColorConstants.primary,
        fontWeight: FontWeight.bold);
    fontBold16primary = TextStyle(
        fontSize: 16.toFont,
        color: ColorConstants.primary,
        fontWeight: FontWeight.bold);
    fontBold14primary = TextStyle(
        fontSize: 14.toFont,
        color: ColorConstants.primary,
        fontWeight: FontWeight.bold);

    //regular textstyles
    fontR20secondary =
        TextStyle(fontSize: 20.0.toFont, color: ColorConstants.secondary);
    fontR18secondary =
        TextStyle(fontSize: 18.toFont, color: ColorConstants.secondary);
    fontR16secondary =
        TextStyle(fontSize: 16.toFont, color: ColorConstants.secondary);
    fontR14secondary =
        TextStyle(fontSize: 14.toFont, color: ColorConstants.secondary);

    //medium textstyles
    fontM20secondary = TextStyle(
        fontSize: 20.0.toFont,
        color: ColorConstants.secondary,
        fontWeight: FontWeight.w500);
    fontM18secondary = TextStyle(
        fontSize: 18.toFont,
        color: ColorConstants.secondary,
        fontWeight: FontWeight.w500);
    fontM16secondary = TextStyle(
        fontSize: 16.toFont,
        color: ColorConstants.secondary,
        fontWeight: FontWeight.w500);
    fontM14secondary = TextStyle(
        fontSize: 14.toFont,
        color: ColorConstants.secondary,
        fontWeight: FontWeight.w500);

    //bold TextStyles
    fontBold20secondary = TextStyle(
        fontSize: 20.0.toFont,
        color: ColorConstants.secondary,
        fontWeight: FontWeight.bold);
    fontBold18secondary = TextStyle(
        fontSize: 18.toFont,
        color: ColorConstants.secondary,
        fontWeight: FontWeight.bold);
    fontBold16secondary = TextStyle(
        fontSize: 16.toFont,
        color: ColorConstants.secondary,
        fontWeight: FontWeight.bold);
    fontBold14secondary = TextStyle(
        fontSize: 14.toFont,
        color: ColorConstants.secondary,
        fontWeight: FontWeight.bold);
  }
}
