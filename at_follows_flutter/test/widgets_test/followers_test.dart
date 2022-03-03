import 'package:at_follows_flutter/services/size_config.dart';
// import 'package:at_follows_flutter/widgets/followers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget followers}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return followers;
    }));
  }

  /// Functional test cases for Followers Widget
  group('Followers Widget Tests:', () {
    // Test Case to Check Followers is displayed
    // testWidgets("Followers is displayed",
    //     (WidgetTester tester) async {
    //   final followers = Followers();
    //   await tester.pumpWidget(
    //       _wrapWidgetWithMaterialApp(followers: followers));
    //   expect(find.byType(Followers), findsOneWidget);
    // });
  });
}
