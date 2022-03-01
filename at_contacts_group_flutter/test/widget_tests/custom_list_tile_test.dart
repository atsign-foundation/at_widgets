import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contacts_group_flutter/widgets/custom_list_tile.dart';


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget customListTile}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return Scaffold(body: customListTile);
    }));
  }

  /// Functional test cases for custom list tile
  group('Custom list tile widget Test', () {
    final customListTile = CustomListTile();
    // Test Case to check  is custom list tile displayed or not
    // testWidgets(
    //     'Test Case to check custom list tile is displayed',
    //     (WidgetTester tester) async {
    //   await tester.pumpWidget(
    //       _wrapWidgetWithMaterialApp(customListTile: customListTile));
    //   expect(find.byType(CustomListTile), findsOneWidget);
    // });
  });
}
