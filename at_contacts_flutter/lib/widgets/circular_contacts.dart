import 'dart:typed_data';

// ignore: import_of_legacy_library_into_null_safe
import 'package:at_contact/at_contact.dart';
import 'package:at_contacts_flutter/widgets/contacts_initials.dart';
import 'package:at_contacts_flutter/widgets/custom_circle_avatar.dart';

///

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/services/size_config.dart';

class CircularContacts extends StatelessWidget {
  final Function? onCrossPressed;

  final AtContact? contact;

  const CircularContacts({Key? key, this.onCrossPressed, this.contact})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    Uint8List? image;
    if (contact!.tags != null && contact!.tags!['image'] != null) {
      List<int> intList = contact!.tags!['image'].cast<int>();
      image = Uint8List.fromList(intList);
    }
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: 9.toHeight, horizontal: 20.toWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              Container(
                height: 50.toHeight,
                width: 50.toHeight,
                child:
                    (contact!.tags != null && contact!.tags!['image'] != null)
                        ? CustomCircleAvatar(
                            byteImage: image,
                            nonAsset: true,
                          )
                        : ContactInitial(
                            initials: contact!.atSign!,
                          ),
                // child:
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onCrossPressed as void Function()?,
                  child: Container(
                    height: 12.toHeight,
                    width: 12.toHeight,
                    decoration: BoxDecoration(
                        color: Colors.black, shape: BoxShape.circle),
                    child: Icon(
                      Icons.close,
                      size: 10.toHeight,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.toHeight),
          Container(
            width: 80.toWidth,
            child: Text(
              contact!.tags != null && contact!.tags!['name'] != null
                  ? contact!.tags!['name']
                  : contact!.atSign!.substring(1),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15.toFont),
            ),
          ),
          SizedBox(height: 10.toHeight),
          Container(
            width: 60.toWidth,
            child: Text(
              contact!.atSign!,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15.toFont),
            ),
          )
        ],
      ),
    );
  }
}
