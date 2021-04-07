import 'package:at_commons/at_commons.dart';
import 'package:at_contact/at_contact.dart';

import 'key_stream_service.dart';

Future<AtContact> getAtSignDetails(String atSign) async {
  AtContact atContact = getCachedContactDetail(atSign);
  if (atContact == null) {
    Map<String, dynamic> contactDetails = await getContactDetails(atSign);
    atContact = AtContact(
      atSign: atSign,
      tags: contactDetails,
    );
  }
  return atContact;
}

AtContact getCachedContactDetail(String atsign) {
  if (atsign == KeyStreamService().atContactImpl?.atClient?.currentAtSign) {
    return KeyStreamService().loggedInUserDetails;
  }
  if (KeyStreamService().contactList.isNotEmpty) {
    int index = KeyStreamService()
        .contactList
        .indexWhere((element) => element.atSign == atsign);
    if (index > -1) return KeyStreamService().contactList[index];
  }
  return null;
}

getContactDetails(atSign) async {
  Map<String, dynamic> contactDetails = {};

  if (KeyStreamService().atClientInstance == null || atSign == null) {
    return contactDetails;
  } else if (!atSign.contains('@')) {
    atSign = '@' + atSign;
  }
  var metadata = Metadata();
  metadata.isPublic = true;
  metadata.namespaceAware = false;
  AtKey key = AtKey();
  key.sharedBy = atSign;
  key.metadata = metadata;
  List contactFields = [
    'firstname.persona',
    'lastname.persona',
    'image.persona',
  ];

  try {
    // firstname
    key.key = contactFields[0];
    var result = await KeyStreamService().atClientInstance.get(key).catchError(
        // ignore: return_of_invalid_type_from_catch_error
        (e) => print("error in get ${e.errorCode} ${e.errorMessage}"));
    var firstname = result.value;

    // lastname
    key.key = contactFields[1];
    result = await KeyStreamService().atClientInstance.get(key);
    var lastname = result.value;

    // construct name
    var name = ((firstname ?? '') + ' ' + (lastname ?? '')).trim();
    if (name.length == 0) {
      name = atSign.substring(1);
    }

    // profile picture
    key.metadata.isBinary = true;
    key.key = contactFields[2];
    result = await KeyStreamService().atClientInstance.get(key);
    var image = result.value;
    contactDetails['name'] = name;
    contactDetails['image'] = image;
  } catch (e) {
    contactDetails['name'] = null;
    contactDetails['image'] = null;
  }
  return contactDetails;
}
