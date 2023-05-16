import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:at_login_flutter/at_login_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('at_login_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

}
