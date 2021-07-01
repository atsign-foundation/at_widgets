import 'package:at_events_flutter/models/event_key_location_model.dart';
import 'package:at_events_flutter/screens/create_event.dart';
import 'package:at_events_flutter/utils/init_events_service.dart';
import 'package:at_events_flutter_example/event_list.dart';
import 'package:at_events_flutter_example/main.dart';
import 'package:flutter/material.dart';
import 'client_sdk_service.dart';
import 'constants.dart';

class SecondScreen extends StatefulWidget {
  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  String activeAtSign;
  GlobalKey<ScaffoldState> scaffoldKey;
  bool isAuthenticated;
  List<EventKeyLocationModel> events = [];

  @override
  void initState() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    super.initState();

    try {
      activeAtSign =
          clientSdkService.atClientServiceInstance.atClient.currentAtSign;
      initializeEventService();
      isAuthenticated = true;
    } catch (e) {
      isAuthenticated = false;
      print('not authenticated');
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alertDialogContent();
          },
        );
      });
    }
  }

  updateEvents(List<EventKeyLocationModel> _events) {
    setState(() {
      events = _events;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Second Screen')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20.0,
          ),
          Container(
            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
            child: Center(
              child: Text(
                'Welcome $activeAtSign!',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          TextButton(
            onPressed: () {
              bottomSheet(
                  CreateEvent(
                      clientSdkService.atClientServiceInstance.atClient),
                  MediaQuery.of(context).size.height * 0.9);
            },
            child: Container(
              height: 40,
              child:
                  Text('Create event', style: TextStyle(color: Colors.black)),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventList(events),
                ),
              );
            },
            child: Container(
              height: 40,
              child: Text('Event list', style: TextStyle(color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  void initializeEventService() {
    initialiseEventService(
        clientSdkService.atClientServiceInstance.atClient, NavService.navKey,
        rootDomain: MixedConstants.ROOT_DOMAIN,
        streamAlternative: updateEvents);
  }

  void bottomSheet(
    T,
    double height,
  ) async {
    await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: StadiumBorder(),
        builder: (BuildContext context) {
          return Container(
            height: height,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12.0),
                topRight: const Radius.circular(12.0),
              ),
            ),
            child: T,
          );
        });
  }

  Widget alertDialogContent() {
    return AlertDialog(
      title: Text('you are not authenticated'),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child: Text('Ok', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
