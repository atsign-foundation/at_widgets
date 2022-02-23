// import 'package:at_chat_flutter/widgets/custom_circle_avatar.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget customCircularAvatar}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return customCircularAvatar;
    }));
  }

  /// Functional test cases for [customCircularAvatar]
  group('Circular Avatar Widget Tests:', () {
    // TODO: Test Case to custom circular avatar is displayed
    // testWidgets("Circular Avatar is displayed", (WidgetTester tester) async {
    //   // ignore: prefer_const_constructors
    //   final customCircularAvatar = CustomCircleAvatar();
    //   await tester.pumpWidget(
    //       _wrapWidgetWithMaterialApp(customCircularAvatar: customCircularAvatar));
    //   expect(find.byType(CustomCircleAvatar), findsOneWidget);
    // });
  });
}
