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

  const BlockedUserCard({Key? key, this.blockeduser}) : super(key: key);
  @override
  _BlockedUserCardState createState() => _BlockedUserCardState();
}

class _BlockedUserCardState extends State<BlockedUserCard> {
  late ContactService _contactService;
  bool unblockUser = false;
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
      Uint8List image = Uint8List.fromList(intList);
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
          children: <Widget>[
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
        onTap: () async {
          setState(() {
            unblockUser = true;
          });
          // ignore: unawaited_futures
          showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Center(
                child: Text(TextStrings().unblockContact),
              ),
              content: Container(
                height: 100.toHeight,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
          await _contactService.blockUnblockContact(
              contact: widget.blockeduser!, blockAction: false);

          setState(() {
            unblockUser = false;
            Navigator.pop(context);
          });
        },
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
