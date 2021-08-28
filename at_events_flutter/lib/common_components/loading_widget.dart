import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_events_flutter/utils/colors.dart';
import 'package:flutter/material.dart';

import 'custom_popup_route.dart';
import 'triple_dot_loading.dart';

class LoadingDialog {
  LoadingDialog._();

  static final LoadingDialog _instance = LoadingDialog._();

  factory LoadingDialog() => _instance;
  bool _showing = false;

  void show({String? text}) {
    if (!_showing) {
      _showing = true;
      AtEventNotificationListener()
          .navKey!
          .currentState!
          .push(CustomPopupRoutes<Widget>(
              pageBuilder: (_, __, ___) {
                print('building loader');
                return Center(
                  child: (text != null)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                text,
                                textScaleFactor: 1,
                                style: TextStyle(
                                    color: AllColors().MILD_GREY,
                                    fontSize: 20.toFont,
                                    fontWeight: FontWeight.w400,
                                    decoration: TextDecoration.none),
                              ),
                            ),
                            TypingIndicator(
                              showIndicator: true,
                              flashingCircleBrightColor: AllColors().LIGHT_GREY,
                              flashingCircleDarkColor: AllColors().DARK_GREY,
                            ),
                          ],
                        )
                      : const CircularProgressIndicator(),
                );
              },
              barrierDismissible: false))
          .then((_) {});
    }
  }

  void hide() {
    print('hide called');
    if (_showing) {
      AtEventNotificationListener().navKey!.currentState!.pop();
      _showing = false;
    }
  }
}
