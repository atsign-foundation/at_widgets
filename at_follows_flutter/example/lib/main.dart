import 'package:at_follows_flutter/screens/connections.dart';
import 'package:at_follows_flutter_example/services/at_service.dart';
import 'package:at_follows_flutter_example/services/notification_service.dart';
import 'package:at_follows_flutter_example/utils/app_constants.dart';
import 'package:at_follows_flutter_example/utils/app_strings.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AtService atService = AtService.getInstance();
  NotificationService _notificationService;
  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _notificationService.setOnNotificationClick(onNotificationClick);
  }

  onNotificationClick(String payload) {
    print(
        'clicked inside on notification click and received atsign is $payload');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Builder(
          builder: (context) => Center(
            child: RaisedButton(
                onPressed: () {
                  _getConnections(context);
                },
                child: Text(AppStrings.connection_button)),
          ),
        ),
      ),
    );
  }

  _getConnections(context) async {
    var atService = AtService.getInstance();
    var preference = await atService.getAtClientPreference();

    Onboarding(
      domain: AppConstants.rootDomain,
      context: context,
      onboard: (value, atsign) async {
        atService.atClientServiceInstance = value[atsign];
        atService.atClientInstance = atService.atClientServiceInstance.atClient;
        await atService.startMonitor();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Connections(
                    atClientserviceInstance: atService.atClientServiceInstance,
                    appColor: Colors.black)));
      },
      onError: (error) {
        Center(child: Text('Onboarding throws $error'));
      },
      nextScreen: null,
      atClientPreference: preference,
    );
  }
}
