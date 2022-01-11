import 'package:at_contact/at_contact.dart';

class BaseContact {
  AtContact? contact;
  bool? isBlocking;
  bool? isMarkingFav;
  bool? isDeleting;

  BaseContact(
    this.contact, {
    this.isBlocking = false,
    this.isMarkingFav = false,
    this.isDeleting = false,
  });
}

enum STATE_UPDATE { block, markFav, delete, unblock }
