import 'package:at_common_flutter/at_common_flutter.dart';
// import 'package:at_contacts_flutter/widgets/blocked_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget blockedUserCard}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return blockedUserCard;
    }));
  }

  /// Functional test cases for Blocked User Card
  group('Blocked User Card widget Tests:', () {
    // Test case to identify Blocked User Card is used in screen or not
    // testWidgets("Blocked User Card widget is used and shown on screen",
    //     (WidgetTester tester) async {
    //   final blockedUserCard = BlockedUserCard();
    //   await tester.pumpWidget(
    //       _wrapWidgetWithMaterialApp(blockedUserCard: blockedUserCard));

    //   expect(find.byType(BlockedUserCard), findsOneWidget);
    // });
  });
}
