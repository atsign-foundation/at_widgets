import 'package:at_chat_flutter/widgets/outgoing_message_bubble.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget outgoingMessageBubble}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return outgoingMessageBubble;
    }));
  }
  /// Functional test cases for OutgoingMessageBubble
  group('Button widget Tests:', () {
    // Test case to identify incoming message bubble is used in screen or not
    testWidgets("Button widget is used and shown on screen",
        (WidgetTester tester) async {
      // ignore: prefer_const_constructors
      final outgoingMessageBubble = OutgoingMessageBubble();
      await tester.pumpWidget(_wrapWidgetWithMaterialApp(
          outgoingMessageBubble: outgoingMessageBubble));

      expect(find.byType(OutgoingMessageBubble), findsOneWidget);
    });
  });
}
