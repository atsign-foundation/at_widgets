import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_onboarding_flutter/widgets/custom_reset_button.dart';

import '../test_material_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget customResetButton}) {
    return TestMaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          SizeConfig().init(context);
          return Scaffold(body: Container(child: customResetButton));
        },
      ),
    );
  }

  /// Functional test cases for Custom reset button
  group('Custom reset button Tests:', () {
    const customResetButton = CustomResetButton(
      buttonText: 'Click Here',
      height: 30.0,
      width: 100.0,
    );
    // Test case to check Custom reset button is is displayed
    testWidgets('Custom reset button is used', (WidgetTester tester) async {
      await tester.pumpWidget(
          _wrapWidgetWithMaterialApp(customResetButton: customResetButton));
      expect(find.byType(CustomResetButton), findsOneWidget);
    });
    // Test case to Custom reset button title is given
    testWidgets('Test case to check Custom reset button title is given',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _wrapWidgetWithMaterialApp(customResetButton: customResetButton));
      expect(customResetButton.buttonText, 'Click Here');
    });
    // Test case to Custom reset button height is given
    testWidgets('Test case to check Custom reset button height is given',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _wrapWidgetWithMaterialApp(customResetButton: customResetButton));
      expect(customResetButton.height, 30.0);
    });
    // Test case to Custom reset button width is given
    testWidgets('Test case to check Custom reset button width is given',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          _wrapWidgetWithMaterialApp(customResetButton: customResetButton));
      expect(customResetButton.width, 100.0);
    });
  });
}
