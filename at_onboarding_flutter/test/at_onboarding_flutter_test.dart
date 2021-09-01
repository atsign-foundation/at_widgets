import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_onboarding_flutter/utils/strings.dart';
import 'package:at_onboarding_flutter/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_material_app.dart';

void main() {
  BuildContext? ctxt;
  Widget _homeWidget({required Widget home}) {
    return TestMaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          SizeConfig().init(context);
          context = context;
          return home;
        },
      ),
    );
  }

  group('test @sign form widget', () {
    String? _atsign;
    AppConstants.rootDomain = 'vip.ve.atsign.zone';
    Key uniqueKey = const Key(Strings.submitButton);

    testWidgets('entering invalid @signs', (WidgetTester tester) async {
      void onSubmit(String atsign) {
        print('atsign is $atsign');
        _atsign = atsign;
      }

      await tester.pumpWidget(
        _homeWidget(
          home: CustomDialog(
            context: ctxt,
            isAtsignForm: true,
            onSubmit: onSubmit,
          ),
        ),
      );
      await tester.tap(find.byWidgetPredicate((Widget widget) =>
          widget is Text && widget.data == Strings.submitButton));
      expect(find.byType(CustomDialog), findsOneWidget);
      expect(_atsign, null);
    });

    testWidgets('entering valid @sign', (WidgetTester tester) async {
      void onSubmit(String atsign) {
        print('atsign is $atsign');
        _atsign = atsign;
      }

      await tester.pumpWidget(_homeWidget(
          home: CustomDialog(
              context: ctxt, isAtsignForm: true, onSubmit: onSubmit)));

      await tester.enterText(find.byType(TextFormField), 'ALICE 💙');
      expect(
          find.byWidgetPredicate((Widget widget) =>
              widget is TextFormField && widget.controller!.text == 'alice💙'),
          findsOneWidget);
      expect(find.byType(CustomDialog), findsOneWidget);
      await tester.tap(find.byKey(uniqueKey));
      expect(_atsign, 'alice💙');
      await tester.pump();
      expect(find.byType(CustomDialog), findsOneWidget);
    });
  });
}
