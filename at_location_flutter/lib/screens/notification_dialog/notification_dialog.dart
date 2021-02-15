import 'dart:typed_data';
import 'package:at_common_flutter/widgets/custom_button.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_location_flutter/common_components/bottom_sheet.dart';
import 'package:at_location_flutter/common_components/contacts_initial.dart';
import 'package:at_location_flutter/common_components/text_tile_repeater.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/request_location_service.dart';
import 'package:at_location_flutter/service/sharing_location_service.dart';
import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:at_location_flutter/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:at_common_flutter/services/size_config.dart';

class NotificationDialog extends StatefulWidget {
  final String userName;
  final LocationNotificationModel locationData;
  final bool showMembersCount;

  int minutes;
  NotificationDialog(
      {this.locationData, this.userName, this.showMembersCount = false});

  @override
  _NotificationDialogState createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  int minutes;
  AtContact contact;
  Uint8List image;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(10, 20, 5, 10),
        content: Container(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                      ((!widget.locationData.isRequest)
                          ? '${widget.userName} wants to share their location with you. Are you sure you want to accept their location?'
                          : '${widget.userName} wants you to share your location? Are you sure you want to share?'),
                      style: CustomTextStyles().grey16,
                      textAlign: TextAlign.center),
                  SizedBox(height: 30),
                  Stack(
                    children: [
                      image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              child: Image.memory(
                                image,
                                width: 50,
                                height: 50,
                                fit: BoxFit.fill,
                              ),
                            )
                          : ContactInitial(
                              initials: widget.locationData.atsignCreator
                                  .substring(1, 3),
                              size: 60,
                            ),
                      widget.showMembersCount
                          ? Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AllColors().BLUE,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                    child: Text(
                                  '+10',
                                  style: CustomTextStyles().black10,
                                )),
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                  SizedBox(height: 10.toHeight),
                  CustomButton(
                    onPressed: () => () async {
                      ((!widget.locationData.isRequest)
                          ? {
                              print('accept share location'),
                              SharingLocationService()
                                  .shareLocationAcknowledgment(
                                      widget.locationData, true),
                              Navigator.of(context).pop(),
                            }
                          : {
                              Navigator.of(context).pop(),
                              timeSelect(context),
                            });
                    }(),
                    buttonText: 'Yes',
                    buttonColor: AllColors().Black,
                    fontColor: AllColors().WHITE,
                    width: 164.toWidth,
                    height: 48.toHeight,
                  ),
                  SizedBox(height: 5),
                  CustomButton(
                    onPressed: () => () async {
                      ((!widget.locationData.isRequest)
                          ? {
                              print('accept share location'),
                              SharingLocationService()
                                  .shareLocationAcknowledgment(
                                      widget.locationData, false),
                              Navigator.of(context).pop(),
                            }
                          : {
                              RequestLocationService()
                                  .requestLocationAcknowledgment(
                                      widget.locationData, false),
                              Navigator.of(context).pop(),
                            });
                    }(),
                    buttonText: 'No',
                    buttonColor: AllColors().WHITE,
                    fontColor: AllColors().Black,
                    width: 164.toWidth,
                    height: 48.toHeight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  timeSelect(BuildContext context) {
    int result;
    bottomSheet(
        context,
        TextTileRepeater(
          title: 'How long do you want to share your location for ?',
          options: ['30 mins', '2 hours', '24 hours', 'Until turned off'],
          onChanged: (value) {
            print('$result');
            result = (value == '30 mins'
                ? 30
                : (value == '2 hours'
                    ? (2 * 60)
                    : (value == '24 hours' ? (24 * 60) : null)));
            print('hours = $result');
          },
        ),
        350, onSheetCLosed: () {
      RequestLocationService().requestLocationAcknowledgment(
          widget.locationData, true,
          minutes: result);
      return result;
    });
  }
}
