import 'package:at_chat_flutter/utils/colors.dart';
import 'package:at_chat_flutter/widgets/contacts_initials.dart';
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

  group('Contacts Initial widget Tests', () {
    testWidgets('Contacts initial with text', (WidgetTester tester) async {
      await tester
          .pumpWidget(_homeWidget(home: ContactInitial(initials:'@')));
      final contactsInitial =
          tester.widget<ContactInitial>(find.byType(ContactInitial));
      expect(contactsInitial.initials, '@');
    });
    testWidgets('Contacts initial with background color',
        (WidgetTester tester) async {
      await tester.pumpWidget(_homeWidget(
          home: ContactInitial(initials: '@',backgroundColor: CustomColors.defaultColor,)));
      final contactsInitial =
          tester.widget<ContactInitial>(find.byType(ContactInitial));
      expect(contactsInitial.backgroundColor, CustomColors.defaultColor,);
    });

    testWidgets('Contacts initial without background color',
        (WidgetTester tester) async {
      await tester.pumpWidget(_homeWidget(home: ContactInitial(initials: '@',)));
      final contactsInitial =
          tester.widget<ContactInitial>(find.byType(ContactInitial));
      expect(contactsInitial.backgroundColor, '');
    });
  });
}
