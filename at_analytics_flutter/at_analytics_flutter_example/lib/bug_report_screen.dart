import 'dart:math';


import 'package:at_analytics_flutter/at_analytics_flutter.dart';
import 'package:at_analytics_flutter_example/constants.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:flutter/material.dart';

class BugReportScreen extends StatefulWidget {
  @override
  _BugReportScreenState createState() => _BugReportScreenState();
}

class _BugReportScreenState extends State<BugReportScreen> {
  AtClientService? atClientService;
  AtClientPreference? atClientPreference;
  String? activeAtSign;
  String? bugReport;

  /// Get the AtClientManager instance
  var atClientManager = AtClientManager.getInstance();
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
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            'Bug Report Example',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
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
                  height: 64.0,
                ),
                TextButton(
                  onPressed: () async {
                    print('activeAtSign = $activeAtSign');
                    // Example Try catch function to catch exception from app
                    try {
                      int result = 12 ~/ 0;
                      print("The result is $result");
                    } catch (e) {
                      setState(() {
                        bugReport = e.toString();
                      });
                      print("The exception thrown is $e");
                    }
                    // End of function
                    print(bugReport);
                    showBugReportDialog(
                      context,
                      activeAtSign,
                      MixedConstants.authorAtsign,
                      bugReport,
                      isSuccessCallback: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              'Share Successfully',
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    'Show issue report dialog',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    sendErrorReport(
                        'custom error', context, MixedConstants.authorAtsign,
                        () {
                      print('success in sending report');
                    });
                  },
                  child: Text(
                    'Send custom error.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
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
                          authorAtSign: MixedConstants.authorAtsign,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Show reported issues list',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
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
    var currentAtSign = atClientManager.atClient.getCurrentAtSign();
    setState(() {
      activeAtSign = currentAtSign;
    });
    initializeBugReportService(atClientService!.atClientManager,
        MixedConstants.authorAtsign, activeAtSign!, atClientPreference!,
        rootDomain: MixedConstants.ROOT_DOMAIN);
  }
}
