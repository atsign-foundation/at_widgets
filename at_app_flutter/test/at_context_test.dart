import 'package:at_app_flutter/at_app_flutter.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final preference = AtClientPreference()..namespace = 'PREF_NAMESPACE';
  final atClientService = AtClientService();

  const titleText = 'title';
  const textWidget = Text(titleText);
  final contextWidget = AtContext(
    child: textWidget,
    atClientPreference: preference,
    atClientService: atClientService,
  );
  group('AtContext Test', () {
    testWidgets('Widget Tree Test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: contextWidget,
          ),
        ),
        Duration(seconds: 5),
      );

      final contextFinder = find.byWidget(contextWidget, skipOffstage: false);
      expect(contextFinder, findsOneWidget);

      final textFinder = find.byWidget(textWidget, skipOffstage: false);
      expect(textFinder, findsOneWidget,
          reason: 'Could not find text widget in tree.');

      BuildContext textWidgetContext = tester.element(textFinder);
      AtContext atContext = AtContext.of(textWidgetContext);

      expect(atContext.atClientPreference, preference,
          reason: 'AtClientPreference did not match the context.');
      expect(atContext.atClientService, atClientService,
          reason: 'AtClientService did not match the context.');
    });
  });
}
