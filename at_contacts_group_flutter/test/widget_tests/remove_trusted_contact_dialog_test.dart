import 'package:at_common_flutter/at_common_flutter.dart';
// import 'package:at_contacts_group_flutter/widgets/remove_trusted_contact_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget removeTrustedContact}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return Scaffold(body: Container(child: removeTrustedContact));
    }));
  }

  /// Functional test cases for Remove Trusted Contact Dialog
  group('Remove Trusted Contact Dialog widget Test', () {
    //final removeTrustedContact = RemoveTrustedContact();
    // // Test Case to check  is Remove Trusted Contact Dialog displayed or not
    // testWidgets('Test Case to check Remove Trusted Contact Dialog is displayed',
    //     (WidgetTester tester) async {
    //   await tester.pumpWidget(_wrapWidgetWithMaterialApp(
    //       removeTrustedContact: removeTrustedContact ));
    //   expect(find.byType(RemoveTrustedContact), findsOneWidget);
    // });
  });
}
