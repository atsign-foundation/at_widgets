import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:at_events_flutter/common_components/bottom_sheet.dart';
import 'package:at_events_flutter/models/event_notification.dart';
import 'package:at_events_flutter/screens/create_event.dart';
import 'package:at_events_flutter/utils/init_events_service.dart';
import 'package:flutter/material.dart';
import 'client_sdk_service.dart';

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
    print('events:${events}');
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
          automaticallyImplyLeading: true,
          leading: Center(
            child: Icon(Icons.arrow_back),
          )),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          !isEventAvailable
              ? Center(
                  child: Container(
                    padding: EdgeInsets.only(top: 20),
                    child: Text('No event found!!'),
                  ),
                )
              : Expanded(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          print('list view build');
                          return InkWell(
                            onLongPress: () {
                              deleteEvent(events[index].key);
                            },
                            onTap: () {
                              print(
                                  'event tapped:${events[index].title}, ${events[index].key}, ${events[index].group}');
                              if (events[index].atsignCreator ==
                                  EventService().atClientInstance.currentAtSign)
                                bottomSheet(
                                    context,
                                    CreateEvent(EventService().atClientInstance,
                                        isUpdate: true,
                                        eventData: events[index],
                                        onEventSaved: (event) {
                                      setState(() {
                                        events[events.indexWhere((element) =>
                                            element.key
                                                .contains(event.key))] = event;
                                      });
                                    }),
                                    MediaQuery.of(context).size.height * 0.9);
                              else
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return alertDialog(events[index]);
                                  },
                                );
                            },
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${events[index].title}'),
                                  SizedBox(height: 10),
                                  EventService().currentAtSign ==
                                          events[index].atsignCreator
                                      ? SizedBox()
                                      : Text('${events[index].title}'),
                                  SizedBox(height: 10),
                                  Text(
                                      'created by${events[index].atsignCreator}'),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider();
                        },
                        itemCount: events.length),
                  ),
                )
        ],
      ),
    );
  }

  Widget alertDialog(EventNotificationModel eventData) {
    return AlertDialog(
      title: Text(eventData.title),
      content: Text("Accept event invite??"),
      actions: [
        FlatButton(
          child: Text("No"),
          onPressed: () {
            sendEventAcknowledgement(eventData,
                isAccepted: false, isSharing: false, isExited: false);
          },
        ),
        FlatButton(
          child: Text("Yes"),
          onPressed: () {
            sendEventAcknowledgement(eventData,
                isAccepted: true, isSharing: true, isExited: false);
          },
        ),
      ],
    );
  }
}
