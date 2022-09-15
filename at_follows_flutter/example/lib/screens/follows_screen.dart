import 'package:at_follows_flutter/screens/connections.dart';
import 'package:at_follows_flutter_example/services/at_service.dart';
import 'package:at_follows_flutter_example/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:at_utils/at_logger.dart';
import 'package:at_follows_flutter_example/utils/app_strings.dart';
import 'package:at_client_mobile/at_client_mobile.dart'
    hide NotificationService;

class NextScreen extends StatefulWidget {
  final AtClientService atClientService;

  NextScreen({
    required this.atClientService,
  });

  @override
  _NextScreen createState() => _NextScreen();
}

class _NextScreen extends State<NextScreen> {
  String? atSign;
  AtService atService = AtService.getInstance();
  late NotificationService _notificationService;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Screen'),
      ),
      body: Builder(
        builder: (context) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: TextButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Connections(
                        atClientserviceInstance: widget.atClientService,
                      ),
                    ),
                  );
                },
                child: Text(
                  AppStrings.nextscreen,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
