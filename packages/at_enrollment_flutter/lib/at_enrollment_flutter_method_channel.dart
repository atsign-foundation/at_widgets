import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'at_enrollment_flutter_platform_interface.dart';

/// An implementation of [AtEnrollmentFlutterPlatform] that uses method channels.
class MethodChannelAtEnrollmentFlutter extends AtEnrollmentFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('at_enrollment_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
