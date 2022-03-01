import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contacts_flutter/widgets/custom_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget customListTile}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return Scaffold(
        body: Container(
          child: customListTile,
        ),
      );
    }));
  }

  /// Functional test cases for Custom List Tile
  group('Custom List Tile widget Tests:', () {
    // Test case to identify Custom List Tile is used in screen or not
    // testWidgets("Custom List Tile widget is used and shown on screen",
    //     (WidgetTester tester) async {
    //   final customListTile = CustomListTile();
    //   await tester
    //       .pumpWidget(_wrapWidgetWithMaterialApp(customListTile: customListTile));

    //   expect(find.byType(CustomListTile), findsOneWidget);
    // });
  });
}
