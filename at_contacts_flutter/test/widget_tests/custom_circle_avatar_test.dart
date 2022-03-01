import 'package:at_common_flutter/at_common_flutter.dart';
// import 'package:at_contacts_flutter/widgets/custom_circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget customCircleAvatar}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return Scaffold(
        body: Container(
          child: customCircleAvatar,
        ),
      );
    }));
  }

  /// Functional test cases for Custom circle avatar
  group('Custom circle avatar widget Tests:', () {
    // Test case to identify Custom circle avatar is used in screen or not
    // testWidgets("Custom circle avatar widget is used and shown on screen",
    //     (WidgetTester tester) async {
    //   final customCircleAvatar = CustomCircleAvatar();
    //   await tester.pumpWidget(
    //       _wrapWidgetWithMaterialApp(customCircleAvatar: customCircleAvatar));

    //   expect(find.byType(CustomCircleAvatar), findsOneWidget);
    // });
  });
}
