/// A list tile to display the blocked contact
/// takes in a [AtContact] blocked user
/// and displays it's name, atsign, profile picture and option to unblock the user

import 'dart:typed_data';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/services/contact_service.dart';
import 'package:at_contacts_flutter/utils/text_strings.dart';
import 'package:at_contacts_flutter/utils/text_styles.dart';
import 'package:at_contacts_flutter/widgets/contacts_initials.dart';
import 'package:at_contacts_flutter/widgets/custom_circle_avatar.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

class BlockedUserCard extends StatefulWidget {
  final AtContact? blockeduser;
  final Function? unblockAtsign;

  const BlockedUserCard({Key? key, this.blockeduser, this.unblockAtsign})
      : super(key: key);
  @override
  _BlockedUserCardState createState() => _BlockedUserCardState();
}

class _BlockedUserCardState extends State<BlockedUserCard> {
  /// Instance of the contact service
  late ContactService _contactService;

  @override
  void initState() {
    super.initState();
    _contactService = ContactService();
  }

  @override
  Widget build(BuildContext context) {
    Widget contactImage;
    if (widget.blockeduser!.tags != null &&
        widget.blockeduser!.tags!['image'] != null) {
      List<int> intList = widget.blockeduser!.tags!['image'].cast<int>();
      var image = Uint8List.fromList(intList);
      contactImage = CustomCircleAvatar(
        byteImage: image,
        nonAsset: true,
      );
    } else {
      contactImage = ContactInitial(
        initials: widget.blockeduser!.atSign!,
      );
    }
    return ListTile(
      leading: contactImage,
      title: Container(
        width: 300.toWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.blockeduser!.atSign!.substring(1).toString(),
              style: CustomTextStyles.primaryRegular16,
            ),
            Text(
              widget.blockeduser!.atSign.toString(),
              style: CustomTextStyles.secondaryRegular12,
            ),
          ],
        ),
      ),
      trailing: GestureDetector(
        onTap: widget.unblockAtsign as void Function(),
        child: Container(
          child: Text(
            TextStrings().unblock,
            style: CustomTextStyles.blueRegular14,
          ),
        ),
      ),
    );
  }
}
