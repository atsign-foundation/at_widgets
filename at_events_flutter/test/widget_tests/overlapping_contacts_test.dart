import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_events_flutter/common_components/overlapping_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget overlappingContacts}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return overlappingContacts;
    }));
  }

  /// Functional test cases for Overlapping Contacts Widget
  group('Overlapping Contacts Widget Tests:', () {
    // Test Case to Check Overlapping Contacts is displayed
    final overlappingContacts = OverlappingContacts();
    // testWidgets("Overlapping Contacts is displayed", (WidgetTester tester) async {
    //   await tester
    //       .pumpWidget(_wrapWidgetWithMaterialApp(overlappingContacts: overlappingContacts));
    //   expect(find.byType(OverlappingContacts), findsOneWidget);
    // });
  });
}
