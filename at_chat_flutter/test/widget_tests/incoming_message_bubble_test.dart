import 'package:at_chat_flutter/models/message_model.dart';
import 'package:at_chat_flutter/utils/colors.dart';
import 'package:at_chat_flutter/widgets/contacts_initials.dart';
import 'package:at_chat_flutter/widgets/incoming_message_bubble.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget incomingMessageBubble}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return incomingMessageBubble;
    }));
  }

  /// Functional test cases for IncomingMessageBubble
  group('IncomingMessageBubble widget Tests:', () {
    // Test case to identify incoming message bubble is used in screen or not
    testWidgets("Incoming message bubble widget is used and shown on screen",
        (WidgetTester tester) async {
      final incomingMessageBubble = IncomingMessageBubble();
      await tester.pumpWidget(_wrapWidgetWithMaterialApp(
          incomingMessageBubble: incomingMessageBubble));

      expect(find.byType(IncomingMessageBubble), findsOneWidget);
    });
    // Test case to identify incoming message has text
    testWidgets("Check message in incoming message bubble",
        (WidgetTester tester) async {
      Message displayMessage =
          Message(id: '1', time: 9, message: 'Hi', sender: 'x');
      final incomingMessageBubble =
          IncomingMessageBubble(message: displayMessage);
      await tester.pumpWidget(_wrapWidgetWithMaterialApp(
          incomingMessageBubble: incomingMessageBubble));
      expect(find.text(displayMessage.toString()), findsOneWidget);
    });

    // Test case to identify color of incoming message bubble
    testWidgets("Color of button is button default color",
        (WidgetTester tester) async {
      final incomingMessageBubble = IncomingMessageBubble();
      await tester.pumpWidget(_wrapWidgetWithMaterialApp(
          incomingMessageBubble: incomingMessageBubble));
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.color,
        CustomColors.defaultColor,
      );
    });

    // Test case to identify color of avatar in incoming message bubble
    testWidgets("Color of avatar in incoming message bubble",
        (WidgetTester tester) async {
      final incomingMessageBubble = IncomingMessageBubble();
      await tester.pumpWidget(_wrapWidgetWithMaterialApp(
          incomingMessageBubble: incomingMessageBubble));
      final contactInitial = tester.widget<ContactInitial>(find.byType(ContactInitial));
      final avatarColor = contactInitial.backgroundColor;
      expect(
        avatarColor,
        CustomColors.defaultColor,
      );
    });
  });
}
