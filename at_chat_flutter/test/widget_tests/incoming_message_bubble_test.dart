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
  group('Button widget Tests:', () {
    // Test case to identify incoming message bubble is used in screen or not
    testWidgets("Incoming message bubble widget is used and shown on screen",
        (WidgetTester tester) async {
      final incomingMessageBubble = IncomingMessageBubble();
      await tester.pumpWidget(_wrapWidgetWithMaterialApp(
          incomingMessageBubble: incomingMessageBubble));

      expect(find.byType(IncomingMessageBubble), findsOneWidget);
    });
  });
}
