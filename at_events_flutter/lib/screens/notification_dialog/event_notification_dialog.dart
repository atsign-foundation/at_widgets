// ignore: must_be_immutable
import 'dart:typed_data';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/at_contact.dart';
import 'package:at_events_flutter/common_components/bottom_sheet.dart';
import 'package:at_events_flutter/common_components/contacts_initials.dart';
import 'package:at_events_flutter/common_components/custom_button.dart';
import 'package:at_events_flutter/common_components/event_time_selection.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_events_flutter/services/contact_service.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
import 'package:at_events_flutter/services/event_services.dart';
import 'package:at_events_flutter/utils/colors.dart';
import 'package:at_events_flutter/utils/constants.dart';
import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:at_events_flutter/utils/texts.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EventNotificationDialog extends StatefulWidget {
  String? event, invitedPeopleCount, timeAndDate, userName;
  final EventNotificationModel? eventData;
  bool showMembersCount;

  int? minutes;
  EventNotificationDialog(
      {required this.eventData,
      this.event,
      this.invitedPeopleCount,
      this.timeAndDate,
      this.userName,
      this.showMembersCount = false});

  @override
  _EventNotificationDialogState createState() =>
      _EventNotificationDialogState();
}

class _EventNotificationDialogState extends State<EventNotificationDialog> {
  int? minutes;
  EventNotificationModel? concurrentEvent;
  bool? isOverlap = false, loading = false, result;
  AtContact? contact;
  Uint8List? image;
  String? locationUserImageToShow;

  @override
  void initState() {
    if (widget.eventData != null) checkForEventOverlap();
    getEventCreator();
    super.initState();

    if (widget.eventData != null) {
      widget.showMembersCount = true;
    }
  }

  // ignore: always_declare_return_types
  getEventCreator() async {
    var contact = await getAtSignDetails(widget.eventData != null
        ? widget.eventData!.atsignCreator
        : locationUserImageToShow);
    // ignore: unnecessary_null_comparison
    if (contact != null) {
      if (contact.tags != null && contact.tags!['image'] != null) {
        List<int>? intList = contact.tags!['image'].cast<int>();
        setState(() {
          image = Uint8List.fromList(intList!);
        });
      }
    }
  }

  void checkForEventOverlap() {
    var allEventsExcludingCurrentEvent = <EventKeyLocationModel>[];
    var allSavedEvents = EventKeyStreamService().allEventNotifications;
    dynamic overlapData = [];

    allSavedEvents.forEach((event) {
      var keyMicrosecondId = event.key!.split('createevent-')[1].split('@')[0];
      if (!event.key!.contains(keyMicrosecondId)) {
        allEventsExcludingCurrentEvent.add(event);
      }
    });
    overlapData = EventService().isEventTimeSlotOverlap(
        allEventsExcludingCurrentEvent
            .map((e) => e.eventNotificationModel)
            .toList(),
        widget.eventData);
    isOverlap = overlapData[0];
    if (isOverlap != null) {
      if (isOverlap == true) concurrentEvent = overlapData[1];
    }
  }

