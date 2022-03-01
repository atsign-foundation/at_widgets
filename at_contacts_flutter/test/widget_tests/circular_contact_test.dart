import 'package:at_common_flutter/at_common_flutter.dart';
// import 'package:at_contacts_flutter/widgets/circular_contacts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget circularContacts}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return circularContacts;
    }));
  }

  /// Functional test cases for Circular Contacts
  group('Circular Contacts widget Tests:', () {
    // Test case to identify Circular Contacts is used in screen or not
    // testWidgets("Circular Contacts widget is used and shown on screen",
    //     (WidgetTester tester) async {
    //   final circularContacts = CircularContacts();
    //   await tester
    //       .pumpWidget(_wrapWidgetWithMaterialApp(circularContacts: circularContacts));

    //   expect(find.byType(CircularContacts), findsOneWidget);
    // });
  });
}
