import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'at_enrollment_flutter_method_channel.dart';

abstract class AtEnrollmentFlutterPlatform extends PlatformInterface {
  /// Constructs a AtEnrollmentFlutterPlatform.
  AtEnrollmentFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static AtEnrollmentFlutterPlatform _instance =
      MethodChannelAtEnrollmentFlutter();

  /// The default instance of [AtEnrollmentFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelAtEnrollmentFlutter].
  static AtEnrollmentFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AtEnrollmentFlutterPlatform] when
  /// they register themselves.
  static set instance(AtEnrollmentFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
