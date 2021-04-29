// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:at_common_flutter_example/main.dart';
import 'test_material_app.dart';

void main() {
  Widget _homeWidget({@required Widget home}) {
    return TestMaterialApp(home: home);
  }

  group('testing common custom widgets', () {
    testWidgets('Testing customAppBar with and without title',
        (WidgetTester tester) async {
      await tester
          .pumpWidget(_homeWidget(home: MyHomePage(title: 'Welcome Screen')));
      final appBar = tester.widget<CustomAppBar>(find.byType(CustomAppBar));
      expect(appBar.titleText, 'Welcome Screen');

      await tester.pumpWidget(_homeWidget(home: MyHomePage()));
      expect(tester.takeException(), isInstanceOf<AssertionError>());
    });

    testWidgets('Custom Input Field', (WidgetTester tester) async {
      await tester
          .pumpWidget(_homeWidget(home: MyHomePage(title: 'Welcome Screen')));

      var text = 'Hello!!';
      await tester.enterText(find.byType(CustomInputField), text);
      expect(find.text(text), findsOneWidget);

      text = 'accepts @, *, #, %, 1,2,80, characters';
      await tester.enterText(find.byType(CustomInputField), text);
      expect(find.text(text), findsOneWidget);

      text = '\n is not considered';
      await tester.enterText(find.byType(CustomInputField), text);
      expect(find.text(text), findsNothing);
    });

    testWidgets('Custom Button', (WidgetTester tester) async {
      await tester
          .pumpWidget(_homeWidget(home: MyHomePage(title: 'Welcome Screen')));

      expect(find.byType(CustomButton), findsOneWidget);
      await tester.tap(find.byType(CustomButton));

      var customButton =
          await tester.widget<CustomButton>(find.byType(CustomButton));
      expect(customButton.buttonText, 'Add');
      expect(customButton.buttonColor, Colors.black);
      expect(customButton.onPressed.call(), null);

      await tester.pumpWidget(_homeWidget(home: CustomButton()));
      expect(customButton.buttonText, 'Add');
      expect(customButton.buttonColor, Colors.black);
      expect(customButton.onPressed.call(), null);
    });
  });
}
