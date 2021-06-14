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

  @override
  void initState() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    super.initState();
    getAllEvent();
  }

  void getAllEvent() async {
    events = await getEvents();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
                padding: EdgeInsets.all(15),
                child: StreamBuilder(
                  stream: EventService().eventListStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        if (snapshot.data.length < 1) {
                          return Center(
                            child: Text('No data found'),
                          );
                        } else {
                          events = snapshot.data;

                          return ListView.separated(
                              itemBuilder: (BuildContext context, int index) {
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
                                            .currentAtSign) {
                                      bottomSheet(
                                          context,
                                          CreateEvent(
                                            isUpdate: true,
                                            eventData: events[index],
                                            onEventSaved:
                                                (EventNotificationModel event) {
                                              EventService()
                                                  .onUpdatedEventReceived(
                                                      event);
                                            },
                                          ),
                                          MediaQuery.of(context).size.height *
                                              0.9);
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return alertDialog(events[index],
                                              'Accept event invite??');
                                        },
                                      );
                                    }
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
                                                    .isNotEmpty
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
                        }
                      } else {
                        return Center(
                          child: Text('something went wrong'),
                        );
                      }
                    } else {
                      return Center(
                          child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: CircularProgressIndicator(),
                      ));
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
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
          ),
          onPressed: () async {
            if (!isDelete) {
              var result = await EventService().sendEventAcknowledgement(
                  eventData,
                  isAccepted: false,
                  isSharing: false,
                  isExited: true);
              if (result != null && result) {
                Navigator.of(context).pop();
              }
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
              var result = await EventService().sendEventAcknowledgement(
                  eventData,
                  isAccepted: true,
                  isSharing: true,
                  isExited: false);
              if (result != null && result) {
                Navigator.of(context).pop();
              }
            }
          },
          child: Text('Yes', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  String getActionString(EventNotificationModel event) {
    var label = 'Action required';
    var currentAtsign = EventService().currentAtSign;

    if (event.group.members.isEmpty) return '';

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
