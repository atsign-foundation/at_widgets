import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:at_contacts_group_flutter/at_contacts_group_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('at_contacts_group_flutter');

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
  //   expect(await AtContactsGroupFlutter.platformVersion, '42');
  // });
}
