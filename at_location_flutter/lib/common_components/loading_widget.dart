import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:flutter/material.dart';

import 'custom_popup_route.dart';

class LoadingDialog {
  LoadingDialog._();

  static final LoadingDialog _instance = LoadingDialog._();

  factory LoadingDialog() => _instance;
  bool _showing = false;

  void show() {
    if (!_showing) {
      _showing = true;
      AtLocationNotificationListener()
          .navKey
          .currentState!
          .push(CustomPopupRoutes<Widget>(
              pageBuilder: (_, __, ___) {
                print('building loader');
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              barrierDismissible: false))
          .then((_) {});
    }
  }

  void hide() {
    print('hide called');
    if (_showing) {
      AtLocationNotificationListener().navKey.currentState!.pop();
      _showing = false;
    }
  }
}
