import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:at_events_flutter/common_components/bottom_sheet.dart';
import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/screens/create_event.dart';
import 'package:at_events_flutter/screens/notification_dialog/event_notification_dialog.dart';
import 'package:at_events_flutter/services/event_key_stream_service.dart';
import 'package:at_events_flutter/utils/init_events_service.dart';
import 'package:at_events_flutter/common_components/display_tile.dart';
import 'package:at_events_flutter_example/client_sdk_service.dart';
import 'package:at_common_flutter/services/size_config.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class EventList extends StatefulWidget {
  List<EventKeyLocationModel> events;
  EventList(this.events);
  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  GlobalKey<ScaffoldState> scaffoldKey;
  // List<EventKeyLocationModel> events = [];

  @override
  void initState() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    super.initState();
    getAllEvent();
  }

  void getAllEvent() async {}

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Event list'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          // Text('Coming soon')
          ListView.separated(
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    onEventModelTap(widget.events[index].eventNotificationModel,
                        widget.events[index].haveResponded);
                  },
                  child: DisplayTile(
                    atsignCreator: widget
                        .events[index].eventNotificationModel.atsignCreator,
                    number: widget.events[index].eventNotificationModel.group
                        .members.length,
                    title: 'Event - ' +
                        widget.events[index].eventNotificationModel.title,
                    subTitle: getSubTitle(
                        widget.events[index].eventNotificationModel),
                    semiTitle: getSemiTitle(
                        widget.events[index].eventNotificationModel,
                        widget.events[index].haveResponded),
                    showRetry: calculateShowRetry(widget.events[index]),
                    onRetryTapped: () {
                      onEventModelTap(
                          widget.events[index].eventNotificationModel, false);
                    },
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  color: Colors.grey,
                );
              },
              itemCount: widget.events.length),
    );
  }

  Widget alertDialog(EventNotificationModel eventData, String heading,
      {bool isDelete = false}) {
    return AlertDialog(
      title: Text(eventData.title),
      content: Text(heading),
      actions: [
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
          ),
          onPressed: () async {
            if (!isDelete) {
              // var result = await EventService().sendEventAcknowledgement(
              //     eventData,
              //     isAccepted: false,
              //     isSharing: false,
              //     isExited: true);
              // if (result != null && result) {
              //   Navigator.of(context).pop();
              // }
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Text(
            'No',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () async {
            if (isDelete) {
              var result = await deleteEvent(eventData.key);
              if (result != null && result) {
                Navigator.of(context).pop();
              }
            } else {
              // var result = await EventService().sendEventAcknowledgement(
              //     eventData,
              //     isAccepted: true,
              //     isSharing: true,
              //     isExited: false);
              // if (result != null && result) {
              //   Navigator.of(context).pop();
              // }
            }
          },
          child: Text('Yes', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  bool isActionRequired(EventNotificationModel event) {
    if (event.isCancelled) return true;

    var isRequired = true;
    var currentAtsign = ClientSdkService.getInstance()
        .atClientServiceInstance
        .atClient
        .currentAtSign;

    if (event.group.members.isEmpty) return true;

    event.group.members.forEach((member) {
      if (member.atSign[0] != '@') member.atSign = '@' + member.atSign;
      if (currentAtsign[0] != '@') currentAtsign = '@' + currentAtsign;

      if ((member.tags['isAccepted'] != null &&
              member.tags['isAccepted'] == true) &&
          member.tags['isExited'] == false &&
          member.atSign.toLowerCase() == currentAtsign.toLowerCase()) {
        isRequired = false;
      }
    });

    if (event.atsignCreator == currentAtsign) isRequired = false;

    return isRequired;
  }

  String getActionString(EventNotificationModel event, bool haveResponded) {
    if (event.isCancelled) return 'Cancelled';
    var label = 'Action required';
    var currentAtsign = ClientSdkService.getInstance()
        .atClientServiceInstance
        .atClient
        .currentAtSign;

    if (event.group.members.isEmpty) return '';

    event.group.members.forEach((member) {
      if (member.atSign[0] != '@') member.atSign = '@' + member.atSign;
      if (currentAtsign[0] != '@') currentAtsign = '@' + currentAtsign;

      if (member.tags['isExited'] != null &&
          member.tags['isExited'] == true &&
          member.atSign.toLowerCase() == currentAtsign.toLowerCase()) {
        label = 'Request declined';
      } else if (member.tags['isExited'] != null &&
          member.tags['isExited'] == false &&
          member.tags['isAccepted'] != null &&
          member.tags['isAccepted'] == false &&
          member.atSign.toLowerCase() == currentAtsign.toLowerCase() &&
          haveResponded) {
        label = 'Pending request';
      }
    });

    return label;
  }

  String getSubTitle(EventNotificationModel _event) {
    return _event.event != null
        ? _event.event.date != null
            ? 'Event on ${dateToString(_event.event.date)}'
            : ''
        : '';
  }

  String getSemiTitle(EventNotificationModel _event, bool _haveResponded) {
    return _event.group != null
        ? (isActionRequired(_event))
            ? getActionString(_event, _haveResponded)
            : null
        : 'Action required';
  }

  bool calculateShowRetry(EventKeyLocationModel _eventKeyModel) {
    if ((_eventKeyModel.eventNotificationModel.group != null) &&
        (isActionRequired(_eventKeyModel.eventNotificationModel)) &&
        (_eventKeyModel.haveResponded)) {
      if (getActionString(_eventKeyModel.eventNotificationModel,
              _eventKeyModel.haveResponded) ==
          'Pending request') {
        return true;
      }
      return false;
    }
    return false;
  }

  onEventModelTap(
      EventNotificationModel eventNotificationModel, bool haveResponded) {
    print(
        'isActionRequired(eventNotificationModel) ${isActionRequired(eventNotificationModel)}');
    print(
        'eventNotificationModel.isCancelled ${eventNotificationModel.isCancelled}');
    if (isActionRequired(eventNotificationModel) &&
        !eventNotificationModel.isCancelled) {
      if (haveResponded) {
        print('haveResponded');
        return null;
      }
      print('not haveResponded');
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return EventNotificationDialog(eventData: eventNotificationModel);
        },
      );
    }

    eventNotificationModel.isUpdate = true;

    /// Move to map screen
    // Navigator.push(
    //   NavService.navKey.currentContext,
    //   MaterialPageRoute(
    //     builder: (context) => AtLocationFlutterPlugin(
    //         BackendService.getInstance().atClientServiceInstance.atClient,
    //         allUsersList: LocationNotificationListener().allUsersList,
    //         onEventCancel: () async {
    //       await provider.cancelEvent(eventNotificationModel);
    //     }, onEventExit: (
    //             {bool isExited,
    //             bool isSharing,
    //             ATKEY_TYPE_ENUM keyType,
    //             EventNotificationModel eventData}) async {
    //       bool isNullSent = false;
    //       var result = await provider.actionOnEvent(
    //         eventData != null ? eventData : eventNotificationModel,
    //         keyType,
    //         isExited: isExited,
    //         isSharing: isSharing,
    //       );

    //       bool isAdmin = BackendService.getInstance()
    //                   .atClientServiceInstance
    //                   .atClient
    //                   .currentAtSign ==
    //               eventNotificationModel.atsignCreator
    //           ? true
    //           : false;
    //       LocationNotificationModel locationNotificationModel =
    //           LocationNotificationModel()
    //             ..key = eventNotificationModel.key
    //             ..receiver = isAdmin
    //                 ? eventNotificationModel.group.members.elementAt(0).atSign
    //                 : eventNotificationModel.atsignCreator
    //             ..atsignCreator = !isAdmin
    //                 ? eventNotificationModel.group.members.elementAt(0).atSign
    //                 : eventNotificationModel.atsignCreator;
    //       if (isSharing != null) {
    //         if (!isSharing && result) {
    //           Provider.of<HybridProvider>(NavService.navKey.currentContext,
    //                   listen: false)
    //               .removeLocationSharing(locationNotificationModel.key);
    //         }
    //       }
    //       if ((isExited != null) && (isExited && result)) {
    //         Provider.of<HybridProvider>(NavService.navKey.currentContext,
    //                 listen: false)
    //             .removeLocationSharing(locationNotificationModel.key);
    //       }

    //       return result;
    //     }, onEventUpdate: (EventNotificationModel eventData) {
    //       provider.mapUpdatedEventDataToWidget(eventData);
    //     }, eventListenerKeyword: eventNotificationModel),
    //   ),
    // );
  }
}
