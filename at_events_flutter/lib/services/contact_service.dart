import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';

import 'event_key_stream_service.dart';

Future<AtContact> getAtSignDetails(String? atSign) async {
  AtContact? atContact = getCachedContactDetail(atSign);
  if (atContact == null) {
    Map<String, dynamic> contactDetails = await getContactDetails(atSign);
    atContact = AtContact(
      atSign: atSign,
      tags: contactDetails,
    );
  }
  return atContact;
}

AtContact? getCachedContactDetail(String? atsign) {
  if (atsign == EventKeyStreamService().atContactImpl?.atClient?.currentAtSign) {
    return EventKeyStreamService().loggedInUserDetails;
  }
  if (EventKeyStreamService().contactList.isNotEmpty) {
    int index = EventKeyStreamService().contactList.indexWhere((AtContact element) => element.atSign == atsign);
    if (index > -1) return EventKeyStreamService().contactList[index];
  }
  return null;
}

Future<Map<String, dynamic>> getContactDetails(String? atSign) async {
  Map<String, dynamic> contactDetails = <String, dynamic>{};

  if (EventKeyStreamService().atClientInstance == null || atSign == null) {
    return contactDetails;
  } else if (!atSign.contains('@')) {
    atSign = '@' + atSign;
  }
  Metadata metadata = Metadata();
  metadata.isPublic = true;
  metadata.namespaceAware = false;
  AtKey key = AtKey();
  key.sharedBy = atSign;
  key.metadata = metadata;
  List<String> contactFields = <String>[
    'firstname.persona',
    'lastname.persona',
    'image.persona',
  ];

  try {
    // firstname
    key.key = contactFields[0];
    AtValue result = await EventKeyStreamService().atClientInstance!.get(key).catchError((dynamic e) {
      print('error in get ${e.errorCode} ${e.errorMessage}');
    });
    dynamic firstname = result.value;

    // lastname
    key.key = contactFields[1];
    result = await EventKeyStreamService().atClientInstance!.get(key);
    dynamic lastname = result.value;

    // construct name
    String name = ((firstname ?? '') + ' ' + (lastname ?? '')).trim();
    if (name.isEmpty) {
      name = atSign.substring(1);
    }

    // profile picture
    key.metadata!.isBinary = true;
    key.key = contactFields[2];
    result = await EventKeyStreamService().atClientInstance!.get(key);
    dynamic image = result.value;
    contactDetails['name'] = name;
    contactDetails['image'] = image;
  } catch (e) {
    contactDetails['name'] = null;
    contactDetails['image'] = null;
  }
  return contactDetails;
}
