import 'package:at_analytics_flutter_example/client_sdk_service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';

import 'bug_report_example_screen.dart';
import 'constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ClientSdkService clientSdkService = ClientSdkService.getInstance();
  @override
  void initState() {
    clientSdkService.onboard();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('At Bug Report Plugin Example'),
          ),
          body: Builder(
            builder: (context) => Column(
              children: [
                Container(
                    padding: EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                          'A client service should create an atClient instance and call onboard method before navigating to QR scanner screen',
                          textAlign: TextAlign.center),
                    )),
                Center(
                    child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black12),
                        ),
                        onPressed: () async {
                          Onboarding(
                            rootEnvironment: RootEnvironment.Production,
                            context: context,
                            atClientPreference:
                            clientSdkService.atClientPreference,
                            domain: MixedConstants.ROOT_DOMAIN,
                            appAPIKey: MixedConstants.devAPIKey,
                            appColor: Color.fromARGB(255, 240, 94, 62),
                            onboard: (Map<String?, AtClientService> value,
                                String? atsign) async {
                              clientSdkService.atClientServiceInstance =
                              value[atsign];
                              await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BugReportScreen()));
                            },
                            onError: (error) async {
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Text('Something went wrong'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('ok'))
                                      ],
                                    );
                                  });
                            },
                          );
                        },
                        child: Text(
                          'Show QR scanner screen',
                          style: TextStyle(color: Colors.black),
                        ))),
                SizedBox(
                  height: 25,
                ),
                Center(
                    child: TextButton(
                        style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.black12),
                        ),
                        onPressed: () async {
                          await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BugReportScreen()));
                        },
                        child: Text(
                          'Already authenticated',
                          style: TextStyle(color: Colors.black),
                        ))),
              ],
            ),
          )),
    );
  }
}
