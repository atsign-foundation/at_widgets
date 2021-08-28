import 'package:at_common_flutter/services/size_config.dart';
import 'package:at_contact/src/model/at_contact.dart';
import 'package:at_events_flutter/common_components/bottom_sheet.dart';
import 'package:at_events_flutter/common_components/custom_toast.dart';
import 'package:at_events_flutter/common_components/display_tile.dart';
import 'package:at_events_flutter/common_components/draggable_symbol.dart';
import 'package:at_events_flutter/common_components/loading_widget.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/screens/create_event.dart';
import 'package:at_events_flutter/services/at_event_notification_listener.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
import 'package:at_events_flutter/utils/colors.dart';
import 'package:at_events_flutter/utils/text_styles.dart';
import 'package:flutter/material.dart';

import 'participants.dart';

Widget eventsCollapsedContent(EventNotificationModel eventListenerKeyword) {
  bool? isExited = false;

  for (AtContact groupMember in eventListenerKeyword.group!.members!) {
    if (groupMember.atSign == AtEventNotificationListener().atClientInstance!.currentAtSign) {
      isExited = groupMember.tags!['isExited'];
    }
  }

  bool? isSharingEvent = false, isAdmin = false;
  String? currentAtSign = AtEventNotificationListener().currentAtSign;
  isAdmin = eventListenerKeyword.atsignCreator == currentAtSign;
  if (isAdmin) {
    if (eventListenerKeyword.isSharing!) isSharingEvent = true;
  } else {
    for (AtContact groupMember in eventListenerKeyword.group!.members!) {
      if (groupMember.atSign == currentAtSign) {
        if (groupMember.tags!['isSharing'] == true) {
          isSharingEvent = true;
        }
      }
    }
  }

  /// TODO: remove extra columns
  return Container(
    height: 431,
    padding: const EdgeInsets.fromLTRB(15, 3, 15, 0),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
      color: AllColors().WHITE,
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
          DraggableSymbol(),
          const SizedBox(height: 3),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        eventListenerKeyword.title!,
                        style: TextStyle(color: AllColors().Black, fontSize: 18.toFont),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    isAdmin
                        ? InkWell(
                            onTap: () {
                              bottomSheet(
                                AtEventNotificationListener().navKey!.currentContext!,
                                CreateEvent(
                                  AtEventNotificationListener().atClientInstance,
                                  isUpdate: true,
                                  eventData: eventListenerKeyword,
                                  onEventSaved: (EventNotificationModel event) {},
                                ),
                                SizeConfig().screenHeight * 0.9,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text('Edit', style: CustomTextStyles().orange16),
                                Icon(Icons.edit, color: AllColors().ORANGE)
                              ],
                            ),
                          )
                        : const SizedBox()
                  ],
                ),
                Text(
                  eventListenerKeyword.atsignCreator!,
                  style: CustomTextStyles().black14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  dateToString(eventListenerKeyword.event!.date!),
                  style: CustomTextStyles().darkGrey14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  '${timeOfDayToString(eventListenerKeyword.event!.startTime!)} - ${timeOfDayToString(eventListenerKeyword.event!.endTime!)}',
                  style: CustomTextStyles().darkGrey14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(),
                DisplayTile(
                  title:
                      '${eventListenerKeyword.atsignCreator} and ${eventListenerKeyword.group!.members!.length} more',
                  atsignCreator: eventListenerKeyword.atsignCreator,
                  semiTitle: (eventListenerKeyword.group!.members!.length == 1)
                      ? '${eventListenerKeyword.group!.members!.length} person'
                      : '${eventListenerKeyword.group!.members!.length} people',
                  number: eventListenerKeyword.group!.members!.length,
                  subTitle:
                      'Share my location from ${timeOfDayToString(eventListenerKeyword.event!.startTime!)} on ${dateToString(eventListenerKeyword.event!.date!)}',
                ),
              ],
            ),
          ),
          // StreamBuilder(
          //     stream: LocationService().atHybridUsersStream,
          //     builder: (context, AsyncSnapshot<List<HybridModel>> snapshot) {
          //       if (snapshot.connectionState == ConnectionState.active) {
          //         if (snapshot.hasError) {
          //           return SeeParticipants(() => null);
          //         } else {
          //           var data = snapshot.data;

          //           ParticipantsData().putData(data);
          //           ParticipantsData()
          //               .putAtsign(LocationService().atsignsAtMonitor);

          //           return SeeParticipants(() => bottomSheet(
          //               context,
          //               Participants(
          //                 true,
          //                 data: data,
          //                 atsign: LocationService().atsignsAtMonitor,
          //               ),
          //               422));
          //         }
          //       } else {
          //         ParticipantsData().putData([]);
          //         ParticipantsData()
          //             .putAtsign(LocationService().atsignsAtMonitor);

          //         return SeeParticipants(() => bottomSheet(
          //             context,
          //             Participants(
          //               false,
          //               atsign: LocationService().atsignsAtMonitor,
          //             ),
          //             422));
          //       }
          //     }),
          ///
          // isSharingEvent = false;
          //           if (widget.isAdmin) {
          //             if (snapshot.data.isSharing) isSharingEvent = true;
          //           } else {
          //             if (snapshot.data != null) {
          //               snapshot.data.group.members.forEach((groupMember) {
          //                 if (groupMember.atSign ==
          //                     BackendService.getInstance()
          //                         .atClientServiceInstance
          //                         .atClient
          //                         .currentAtSign) {
          //                   if (groupMember.tags['isSharing'] == true) {
          //                     isSharingEvent = true;
          //                   }
          //                 }
          //               });
          //             }
          //           }
          // return

          /// Next
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   mainAxisSize: MainAxisSize.min,
          // children: [
          InkWell(
            onTap: () => bottomSheet(AtEventNotificationListener().navKey!.currentContext!, Participants(), 422),
            child: Text(
              'See Participants',
              style: CustomTextStyles().orange14,
            ),
          ),
          const Divider(),
          Flexible(
              child: RichText(
            text: TextSpan(
              text: 'Address: ',
              style: CustomTextStyles().darkGrey16,
              children: <InlineSpan>[
                TextSpan(
                  text: ' ${eventListenerKeyword.venue!.label}',
                  style: CustomTextStyles().darkGrey14,
                )
              ],
            ),
          )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Share Location',
                style: CustomTextStyles().darkGrey16,
              ),
              Switch(
                  value: isSharingEvent!,
                  onChanged: (bool value) async {
                    LoadingDialog().show(text: isAdmin! ? 'Updating data' : 'Sending request to update data');
                    try {
                      // if (isAdmin) {
                      //   LocationService().eventListenerKeyword.isSharing =
                      //       value;
                      // }

                      bool result = await EventKeyStreamService().actionOnEvent(
                        eventListenerKeyword,
                        isAdmin ? ATKEY_TYPE_ENUM.CREATEEVENT : ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT,
                        isSharing: value,
                      );
                      if (result == true) {
                        if (!isAdmin) {
                          CustomToast().show('Request to update data is submitted',
                              AtEventNotificationListener().navKey!.currentContext);
                        }
                      } else {
                        CustomToast().show('something went wrong , please try again.',
                            AtEventNotificationListener().navKey!.currentContext);
                      }
                      LoadingDialog().hide();
                    } catch (e) {
                      print(e);
                      CustomToast().show('something went wrong , please try again.',
                          AtEventNotificationListener().navKey!.currentContext);
                      LoadingDialog().hide();
                    }
                  })
            ],
          ),
          const Divider(),
          isAdmin
              ? const SizedBox()
              : Expanded(
                  child: InkWell(
                    onTap: () async {
                      bool isExited = true;
                      for (AtContact groupMember in eventListenerKeyword.group!.members!) {
                        if (groupMember.atSign == currentAtSign) {
                          if (groupMember.tags!['isExited'] == false) {
                            isExited = false;
                          }
                        }
                      }
                      if (!isExited) {
                        //if member has not exited then only following code will run.
                        LoadingDialog().show();
                        try {
                          await EventKeyStreamService().actionOnEvent(
                            eventListenerKeyword,
                            isAdmin! ? ATKEY_TYPE_ENUM.CREATEEVENT : ATKEY_TYPE_ENUM.ACKNOWLEDGEEVENT,
                            isExited: true,
                          );
                          LoadingDialog().hide();
                          Navigator.of(AtEventNotificationListener().navKey!.currentContext!).pop();
                          CustomToast().show('Request to update data is submitted',
                              AtEventNotificationListener().navKey!.currentContext);
                        } catch (e) {
                          print(e);
                          CustomToast().show('something went wrong , please try again.',
                              AtEventNotificationListener().navKey!.currentContext);
                          LoadingDialog().hide();
                        }
                      }
                    },
                    child: Text(
                      isExited! ? 'Exited' : 'Exit Event',
                      style: CustomTextStyles().orange16,
                    ),
                  ),
                ),
          isAdmin ? const SizedBox() : const Divider(),
          isAdmin
              ? Expanded(
                  child: InkWell(
                    onTap: () async {
                      if (!eventListenerKeyword.isCancelled!) {
                        LoadingDialog().show(text: isAdmin! ? 'Updating data' : 'Sending request to update data');
                        try {
                          // await LocationService().onEventCancel();
                          await EventKeyStreamService().actionOnEvent(
                            eventListenerKeyword,
                            ATKEY_TYPE_ENUM.CREATEEVENT,
                            isCancelled: true,
                          );
                          LoadingDialog().hide();
                          Navigator.of(AtEventNotificationListener().navKey!.currentContext!).pop();
                        } catch (e) {
                          print(e);
                          CustomToast().show('something went wrong , please try again.',
                              AtEventNotificationListener().navKey!.currentContext);
                          LoadingDialog().hide();
                        }
                      }
                    },
                    child: Text(
                      eventListenerKeyword.isCancelled! ? 'Event Cancelled' : 'Cancel Event',
                      style: CustomTextStyles().orange16,
                    ),
                  ),
                )
              : const SizedBox()
          //   ],
          // ),
        ]),
  );
}
