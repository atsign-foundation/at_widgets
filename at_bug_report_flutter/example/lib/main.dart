import 'package:at_bug_report_flutter/utils/bug_report_dialog_utils.dart';
import 'package:at_bug_report_flutter/utils/init_bug_report_service.dart';
import 'package:at_bug_report_flutter_example/constants.dart';
import 'package:flutter/material.dart';

import 'client_sdk_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  String? activeAtSign;

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
          title: const Text('Bug Report Example'),
        ),
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () async {
                print('activeAtSign = $activeAtSign');
                showBugReportDialog(context, activeAtSign);
              },
              child: Text(
                'Show Error',
                style: TextStyle(fontSize: 36),
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
    initializeBugReportService(
        clientSdkService.atClientServiceInstance!.atClient!, activeAtSign!,
        rootDomain: MixedConstants.ROOT_DOMAIN);
  }
}
