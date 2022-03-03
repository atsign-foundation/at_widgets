// @dart=2.9
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_invitation_flutter/widgets/share_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({Widget shareDialog}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return shareDialog;
    }));
  }

  /// Functional test cases for Share Dialog Widget
  group('Share Dialog Widget Tests:', () {
    // Test Case to Check Share Dialog is displayed
    testWidgets("Share Dialog is displayed", (WidgetTester tester) async {
      final shareDialog = ShareDialog(currentAtsign: '@bluebell86');
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(shareDialog: shareDialog));
      expect(find.byType(ShareDialog), findsOneWidget);
    });
  });
}
