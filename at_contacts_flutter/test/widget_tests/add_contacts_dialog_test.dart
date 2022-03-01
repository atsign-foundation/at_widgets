import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contacts_flutter/widgets/add_contacts_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget addContactsDialog}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return addContactsDialog;
    }));
  }

  /// Functional test cases for Add contacts dialog
  group('Add contacts dialog widget Tests:', () {
    // Test case to identify Add contacts dialog is used in screen or not
    testWidgets("Add contacts dialog widget is used and shown on screen",
        (WidgetTester tester) async {
      final addContactsDialog = AddContactDialog();
      await tester.pumpWidget(
          _wrapWidgetWithMaterialApp(addContactsDialog: addContactsDialog));

      expect(find.byType(AddContactDialog), findsOneWidget);
    });
  });
}
