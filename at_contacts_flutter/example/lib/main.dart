import 'package:at_contacts_flutter_example/client_sdk_service.dart';
import 'package:flutter/material.dart';
import 'package:atsign_authentication_helper/atsign_authentication_helper.dart';
import 'package:at_contacts_flutter_example/second_screen.dart';

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
                                  builder: (context) => SecondScreen()));
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
