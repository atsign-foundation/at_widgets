import 'package:at_chat_flutter/screens/chat_screen.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget chatScreen}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return chatScreen;
    }));
  }

  /// Functional test cases for ChatScreen
  group('Chat Screen Tests:', () {
    // variable widget to be tested in each case
    final chatScreen = ChatScreen();

    // Test case to identify button is used in screen or not
    testWidgets("Chat Screen is displayed",
        (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(chatScreen: chatScreen));

      expect(find.byType(ChatScreen), findsOneWidget);
    });
  });
}
