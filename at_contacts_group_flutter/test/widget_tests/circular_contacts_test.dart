import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_contacts_group_flutter/widgets/circular_contacts.dart';
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

  /// Functional test cases for circular contact
  group('Circular contacts Widget Test', () {
    // Test Case to check circular contact displayed or not
    // testWidgets('Circular contact Widget is Displayed',
    //     (WidgetTester tester) async {
    //   final circularContacts = CircularContacts(onCrossPressed: (){},groupContact: GroupContactsModel(),);
    //   await tester.pumpWidget(
    //       _wrapWidgetWithMaterialApp(circularContacts: circularContacts));
    //   expect(find.byType(CircularContacts), findsOneWidget);
    // });
    // Test case to check button text is given
    // testWidgets("Button Text is given", (WidgetTester tester) async {
    //   final circularContacts =CircularContacts();
    //   await tester.pumpWidget(
    //       _wrapWidgetWithMaterialApp(circularContacts: circularContacts));
    //   expect(find.text('Click here'), findsOneWidget);
    // });

    // Test case to check onPress functionality
    // testWidgets("OnPress is given an action", (WidgetTester tester) async {
    //   final circularContacts = CircularContacts();
    //   await tester.pumpWidget(
    //       _wrapWidgetWithMaterialApp(circularContacts: circularContacts));
    //   expect(circularContacts.onCrossPressed!.call(), null);
    // });
  });
}
