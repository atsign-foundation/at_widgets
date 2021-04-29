import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';

void initializeContactsService(
    AtClientImpl atClientInstance, String currentAtSign,
    {rootDomain = 'root.atsign.wtf', rootPort = 64}) {
  ContactService().initContactsService(
      atClientInstance, currentAtSign, rootDomain, rootPort);
}

void disposeContactsControllers() {
  ContactService().disposeControllers();
}

Future<AtContact> getAtSignDetails(String atSign) async {
  AtContact? atContact = getCachedContactDetail(atSign);
  if (atContact == null) {
    Map<String, dynamic> contactDetails =
        await ContactService().getContactDetails(atSign);
    atContact = AtContact(
      atSign: atSign,
      tags: contactDetails,
    );
    if (contactDetails != null) {
      ContactService().cachedContactList.add(atContact);
    }
  }
  return atContact;
}

AtContact? getCachedContactDetail(String atsign) {
  if (atsign == ContactService().atContactImpl.atClient.currentAtSign &&
      ContactService().loggedInUserDetails != null) {
    return ContactService().loggedInUserDetails;
  }
  if (ContactService().cachedContactList.isNotEmpty) {
    int index = ContactService()
        .cachedContactList
        .indexWhere((element) => element!.atSign == atsign);
    if (index > -1) return ContactService().cachedContactList[index];
  }
  return null;
}
