import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_onboarding_flutter/widgets/custom_appbar.dart';

import '../test_material_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget customAppBar}) {
    return TestMaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          SizeConfig().init(context);
          return Scaffold(body: Container(child: customAppBar));
        },
      ),
    );
  }

  /// Functional test cases for custom app bar
  group('custom app bar Tests:', () {
    final customAppBar = CustomAppBar(title: 'Title',);
    // Test case to check custom app bar is is displayed
    testWidgets('Custom app bar is used', (WidgetTester tester) async {
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(customAppBar: customAppBar));
      expect(find.byType(CustomAppBar), findsOneWidget);
    });
    // Test case to custom app bar title is given
    testWidgets('Test case to check custom app bar title is given',
        (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWidgetWithMaterialApp(
          customAppBar: customAppBar));
      expect(customAppBar.title, 'Title');
    });
  });
}
