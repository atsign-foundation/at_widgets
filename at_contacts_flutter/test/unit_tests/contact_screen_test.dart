import 'dart:developer';

import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAtcontactImpl extends Mock implements AtContactsImpl {}

void main() {
  MockAtcontactImpl mockAtcontactImpl = MockAtcontactImpl();
  group('Contact Screen test', () {
    setUp(() {});

    test('Fetching contacts', () async {
      when(() => mockAtcontactImpl.listContacts())
          .thenAnswer((invocation) async => [AtContact(atSign: '@alice')]);

      ContactService().atContactImpl = mockAtcontactImpl;
      var res = await ContactService().fetchContacts();

      expect(res, isA<List<AtContact>>());
    });
  });
}
