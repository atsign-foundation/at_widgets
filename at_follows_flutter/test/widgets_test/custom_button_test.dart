import 'package:at_follows_flutter/services/size_config.dart';
import 'package:at_follows_flutter/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget customButton}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return customButton;
    }));
  }

  /// Functional test cases for Custom Button Widget
  group('Custom Button Widget Tests:', () {
    // Test Case to Check Custom Button is displayed
    // testWidgets("Custom Button is displayed", (WidgetTester tester) async {
    //   final customButton =
    //       CustomButton(text: 'Click Here', onPressedCallBack: () {});
    //   await tester
    //       .pumpWidget(_wrapWidgetWithMaterialApp(customButton: customButton));
    //   expect(find.byType(CustomButton), findsOneWidget);
    // });
  });
}
