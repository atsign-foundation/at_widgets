// import 'package:at_chat_flutter/models/message_model.dart';
// import 'package:at_chat_flutter/utils/colors.dart';
// import 'package:at_chat_flutter/widgets/contacts_initials.dart';
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
    // Test case to identify outgoing message bubble is used in screen or not
    testWidgets("Button widget is used and shown on screen",
        (WidgetTester tester) async {
      // ignore: prefer_const_constructors
      final outgoingMessageBubble = OutgoingMessageBubble((message){});
      await tester.pumpWidget(_wrapWidgetWithMaterialApp(
          outgoingMessageBubble: outgoingMessageBubble));

      expect(find.byType(OutgoingMessageBubble), findsOneWidget);
    });

    // TODO: Test case to identify outgoing message has text
    // testWidgets("Check message in outgoing message bubble",
    //     (WidgetTester tester) async {
    //   Message displayMessage =
    //       Message(id: '1', time: 9, message: 'Hi', sender: 'x');
    //   final outgoingMessageBubble = OutgoingMessageBubble((message){},message: displayMessage,);
    //   await tester.pumpWidget(_wrapWidgetWithMaterialApp(
    //       outgoingMessageBubble: outgoingMessageBubble));
    //   expect(find.text(displayMessage.toString()), findsOneWidget);
    // });

    // // TODO: Test case to identify color of outgoing message bubble
    // testWidgets("Color of button is button default color",
    //     (WidgetTester tester) async {
    //   final outgoingMessageBubble = OutgoingMessageBubble((message){});
    //   await tester.pumpWidget(_wrapWidgetWithMaterialApp(
    //       outgoingMessageBubble: outgoingMessageBubble));
    //   final container = tester.widget<Container>(find.byType(Container));
    //   final decoration = container.decoration as BoxDecoration;
    //   expect(
    //     decoration.color,
    //     CustomColors.defaultColor,
    //   );
    // });

    // TODO: Test case to identify color of avatar in outgoing message bubble
    // testWidgets("Color of avatar in outgoing message bubble",
    //     (WidgetTester tester) async {
    //   final outgoingMessageBubble = OutgoingMessageBubble((message){});
    //   await tester.pumpWidget(_wrapWidgetWithMaterialApp(
    //       outgoingMessageBubble: outgoingMessageBubble));
    //   final contactInitial = tester.widget<ContactInitial>(find.byType(ContactInitial));
    //   final avatarColor = contactInitial.backgroundColor;
    //   expect(
    //     avatarColor,
    //     CustomColors.defaultColor,
    //   );
    // });
  });
}
