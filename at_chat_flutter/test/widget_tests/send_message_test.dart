import 'package:at_chat_flutter/widgets/send_message.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget sendMessage}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return sendMessage;
    }));
  }

  /// Functional test cases for Send Message
  group('Button widget Tests:', () {
    // Test case to identify send message is used in screen or not
    testWidgets("Button widget is used and shown on screen",
        (WidgetTester tester) async {
      // ignore: prefer_const_constructors
      final sendMessage = SendMessage();
      await tester.pumpWidget(_wrapWidgetWithMaterialApp(
          sendMessage: sendMessage));

      expect(find.byType(SendMessage), findsOneWidget);
    });
  });
}
