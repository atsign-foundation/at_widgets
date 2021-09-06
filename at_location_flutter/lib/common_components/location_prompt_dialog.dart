import 'package:at_common_flutter/at_common_flutter.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/at_location_notification_listener.dart';
import 'package:at_location_flutter/service/request_location_service.dart';
import 'package:at_location_flutter/service/sharing_location_service.dart';
import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:at_location_flutter/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

import 'custom_toast.dart';

Future<void> locationPromptDialog(
    {String? text,
    String? yesText,
    String? noText,
    required bool isShareLocationData,
    required bool isRequestLocationData,
    bool onlyText = false,
    LocationNotificationModel? locationNotificationModel}) {
  var value = showDialog<void>(
    context: AtLocationNotificationListener().navKey.currentContext!,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return LocationPrompt(
          text: text,
          yesText: yesText,
          noText: noText,
          onlyText: onlyText,
          isShareLocationData: isShareLocationData,
          isRequestLocationData: isRequestLocationData,
          locationNotificationModel: locationNotificationModel);
    },
  );
  return value;
}

class LocationPrompt extends StatefulWidget {
  final String? text, yesText, noText;
  final bool isShareLocationData, isRequestLocationData, onlyText;
  final LocationNotificationModel? locationNotificationModel;

  LocationPrompt(
      {this.text,
      this.yesText,
      this.noText,
      this.onlyText = false,
      required this.isShareLocationData,
      required this.isRequestLocationData,
      this.locationNotificationModel});

  @override
  _LocationPromptState createState() => _LocationPromptState();
}

class _LocationPromptState extends State<LocationPrompt> {
  late bool loading;

  @override
  void initState() {
    loading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig().screenWidth * 0.8,
      child: AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(15, 30, 15, 20),
        content: SingleChildScrollView(
          child: Container(
            child: widget.onlyText
                ? Column(
                    children: [
                      Text(
                        widget.text ?? '...',
                        style: CustomTextStyles().grey16,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      CustomButton(
                        onPressed: () => Navigator.of(context).pop(),
                        buttonText: 'Okay!',
                        fontColor: Colors.white,
                        width: 100.toWidth,
                        height: 48.toHeight,
                      )
                    ],
                  )
                : Column(
                    children: <Widget>[
                      Text(
                        widget.text!,
                        style: CustomTextStyles().grey16,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      loading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : CustomButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });

                                if (widget.isShareLocationData) {
                                  await updateShareLocation();
                                } else if (widget.isRequestLocationData) {
                                  await updateRequestLocation();
                                }

                                if (mounted) {
                                  setState(() {
                                    loading = false;
                                  });
                                }

                                Navigator.of(AtLocationNotificationListener()
                                        .navKey
                                        .currentContext!)
                                    .pop();
                              },
                              buttonText: widget.yesText ?? 'Yes!',
                              fontColor: Colors.white,
                              width: 164.toWidth,
                              height: 48.toHeight,
                            ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () async {
                          if (widget.isShareLocationData) {
                            CustomToast().show('Update cancelled', context);
                          } else if (widget.isRequestLocationData) {
                            CustomToast().show('Prompt cancelled', context);
                          }
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          widget.noText ?? 'No!',
                          style: CustomTextStyles().black14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> updateShareLocation() async {
    var update = await SharingLocationService()
        .updateWithShareLocationAcknowledge(widget.locationNotificationModel!,
            rePrompt: widget.locationNotificationModel!.rePrompt);

    if (update) {
      CustomToast().show(
          'Share Location Request sent to ${widget.locationNotificationModel!.receiver}',
          context);
    } else {
      CustomToast().show(
          'Something went wrong for ${widget.locationNotificationModel!.receiver}',
          context,
          bgColor: AllColors().RED);
    }
  }

  Future<void> updateRequestLocation() async {
    var update = await RequestLocationService()
        .updateWithRequestLocationAcknowledge(widget.locationNotificationModel!,
            rePrompt: widget.locationNotificationModel!.rePrompt);

    if (update) {
      CustomToast().show(
          'Prompted again to ${widget.locationNotificationModel!.atsignCreator}',
          context);
    } else {
      CustomToast().show(
          'Something went wrong for ${widget.locationNotificationModel!.atsignCreator}',
          context,
          bgColor: AllColors().RED);
    }
  }
}
