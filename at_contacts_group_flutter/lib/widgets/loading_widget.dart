import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contacts_flutter/utils/colors.dart';
import 'package:at_contacts_group_flutter/widgets/triple_dot_loading.dart';
import 'package:flutter/material.dart';

import 'custom_popup_route.dart';

class LoadingDialog {
  LoadingDialog._();

  static LoadingDialog _instance = LoadingDialog._();

  factory LoadingDialog() => _instance;
  bool _showing = false;

  show(GlobalKey<NavigatorState> key, {String? text}) {
    if (!_showing) {
      _showing = true;
      key.currentState!
          .push(CustomPopupRoutes(
              pageBuilder: (_, __, ___) {
                print("building loader");
                return Center(
                  child: (text != null)
                      ? onlyText(text)
                      : CircularProgressIndicator(),
                );
              },
              barrierDismissible: false))
          .then((_) {});
    }
  }

  hide(GlobalKey<NavigatorState> key) {
    print("hide called");
    if (_showing) {
      key.currentState!.pop();
      _showing = false;
    }
  }

  onlyText(String text, {TextStyle? style}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            text,
            textScaleFactor: 1,
            style: style ??
                TextStyle(
                    color: ColorConstants.MILD_GREY,
                    fontSize: 20.toFont,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.none),
          ),
        ),
        TypingIndicator(
          showIndicator: true,
          flashingCircleBrightColor: ColorConstants.dullText,
          flashingCircleDarkColor: ColorConstants.fadedText,
        ),
      ],
    );
  }
}
