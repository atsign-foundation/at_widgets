// ignore: import_of_legacy_library_into_null_safe
import 'package:at_client_mobile/at_client_mobile.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';

void initializeContactsService(
    AtClientImpl atClientInstance, String currentAtSign,
    {String rootDomain = 'root.atsign.wtf', int rootPort = 64}) {
  ContactService().initContactsService(
      atClientInstance, currentAtSign, rootDomain, rootPort);
}

void disposeContactsControllers() {
  ContactService().disposeControllers();
}

Future<AtContact> getAtSignDetails(String atSign) async {
  AtContact? atContact = getCachedContactDetail(atSign);
  if (atContact == null) {
    Map<String, dynamic> contactDetails = await ContactService().getContactDetails(atSign, null);
    atContact = AtContact(
      atSign: atSign,
      tags: contactDetails,
    );
    // ignore: unnecessary_null_comparison
    if (contactDetails != null) {
      ContactService().cachedContactList.add(atContact);
    }
  }
  return atContact;
}

// this function is used to get contact from cached array only
AtContact checkForCachedContactDetail(String atSign) {
  // ignore: omit_local_variable_types
  AtContact? atContact = getCachedContactDetail(atSign);
  return atContact ?? AtContact(atSign: atSign);
}

AtContact? getCachedContactDetail(String atsign) {
  if (atsign == ContactService().atContactImpl.atClient?.currentAtSign &&
      ContactService().loggedInUserDetails != null) {
    return ContactService().loggedInUserDetails;
  }
  if (ContactService().cachedContactList.isNotEmpty) {
    int index = ContactService()
        .cachedContactList
        .indexWhere((AtContact? element) => element!.atSign == atsign);
    if (index > -1) return ContactService().cachedContactList[index];
  }
  return null;
}
