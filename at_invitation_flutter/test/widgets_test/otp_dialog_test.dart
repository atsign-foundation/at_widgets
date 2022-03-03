// @dart=2.9
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_invitation_flutter/widgets/otp_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({Widget otpDialog}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return otpDialog;
    }));
  }

  /// Functional test cases for OTP Dialog Widget
  group('OTP Dialog Widget Tests:', () {
    // Test Case to Check OTP Dialog is displayed
    testWidgets("OTP Dialog is displayed", (WidgetTester tester) async {
      final otpDialog = OTPDialog();
      await tester
          .pumpWidget(_wrapWidgetWithMaterialApp(otpDialog: otpDialog));
      expect(find.byType(OTPDialog), findsOneWidget);
    });
  });
}
