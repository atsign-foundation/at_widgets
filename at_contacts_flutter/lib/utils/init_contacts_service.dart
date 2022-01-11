import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';

/// Function to initialise contacts Service
void initializeContactsService(
    {rootDomain = 'root.atsign.org', rootPort = 64}) {
  ContactService().initContactsService(rootDomain, rootPort);
}

/// Function call from app to dispose stream controllers used in the package
void disposeContactsControllers() {
  ContactService().disposeControllers();
}

/// Function to fetch the contact details of an atsign
Future<AtContact> getAtSignDetails(String atSign) async {
  // ignore: omit_local_variable_types
  AtContact? atContact = getCachedContactDetail(atSign);
  if (atContact == null) {
    var contactDetails = await ContactService().getContactDetails(atSign, null);
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

/// Function to fetch the contact details of an atsign from cached list
AtContact? getCachedContactDetail(String atsign) {
  if (atsign == ContactService().atContactImpl.atClient?.getCurrentAtSign() &&
      ContactService().loggedInUserDetails != null) {
    return ContactService().loggedInUserDetails;
  }
  if (ContactService().cachedContactList.isNotEmpty) {
    var index = ContactService()
        .cachedContactList
        .indexWhere((element) => element.atSign == atsign);
    if (index > -1) return ContactService().cachedContactList[index];
  }
  return null;
}
