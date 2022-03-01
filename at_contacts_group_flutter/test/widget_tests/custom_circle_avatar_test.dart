import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contacts_group_flutter/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget? customCircleAvatar}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return Scaffold(body: customCircleAvatar!);
    }));
  }

  /// Functional test cases for custom circle avatar
  group('Custom circle avatar widget Test', () {
    // Test Case to check  is custom circle avatar displayed or not
    // testWidgets('Test Case to check custom circle avatar is displayed',
    //     (WidgetTester tester) async {
    //   await tester.pumpWidget(_wrapWidgetWithMaterialApp(
    //       customCircleAvatar: const CustomCircleAvatar()));
    //   expect(find.byType(CustomCircleAvatar), findsOneWidget);
    // });
  });
}
