import 'dart:async';

import 'package:at_chat_flutter/widgets/bottom_sheet_dialog.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _wrapWidgetWithMaterialApp({required Widget bottomSheetDialog}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return bottomSheetDialog;
    }));
  }

  /// Functional test cases for Bottom Sheet Dialog Widget
  group('Bottom Sheet Dialog Widget Tests:', () {
    // Test Case to Check bottom sheet is displayed
    testWidgets("Botton Sheet is displayed", (WidgetTester tester) async {
      final bottomSheetDialog = BottomSheetDialog(() {});
      await tester.pumpWidget(
          _wrapWidgetWithMaterialApp(bottomSheetDialog: bottomSheetDialog));
      expect(find.byType(BottomSheetDialog), findsOneWidget);
    });

    // TODO: Test Case to Check call back function is passed
    // testWidgets("Test Case to Check call back function is passed", (WidgetTester tester) async {
    //   final completer = Completer<void>();
    //   final bottomSheetDialog = BottomSheetDialog(() {
    //     completer.complete;
    //   });
    //   await tester.pumpWidget(
    //       _wrapWidgetWithMaterialApp(bottomSheetDialog: bottomSheetDialog));

    //   // await tester.tap((find.byType(GestureDetector)));
    //   expect(bottomSheetDialog.deleteCallback, (){});
    // });
  });
}
