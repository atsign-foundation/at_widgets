import 'package:at_events_flutter/screens/create_event.dart';
import 'package:at_events_flutter/utils/init_events_service.dart';
import 'package:at_events_flutter_example/event_list.dart';
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
  bool showOptions = false;

  @override
  void initState() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    super.initState();
    activeAtSign =
        clientSdkService.atClientServiceInstance.atClient.currentAtSign;
    initializeEventService();
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
          FlatButton(
            onPressed: () {
              bottomSheet(
                  CreateEvent(), MediaQuery.of(context).size.height * 0.9);
            },
            child: Container(
              height: 40,
              child: Text('Create event'),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          FlatButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventList(),
                ),
              );
            },
            child: Container(
              height: 40,
              child: Text('Event list'),
            ),
          ),
        ],
      ),
    );
  }

  initializeEventService() {
    initialiseEventService(clientSdkService.atClientServiceInstance.atClient,
        rootDomain: MixedConstants.ROOT_DOMAIN);
  }

  bottomSheet(
    T,
    double height,
  ) async {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: StadiumBorder(),
        builder: (BuildContext context) {
          return Container(
            height: height,
            decoration: new BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(12.0),
                topRight: const Radius.circular(12.0),
              ),
            ),
            child: T,
          );
        });
  }
}
