import 'dart:typed_data';
// ignore: import_of_legacy_library_into_null_safe
import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_contacts_flutter/widgets/contacts_initials.dart';
import 'package:at_contacts_flutter/widgets/custom_circle_avatar.dart';
import 'package:at_contacts_group_flutter/models/group_contacts_model.dart';
import 'package:at_utils/at_logger.dart';
import 'package:flutter/material.dart';

class CircularContacts extends StatelessWidget {
  final Function? onCrossPressed;
  final GroupContactsModel? groupContact;
  final AtSignLogger atSignLogger = AtSignLogger('CircularContacts');

  CircularContacts({Key? key, this.onCrossPressed, this.groupContact})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Uint8List? image;
    if (groupContact?.contact?.tags != null &&
        groupContact?.contact?.tags!['image'] != null) {
      try {
        List<int> intList = groupContact?.contact?.tags!['image'].cast<int>();
        image = Uint8List.fromList(intList);
      } catch (e) {
        atSignLogger.info('Error in getting image');
      }
    }
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: 10.toHeight, horizontal: 20.toWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              SizedBox(
                height: 50.toHeight,
                width: 50.toHeight,
                child: (image != null)
                    ? CustomCircleAvatar(
                        byteImage: image,
                        nonAsset: true,
                      )
                    : ContactInitial(
                        initials: (groupContact?.contact?.atSign ??
                            groupContact?.group?.groupName)!,
                      ),
                // child:
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onCrossPressed as void Function()?,
                  child: Container(
                    height: 15.toHeight,
                    width: 15.toHeight,
                    decoration: const BoxDecoration(
                        color: Colors.black, shape: BoxShape.circle),
                    child: Icon(
                      Icons.close,
                      size: 15.toHeight,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.toHeight),
          SizedBox(
            width: 80.toWidth,
            child: Text(
              groupContact?.contact?.tags != null &&
                      groupContact?.contact?.tags!['name'] != null
                  ? groupContact?.contact?.tags!['name']
                  : (groupContact?.contact?.atSign?.substring(1) ??
                      groupContact?.group?.groupName?.substring(0))!,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15.toFont),
            ),
          ),
          SizedBox(height: 10.toHeight),
          SizedBox(
            width: 60.toWidth,
            child: Text(
              (groupContact?.contact?.atSign ??
                  groupContact?.group?.groupName)!,
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
