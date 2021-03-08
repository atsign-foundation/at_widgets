import 'package:atsign_authentication_helper/screens/scan_qr.dart';

import 'package:at_events_flutter_example/second_screen.dart';
import 'package:flutter/material.dart';

import 'client_sdk_service.dart';

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
            title: const Text('Plugin example app'),
          ),
          body: Builder(
            builder: (context) => Column(
              children: [
                SizedBox(
                  height: 25,
                ),
                Container(
                    padding: EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                          'A client service should create an atClient instance and call onboard method before navigating to QR scanner screen',
                          textAlign: TextAlign.center),
                    )),
                SizedBox(
                  height: 25,
                ),
                Center(
                    child: FlatButton(
                        color: Colors.black12,
                        onPressed: () async {
                          await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ScanQrScreen(
                                      atClientServiceInstance: clientSdkService
                                          .atClientServiceInstance,
                                      atClientPreference:
                                          clientSdkService.atClientPreference,
                                      nextScreen: SecondScreen())));
                        },
                        child: Text('Show QR scanner screen'))),
                SizedBox(
                  height: 25,
                ),
                Center(
                    child: FlatButton(
                        color: Colors.black12,
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SecondScreen()));
                        },
                        child: Text('Already authenticated'))),
              ],
            ),
          )),
    );
  }
}
