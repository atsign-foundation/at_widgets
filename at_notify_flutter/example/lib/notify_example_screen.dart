import 'dart:math';
import 'package:at_notify_flutter/utils/init_notify_service.dart';
import 'package:at_notify_flutter/utils/notify_utils.dart';
import 'package:flutter/material.dart';

import 'client_sdk_service.dart';
import 'constants.dart';

class BugReportScreen extends StatefulWidget {
  @override
  _BugReportScreenState createState() => _BugReportScreenState();
}

class _BugReportScreenState extends State<BugReportScreen> {
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  String? activeAtSign;

  TextEditingController atSignController = TextEditingController(text: '');
  TextEditingController messageController = TextEditingController(text: '');

  @override
  void initState() {
    getAtSignAndInitializeBugReport();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Notify Example'),
        ),
        body: Builder(
          builder: (context) => Center(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome $activeAtSign',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  TextField(
                    controller: atSignController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: '@atSign'),
                    onChanged: (text) {},
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter Message'),
                    onChanged: (text) {},
                  ),
                  SizedBox(
                    height: 32.0,
                  ),
                  TextButton(
                    onPressed: () async {
                      notify(
                        context,
                        activeAtSign,
                        atSignController.text,
                        messageController.text,
                      );
                    },
                    child: Text(
                      'Send Notify',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextButton(
                    onPressed: () async {
                      notifyAll(
                        context,
                        activeAtSign,
                        atSignController.text,
                        messageController.text,
                      );
                    },
                    child: Text(
                      'Send Notify All',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextButton(
                    onPressed: () async {
                      notifyList(
                        context,
                        activeAtSign,
                        atSignController.text,
                        messageController.text,
                      );
                    },
                    child: Text(
                      'Send Notify List',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getAtSignAndInitializeBugReport() async {
    var currentAtSign = await clientSdkService.getAtSign();
    setState(() {
      activeAtSign = currentAtSign;
    });
    initializeNotifyService(
        clientSdkService.atClientServiceInstance!.atClient!, activeAtSign!,
        rootDomain: MixedConstants.ROOT_DOMAIN);
  }
}
