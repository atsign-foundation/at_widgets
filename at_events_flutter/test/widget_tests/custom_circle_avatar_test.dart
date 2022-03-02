import 'package:at_common_flutter/at_common_flutter.dart';
// import 'package:at_events_flutter/common_components/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget customCircleAvatar}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return customCircleAvatar;
    }));
  }

  /// Functional test cases for Custom Circle Avatar Widget
  group('Custom Circle Avatar Widget Tests:', () {
    // Test Case to Check Custom Circle Avatar is displayed
    // final customCircleAvatar = CustomCircleAvatar();
    // testWidgets("Custom Circle Avatar is displayed", (WidgetTester tester) async {
    //   await tester.pumpWidget(
    //       _wrapWidgetWithMaterialApp(customCircleAvatar: customCircleAvatar));
    //   expect(find.byType(CustomCircleAvatar), findsOneWidget);
    // });
  });
}
