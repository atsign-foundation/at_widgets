import 'package:at_common_flutter/at_common_flutter.dart';
// import 'package:at_contacts_flutter/widgets/add_singular_contact_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget addSingleContactDialog}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return Container(child: addSingleContactDialog);
    }));
  }

  /// Functional test cases for Add singular contact dialog
  group('Add singular contact dialog widget Tests:', () {
    // Test case to identify Add singular contact dialog is used in screen or not
    // testWidgets("Add singular contact dialog widget is used and shown on screen",
    //     (WidgetTester tester) async {
    //   final addSingleContactDialog = AddSingleContact();
    //   await tester.pumpWidget(
    //       _wrapWidgetWithMaterialApp(addSingleContactDialog: addSingleContactDialog));

    //   expect(find.byType(AddSingleContact), findsOneWidget);
    // });
  });
}
