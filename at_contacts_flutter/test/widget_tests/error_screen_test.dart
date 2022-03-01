import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contacts_flutter/widgets/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget errorScreen}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return Scaffold(
        body: Container(
          child: errorScreen,
        ),
      );
    }));
  }

  /// Functional test cases for Error Screen
  group('Error Screen widget Tests:', () {
    // Test case to identify Error Screen is used in screen or not
    testWidgets("Error Screen widget is used and shown on screen",
        (WidgetTester tester) async {
      final errorScreen = ErrorScreen();
      await tester.pumpWidget(
          _wrapWidgetWithMaterialApp(errorScreen: errorScreen));

      expect(find.byType(ErrorScreen), findsOneWidget);
    });
  });
}
