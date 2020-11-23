import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:atsign_authentication_helper/atsign_authentication_helper.dart';

void main() {
  const MethodChannel channel = MethodChannel('atsign_authentication_helper');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await AtsignAuthenticationHelper.platformVersion, '42');
  // });
}
