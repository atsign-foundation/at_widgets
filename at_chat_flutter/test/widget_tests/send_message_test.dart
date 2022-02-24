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
  // TODO: Need to correct up the material/parent widget
  /// Functional test cases for Send Message
  group('Button widget Tests:', () {
    // Test case to identify media button color is given
    // testWidgets("Color of button is button default color",
    //     (WidgetTester tester) async {
    //   // ignore: prefer_const_constructors
    //   final sendMessage = SendMessage(
    //     mediaButtonColor: Colors.orange,
    //   );
    //   await tester
    //       .pumpWidget(_wrapWidgetWithMaterialApp(sendMessage: sendMessage));
    //   final buttonColor = tester.widget<SendMessage>(find.byType(SendMessage));
    //   expect(buttonColor.mediaButtonColor, Colors.orange);
    // });

    // Test case to check Send button is clicked
    // testWidgets("Media Button is given an action", (WidgetTester tester) async {
    //   // ignore: prefer_const_constructors
    //   await tester
    //       .pumpWidget(_wrapWidgetWithMaterialApp(sendMessage: SendMessage(
    //     onSend: () {
    //       print('Send button is clicked');
    //     },
    //   )));
    //   final sendMessageMedia =
    //       tester.widget<SendMessage>(find.byType(SendMessage));
    //   await tester.tap((find.byType(SendMessage)));
    //   expect(sendMessageMedia.onSend!.call(), null);
    // });
  });
}
