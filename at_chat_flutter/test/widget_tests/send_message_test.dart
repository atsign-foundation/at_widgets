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
    testWidgets("Send message widget is used and shown on screen",
        (WidgetTester tester) async {
      // ignore: prefer_const_constructors
      final sendMessage = SendMessage();
      await tester.pumpWidget(_wrapWidgetWithMaterialApp(
          sendMessage: sendMessage));

      expect(find.byType(SendMessage), findsOneWidget);
    });
    // Test case to identify media button color is given
    testWidgets("Color of button is button default color",
        (WidgetTester tester) async {
      // ignore: prefer_const_constructors
      final sendMessage = SendMessage();
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(sendMessage: sendMessage));
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      final mediaButtonColor = iconButton.color;
      expect(
        mediaButtonColor,
        Colors.orange
      );
    });
    // Test case to check media button is clicked
    testWidgets("OnPress is given an action", (WidgetTester tester) async {
      // ignore: prefer_const_constructors
      final sendMessage = SendMessage();
      var onPressed = false;
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(sendMessage: sendMessage));
      await tester.tap((find.byType(IconButton)));
      expect(onPressed, true);
    });

  });
}
