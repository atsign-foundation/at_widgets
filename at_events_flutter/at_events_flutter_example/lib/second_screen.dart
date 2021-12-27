import 'package:at_events_flutter/at_events_flutter.dart';
import 'package:at_events_flutter/utils/constants.dart';
import 'package:at_events_flutter_example/main.dart';
import 'package:at_events_flutter_example/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';

class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  // ClientSdkService clientSdkService = ClientSdkService.getInstance();
  String? activeAtSign;
  GlobalKey<ScaffoldState>? scaffoldKey;
  bool? isAuthenticated;
  List<EventKeyLocationModel> events = [];

  /// Get the AtClientManager instance
  var atClientManager = AtClientManager.getInstance();
  late AtClientPreference atClientPreference;
  @override
  void initState() {
    scaffoldKey = GlobalKey<ScaffoldState>();
    super.initState();

    try {
      activeAtSign = atClientManager.atClient.getCurrentAtSign();
      atClientManager.setCurrentAtSign(activeAtSign!, atClientPreference.namespace, atClientPreference);
      initializeEventService();
      isAuthenticated = true;
    } catch (e) {
      isAuthenticated = false;
      print('not authenticated');
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alertDialogContent();
          },
        );
      });
    }
  }

  void updateEvents(List<EventKeyLocationModel> _events) {
    setState(() {
      events = _events;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
              bottomSheet(CreateEvent(atClientManager),
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
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      HomeEventService().onEventModelTap(
                          events[index].eventNotificationModel!,
                          events[index].haveResponded);
                    },
                    child: DisplayTile(
                      atsignCreator:
                          events[index].eventNotificationModel!.atsignCreator,
                      number: events[index]
                          .eventNotificationModel!
                          .group!
                          .members!
                          .length,
                      title: 'Event - ' +
                          events[index].eventNotificationModel!.title!,
                      subTitle: HomeEventService()
                          .getSubTitle(events[index].eventNotificationModel!),
                      semiTitle: HomeEventService().getSemiTitle(
                          events[index].eventNotificationModel!,
                          events[index].haveResponded),
                      showRetry:
                          HomeEventService().calculateShowRetry(events[index]),
                      onRetryTapped: () {
                        HomeEventService().onEventModelTap(
                            events[index].eventNotificationModel!, false);
                      },
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    color: Colors.grey,
                  );
                },
                itemCount: events.length),
          )
        ],
      ),
    );
  }

  void initializeEventService() {
    initialiseEventService(NavService.navKey,
        mapKey: '',
        apiKey: '',
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
