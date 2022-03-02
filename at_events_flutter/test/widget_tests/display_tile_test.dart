import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget displayTile}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return displayTile;
    }));
  }

  /// Functional test cases for Display Tile Widget
  group('Display Tile Widget Tests:', () {
    // Test Case to Check Display Tile is displayed
    final displayTile = DisplayTile(title: 'title', subTitle: 'subTitle');
    // testWidgets("Display Tile is displayed", (WidgetTester tester) async {
    //   await tester
    //       .pumpWidget(_wrapWidgetWithMaterialApp(displayTile: displayTile));
    //   expect(find.byType(DisplayTile), findsOneWidget);
    // });
  });
}
