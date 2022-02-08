import 'package:at_chat_flutter/utils/colors.dart';
import 'package:at_chat_flutter/widgets/button_widget.dart';
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_material_app.dart';

void main() {
  Widget _homeWidget({required Widget home}) {
    return TestMaterialApp(home: Builder(builder: (BuildContext context) {
      SizeConfig().init(context);
      return home;
    }));
  }

  group('CustomButton widget Tests', () {
    testWidgets('CustomButton with text onPressed', (WidgetTester tester) async {
      await tester.pumpWidget(_homeWidget(
          home: ButtonWidget(
        borderRadius: const BorderRadius.all(
          Radius.circular(5.0),
        ),
        colorButton: CustomColors.defaultColor,
        onPress: () {
          prints('Button Pressed ');
        },
        textButton: '',
      )));
      final customButton =
          tester.widget<CustomButton>(find.byType(CustomButton));
      expect(customButton.buttonText, 'Yes');
    });
    
    testWidgets('CustomButton with text onPressed', (WidgetTester tester) async {
      await tester.pumpWidget(_homeWidget(
          home: ButtonWidget(
        borderRadius: const BorderRadius.all(
          Radius.circular(5.0),
        ),
        colorButton: CustomColors.defaultColor,
        onPress: () {
          prints('Button Pressed ');
        },
        textButton: '',
      )));
      final customButton =
          tester.widget<CustomButton>(find.byType(CustomButton));
      expect(customButton.buttonText, 'No');
    });
  });
}
