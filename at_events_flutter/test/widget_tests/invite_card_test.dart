import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_events_flutter/common_components/invite_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget inviteCard}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return Scaffold(body: Container(child: inviteCard));
    }));
  }

  /// Functional test cases for Invite Card Widget
  group('Invite Card Widget Tests:', () {
    // Test Case to Check Invite Card is displayed
    final inviteCard = InviteCard();
    // testWidgets("Invite Card is displayed", (WidgetTester tester) async {
    //   await tester
    //       .pumpWidget(_wrapWidgetWithMaterialApp(inviteCard: inviteCard));
    //   expect(find.byType(InviteCard), findsOneWidget);
    // });
  });
}
