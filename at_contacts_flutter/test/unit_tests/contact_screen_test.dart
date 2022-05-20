import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockContactService extends Mock implements ContactService {}

void main() {
  ContactService mockContactService = MockContactService();
  group('Contact Screen test', () {
    setUp(() {
      reset(mockContactService);
    });
    test('Contacts fetched form contacts service', () {
      when(() => mockContactService.fetchContacts().then((_) async {
            print('Contacts fetched successfully');
          }));
    });
  });
}
