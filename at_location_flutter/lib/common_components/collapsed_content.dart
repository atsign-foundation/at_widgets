import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_location_flutter/location_modal/hybrid_model.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/home_screen_service.dart';
import 'package:at_location_flutter/service/location_service.dart';
import 'package:at_location_flutter/service/request_location_service.dart';
import 'package:at_location_flutter/service/send_location_notification.dart';
import 'package:at_location_flutter/service/sharing_location_service.dart';
import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:at_location_flutter/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

import 'custom_toast.dart';
import 'display_tile.dart';
import 'draggable_symbol.dart';
import 'loading_widget.dart';
import 'package:at_common_flutter/services/size_config.dart';

// ignore: must_be_immutable
class CollapsedContent extends StatefulWidget {
  bool expanded;
  LocationNotificationModel? userListenerKeyword;
  AtClientImpl? atClientInstance;
  String? currentAtSign;
  CollapsedContent(this.expanded, this.atClientInstance,
      {Key? key, this.userListenerKeyword, required this.currentAtSign});
  @override
  _CollapsedContentState createState() => _CollapsedContentState();
}

class _CollapsedContentState extends State<CollapsedContent> {
  late bool isSharing;
  bool locationAvailable = false;
  @override
  void initState() {
    super.initState();
    isSharing = widget.userListenerKeyword!.isSharing;

    LocationService().atHybridUsersStream.listen((List<HybridModel?> e) {
      setState(() {
        locationAvailable = false;
      });
      for (int i = 0; i < e.length; i++) {
        if (e[i]!.displayName == widget.userListenerKeyword!.atsignCreator) {
          setState(() {
            locationAvailable = true;
          });
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.userListenerKeyword!.atsignCreator!.contains('@')) {
      widget.userListenerKeyword!.atsignCreator =
          '@' + widget.userListenerKeyword!.atsignCreator!;
    }

    if (!widget.currentAtSign!.contains('@')) {
      widget.currentAtSign = '@' + widget.currentAtSign!;
    }

    bool amICreator =
        widget.userListenerKeyword!.atsignCreator == widget.currentAtSign;
    DateTime? to = widget.userListenerKeyword!.to;
    String time;
    if (to != null) {
      time =
          'until ${timeOfDayToString(TimeOfDay.fromDateTime(widget.userListenerKeyword!.to!))} today';
    } else {
      time = '';
    }

    return Container(
        height: widget.expanded ? 431.toHeight : 205.toHeight,
        padding: const EdgeInsets.fromLTRB(15, 3, 15, 0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
          color: Theme.of(context).brightness == Brightness.light
              ? AllColors().WHITE
              : AllColors().Black,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AllColors().DARK_GREY,
              blurRadius: 10.0,
              spreadRadius: 1.0,
              offset: const Offset(0.0, 0.0),
            )
          ],
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              amICreator
                  ? DraggableSymbol()
                  : const SizedBox(
                      height: 10,
                    ),
              const SizedBox(
                height: 3,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        DisplayTile(
                            title: amICreator
                                ? widget.userListenerKeyword!.receiver
                                : widget.userListenerKeyword!.atsignCreator,
                            showName: true,
                            atsignCreator: amICreator
                                ? widget.userListenerKeyword!.receiver
                                : widget.userListenerKeyword!.atsignCreator,
                            subTitle: amICreator
                                ? widget.userListenerKeyword!.receiver
                                : widget.userListenerKeyword!.atsignCreator),
                        Text(
                          amICreator
                              ? 'This user does not share their location'
                              : locationAvailable
                                  ? ('Sharing their location $time')
                                  : ("This user's location sharing is turned off"),
                          style: ((amICreator) || locationAvailable)
                              ? CustomTextStyles().grey12
                              : CustomTextStyles().red12,
                        ),
                        amICreator
                            ? Text(
                                'Sharing my location $time',
                                style: CustomTextStyles().black12,
                              )
                            : const SizedBox()
                      ],
                    ),
                  ),
                  Transform.rotate(
                    angle: 5.8,
                    child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: AllColors().ORANGE,
                      ),
                      child: Icon(
                        Icons.send_outlined,
                        color: AllColors().WHITE,
                        size: 25,
                      ),
                    ),
                  )
                ],
              ),
              widget.expanded
                  ? Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Divider(),
                          amICreator
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Share my Location',
                                      style: CustomTextStyles().darkGrey16,
                                    ),
                                    Switch(
                                        value: isSharing,
                                        onChanged: (widget
                                                    .userListenerKeyword!.to ==
                                                null)
                                            ? (bool value) async =>
                                                await removePerson()
                                            : (bool value) async {
                                                LoadingDialog().show();
                                                try {
                                                  late bool result;
                                                  if (widget
                                                      .userListenerKeyword!.key!
                                                      .contains(
                                                          'sharelocation')) {
                                                    result = await SharingLocationService()
                                                        .updateWithShareLocationAcknowledge(
                                                            widget
                                                                .userListenerKeyword!,
                                                            isSharing: value);
                                                  } else if (widget
                                                      .userListenerKeyword!.key!
                                                      .contains(
                                                          'requestlocation')) {
                                                    result = await RequestLocationService()
                                                        .requestLocationAcknowledgment(
                                                            widget
                                                                .userListenerKeyword!,
                                                            true,
                                                            isSharing: value);
                                                  }
                                                  if (result) {
                                                    if (!value) {
                                                      await SendLocationNotification()
                                                          .sendNull(widget
                                                              .userListenerKeyword!);
                                                    }
                                                    setState(() {
                                                      isSharing = value;
                                                    });
                                                  } else {
                                                    CustomToast().show(
                                                        'Something went wrong, try again.',
                                                        context);
                                                  }
                                                  LoadingDialog().hide();
                                                } catch (e) {
                                                  print(e);
                                                  CustomToast().show(
                                                      'Something went wrong , please try again.',
                                                      context);
                                                  LoadingDialog().hide();
                                                }
                                              })
                                  ],
                                )
                              : const SizedBox(),
                          amICreator ? const Divider() : const SizedBox(),
                          amICreator
                              ? Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      try {
                                        bool? result =
                                            await RequestLocationService()
                                                .sendRequestLocationEvent(widget
                                                    .userListenerKeyword!
                                                    .receiver);
                                        if (result == true) {
                                          CustomToast().show(
                                              'Request Location sent', context);
                                        } else {
                                          CustomToast().show(
                                              'Something went wrong, try again.',
                                              context);
                                        }
                                      } catch (e) {
                                        print(e);
                                        CustomToast().show(
                                            'Something went wrong, try again.',
                                            context);
                                      }
                                    },
                                    child: Text(
                                      'Request Location',
                                      style: CustomTextStyles().darkGrey16,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                          (amICreator) ? const Divider() : const SizedBox(),
                          (amICreator)
                              ? Expanded(
                                  child: InkWell(
                                    onTap: () async => await removePerson(),
                                    child: Text(
                                      'Remove Person',
                                      style: CustomTextStyles().orange16,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    )
                  : const SizedBox(
                      height: 2,
                    )
            ]));
  }

  // ignore: always_declare_return_types
  removePerson() async {
    LoadingDialog().show();
    try {
      late bool result;
      if (widget.userListenerKeyword!.key!.contains('sharelocation')) {
        result = await SharingLocationService()
            .deleteKey(widget.userListenerKeyword!);
      } else if (widget.userListenerKeyword!.key!.contains('requestlocation')) {
        result = await RequestLocationService()
            .sendDeleteAck(widget.userListenerKeyword!);
      }
      if (result) {
        await SendLocationNotification().sendNull(widget.userListenerKeyword!);
        LoadingDialog().hide();

        Navigator.pop(context);
      } else {
        LoadingDialog().hide();

        CustomToast().show('Something went wrong, try again.', context);
      }
    } catch (e) {
      print(e);
      CustomToast().show('something went wrong , please try again.', context);
      LoadingDialog().hide();
    }
  }

  Widget participants(Function() onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: InkWell(
        onTap: onTap,
        child: Text(
          'See Participants',
          style: CustomTextStyles().orange14,
        ),
      ),
    );
  }
}
