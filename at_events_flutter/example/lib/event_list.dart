import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:at_events_flutter/common_components/bottom_sheet.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/screens/create_event.dart';
import 'package:at_events_flutter/utils/init_events_service.dart';
import 'package:flutter/material.dart';

class EventList extends StatefulWidget {
  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  GlobalKey<ScaffoldState> scaffoldKey;
  List<EventNotificationModel> events = [];
  bool isEventAvailable = false;

  @override
  void initState() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    super.initState();
    getAllEvent();
  }

  getAllEvent() async {
    events = await getEvents();
    if (events.length > 0) {
      setState(() {
        isEventAvailable = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build called');
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Event list'),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          !isEventAvailable
              ? Center(
                  child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: CircularProgressIndicator(),
                ))
              : Expanded(
                  child: Container(
                      padding: EdgeInsets.all(15),
                      child: StreamBuilder(
                        stream: EventService().eventListStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            if (snapshot.hasData) {
                              events = snapshot.data;
                              return ListView.separated(
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return InkWell(
                                      onLongPress: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return alertDialog(
                                                events[index], 'Delete event??',
                                                isDelete: true);
                                          },
                                        );
                                      },
                                      onTap: () {
                                        if (events[index].atsignCreator ==
                                            EventService()
                                                .atClientInstance
                                                .currentAtSign)
                                          bottomSheet(
                                              context,
                                              CreateEvent(
                                                isUpdate: true,
                                                eventData: events[index],
                                                onEventSaved:
                                                    (EventNotificationModel
                                                        event) {
                                                  EventService()
                                                      .onUpdatedEventReceived(
                                                          event);
                                                },
                                              ),
                                              MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.9);
                                        else
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return alertDialog(events[index],
                                                  'Accept event invite??');
                                            },
                                          );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('${events[index].title}'),
                                            EventService().currentAtSign ==
                                                    events[index].atsignCreator
                                                ? SizedBox()
                                                : getActionString(events[index])
                                                            .length >
                                                        0
                                                    ? Text(
                                                        '${getActionString(events[index])}',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )
                                                    : SizedBox(),
                                            SizedBox(height: 5),
                                            Text(
                                                'creator:${events[index].atsignCreator}'),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Divider(
                                      color: Colors.grey,
                                    );
                                  },
                                  itemCount: events.length);
                            } else {
                              return Center(
                                child: Text('something went wrong'),
                              );
                            }
                          } else {
                            return SizedBox();
                          }
                        },
                      )),
                )
        ],
      ),
    );
  }

  Widget alertDialog(EventNotificationModel eventData, String heading,
      {bool isDelete = false}) {
    return AlertDialog(
      title: Text(eventData.title),
      content: Text(heading),
      actions: [
        FlatButton(
          child: Text("No"),
          onPressed: () async {
            if (!isDelete) {
              var result = await sendEventAcknowledgement(eventData,
                  isAccepted: false, isSharing: false, isExited: true);
              if (result != null && result) {
                Navigator.of(context).pop();
              }
            } else
              Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("Yes"),
          onPressed: () async {
            if (isDelete) {
              bool result = await deleteEvent(eventData.key);
              if (result != null && result) {
                Navigator.of(context).pop();
              }
            } else {
              var result = await sendEventAcknowledgement(eventData,
                  isAccepted: true, isSharing: true, isExited: false);
              if (result != null && result) {
                Navigator.of(context).pop();
              }
            }
          },
        ),
      ],
    );
  }

  String getActionString(EventNotificationModel event) {
    String label = 'Action required';
    String currentAtsign = EventService().currentAtSign;

    if (event.group.members.length < 1) return '';

    event.group.members.forEach((member) {
      if (member.tags['isAccepted'] != null &&
          member.tags['isAccepted'] == true &&
          member.atSign == currentAtsign) {
        label = 'Accepted';
      }

      if (member.tags['isExited'] != null &&
          member.tags['isExited'] == true &&
          member.atSign == currentAtsign) {
        label = 'Declined';
      }
    });

    return label;
  }
}
