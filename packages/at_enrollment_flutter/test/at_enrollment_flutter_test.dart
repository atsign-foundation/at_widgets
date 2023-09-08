// import 'package:flutter_test/flutter_test.dart';
// import 'package:at_enrollment_flutter/at_enrollment_flutter.dart';
// import 'package:at_enrollment_flutter/at_enrollment_flutter_platform_interface.dart';
// import 'package:at_enrollment_flutter/at_enrollment_flutter_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';
//
// class MockAtEnrollmentFlutterPlatform
//     with MockPlatformInterfaceMixin
//     implements AtEnrollmentFlutterPlatform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }
//
// void main() {
//   final AtEnrollmentFlutterPlatform initialPlatform = AtEnrollmentFlutterPlatform.instance;
//
//   test('$MethodChannelAtEnrollmentFlutter is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelAtEnrollmentFlutter>());
//   });
//
//   test('getPlatformVersion', () async {
//     AtEnrollmentFlutter atEnrollmentFlutterPlugin = AtEnrollmentFlutter();
//     MockAtEnrollmentFlutterPlatform fakePlatform = MockAtEnrollmentFlutterPlatform();
//     AtEnrollmentFlutterPlatform.instance = fakePlatform;
//
//     expect(await atEnrollmentFlutterPlugin.getPlatformVersion(), '42');
//   });
// }
