import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_onboarding_flutter/widgets/custom_button.dart';

import '../test_material_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget customButton}) {
    return TestMaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          SizeConfig().init(context);
          return Scaffold(body: Container(child: customButton));
        },
      ),
    );
  }

  /// Functional test cases for custom button
  group('custom button Tests:', () {
    final customButton = CustomButton(
      buttonText: 'Click Here',
      height: 30.0,
      width: 100.0,
    );
    // Test case to check custom button is is displayed
    testWidgets('Custom Button is used', (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(customButton: customButton));
      expect(find.byType(CustomButton), findsOneWidget);
    });
    // Test case to custom button title is given
    testWidgets('Test case to check custom button title is given',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(customButton: customButton));
      expect(customButton.buttonText, 'Click Here');
    });
    // Test case to custom button height is given
    testWidgets('Test case to check custom button height is given',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(customButton: customButton));
      expect(customButton.height, 30.0);
    });
    // Test case to custom button width is given
    testWidgets('Test case to check custom button width is given',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(customButton: customButton));
      expect(customButton.width, 100.0);
    });
  });
}
