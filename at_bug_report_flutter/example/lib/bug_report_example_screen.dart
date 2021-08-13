import 'package:at_bug_report_flutter/screens/list_bug_report_screen.dart';
import 'package:at_bug_report_flutter/utils/bug_report_dialog_utils.dart';
import 'package:at_bug_report_flutter/utils/init_bug_report_service.dart';
import 'package:at_bug_report_flutter_example/constants.dart';
import 'package:flutter/material.dart';

import 'client_sdk_service.dart';

class BugReportScreen extends StatefulWidget {
  @override
  _BugReportScreenState createState() => _BugReportScreenState();
}

class _BugReportScreenState extends State<BugReportScreen> {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome $activeAtSign',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(
                  height: 16.0,
                ),
                TextButton(
                  onPressed: () async {
                    print('activeAtSign = $activeAtSign');
                    showBugReportDialog(
                        context, activeAtSign, '', 'BugReportExampleScreen');
                  },
                  child: Text(
                    'Show issue report dialog',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    print('activeAtSign = $activeAtSign');
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListBugReportScreen(
                          atSign: activeAtSign,
                          authorAtSign: '',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Show reported issues list',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
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
