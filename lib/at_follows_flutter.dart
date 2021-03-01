
import 'dart:async';

import 'package:flutter/services.dart';

class AtFollowsFlutter {
  static const MethodChannel _channel =
      const MethodChannel('at_follows_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
