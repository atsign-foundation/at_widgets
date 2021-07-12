// ignore: import_of_legacy_library_into_null_safe
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';

// ignore: always_declare_return_types
Future<List<AtContact?>> fetchContacts() async {
  var contactList = await ContactService().fetchContacts();
  return contactList;
}