  @override
  Widget build(BuildContext context) {
    print('EventNotificationDialog called');
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
                      '${widget.eventData!.atsignCreator} wants to share an event with you. Are you sure you want to join and share your location with the group?',
                      style: CustomTextStyles().grey16,
                      textAlign: TextAlign.center),
                  SizedBox(height: 30),
                  Stack(
                    children: [
                      image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.toFont)),
                              child: Image.memory(
                                image!,
                                width: 50.toFont,
                                height: 50.toFont,
                                fit: BoxFit.fill,
                              ),
                            )
                          : ContactInitial(
                              initials: widget.eventData != null
                                  ? widget.eventData!.atsignCreator
                                  : locationUserImageToShow,
                              size: 60,
                            ),
                      widget.showMembersCount
                          ? Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 30.toFont,
                                height: 30.toFont,
                                decoration: BoxDecoration(
                                  color: AllColors().BLUE,
                                  borderRadius:
                                      BorderRadius.circular(20.toFont),
                                ),
                                child: Center(
                                    child: Text(
                                  '+${widget.eventData!.group!.members!.length}',
                                  style: CustomTextStyles().black10,
                                )),
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                  SizedBox(height: widget.eventData != null ? 10.toHeight : 0),
                  widget.eventData != null
                      ? Text(
                          widget.eventData!.title!,
                          style: CustomTextStyles().black18,
                          textAlign: TextAlign.center,
                        )
                      : SizedBox(),
                  SizedBox(height: widget.eventData != null ? 5.toHeight : 0),
                  widget.eventData != null
                      ? Text(
                          (widget.eventData!.group!.members!.length == 1)
                              ? '${widget.eventData!.group!.members!.length} person invited'
                              : '${widget.eventData!.group!.members!.length} people invited',
                          style: CustomTextStyles().grey14)
                      : SizedBox(),
                  SizedBox(height: widget.eventData != null ? 10.toHeight : 0),
                  widget.eventData != null
                      ? Text(
                          '${timeOfDayToString(widget.eventData!.event!.startTime!)} on ${dateToString(widget.eventData!.event!.date!)}',
                          style: CustomTextStyles().black14)
                      : SizedBox(),
                  isOverlap! ? SizedBox(height: 10.toHeight) : SizedBox(),
                  isOverlap! ? Divider(height: 2) : SizedBox(),
                  SizedBox(height: 10.toHeight),
                  isOverlap!
                      ? Text(
                          'You already have an event scheduled during this hour. Are you sure you want to accept another?',
                          textAlign: TextAlign.center,
                          style: CustomTextStyles().grey16,
                        )
                      : SizedBox(),
                  SizedBox(height: 10.toHeight),
                  isOverlap!
                      ? Text(concurrentEvent!.title!,
                          style: CustomTextStyles().black18)
                      : SizedBox(),
                  SizedBox(height: 5.toHeight),
                  SizedBox(height: 10.toHeight),
                  isOverlap!
                      ? Text(
                          '${timeOfDayToString(concurrentEvent!.event!.startTime!)} on ${dateToString(concurrentEvent!.event!.date!)}',
                          style: CustomTextStyles().black14)
                      : SizedBox(),
                  SizedBox(height: 10.toHeight),
                  loading!
                      ? CircularProgressIndicator()
                      : CustomButton(
                          onTap: () => () async {
                            startLoading();

                            bottomSheet(
                                context,
                                EventTimeSelection(
                                    eventNotificationModel: widget.eventData,
                                    title: AllText().LOC_START_TIME_TITLE,
                                    isStartTime: true,
                                    options: MixedConstants.startTimeOptions,
                                    onSelectionChanged: (dynamic startTime) {
                                      widget.eventData!.group!.members!
                                          .forEach((groupMember) {
                                        if (groupMember.atSign ==
                                            AtEventNotificationListener()
                                                .currentAtSign) {
                                          groupMember.tags!['shareFrom'] =
                                              startTime.toString();
                                        }
                                      });

                                      bottomSheet(
                                          context,
                                          EventTimeSelection(
                                            eventNotificationModel:
                                                widget.eventData,
                                            title: AllText().LOC_END_TIME_TITLE,
                                            options:
                                                MixedConstants.endTimeOptions,
                                            onSelectionChanged:
                                                (dynamic endTime) async {
                                              widget.eventData!.group!.members!
                                                  .forEach((groupMember) {
                                                if (groupMember.atSign ==
                                                    AtEventNotificationListener()
                                                        .currentAtSign) {
                                                  groupMember.tags!['shareTo'] =
                                                      endTime.toString();
                                                }
                                              });

                                              /// For inner bottomsheet
                                              Navigator.of(context).pop();

                                              /// For outer bottomsheet
                                              Navigator.of(context).pop();

                                              // updateEvent(widget.eventData);
                                              await EventKeyStreamService()
                                                  .actionOnEvent(
                                                      widget.eventData!,
                                                      ATKEY_TYPE_ENUM
                                                          .ACKNOWLEDGEEVENT,
                                                      isAccepted: true,
                                                      isSharing: true,
                                                      isExited: false);

                                              stopLoading();

                                              /// For dialog box
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          400);
                                    }),
                                400);
                          }(),
                          bgColor: AllColors().Black,
                          width: 164,
                          height: 48.toHeight,
                          child: Text('Yes',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  fontSize: 15.toFont)),
                        ),
                  SizedBox(height: 10.toHeight),
                  loading!
                      ? SizedBox()
                      : InkWell(
                          onTap: () async {
                            startLoading();
                            await EventKeyStreamService().actionOnEvent(
                                widget.eventData!,
                                ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT,
                                isAccepted: false,
                                isExited: true);

                            /// For dialog box
                            Navigator.of(context).pop();

                            // providerCallback<EventProvider>(context,
                            //     task: (t) => t.actionOnEvent(widget.eventData,
                            //         ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT,
                            //         isAccepted: false, isExited: true),
                            //     text: 'Sending request to reject event',
                            //     taskName: (t) => t.UPDATE_EVENTS,
                            //     showDialog: false,
                            //     onError: (t) {
                            //       Navigator.of(context).pop();
                            //       CustomToast().show(
                            //           'Something went wrong! ${t.toString()}',
                            //           NavService.navKey.currentContext);
                            //     },
                            //     onSuccess: (t) {
                            //       Navigator.of(context).pop();
                            //       CustomToast().show(
                            //           'Request to reject event is submitted',
                            //           context);
                            //     });
                            stopLoading();
                          },
                          child: Text(
                            'No',
                            style: CustomTextStyles().black14,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void startLoading() {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
  }

  void stopLoading() {
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
}

void updateEvent(
  EventNotificationModel eventData, {
  bool isAccepted = true,
  bool isSharing = true,
  bool isExited = false,
}) {
  EventKeyStreamService().actionOnEvent(
      eventData, ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT,
      isAccepted: true, isSharing: true, isExited: false);

  ///
  // providerCallback<EventProvider>(NavService.navKey.currentContext,
  //     task: (t) => t.actionOnEvent(eventData, ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT,
  //         isAccepted: true, isSharing: true, isExited: false),
  //     taskName: (t) => t.UPDATE_EVENTS,
  //     text: 'Sending request to accept event',
  //     showDialog: false,
  //     onError: (t) {
  //       CustomToast().show('Something went wrong! ${t.toString()}',
  //           NavService.navKey.currentContext);
  //     },
  //     onSuccess: (t) {
  //       Navigator.of(NavService.navKey.currentContext).pop();
  //       Navigator.of(NavService.navKey.currentContext).pop();
  //       CustomToast().show('Request to accept event is submitted',
  //           NavService.navKey.currentContext);
  //     });
}
