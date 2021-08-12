import 'dart:async';

import 'package:at_chat_flutter_example/constants.dart';
import 'package:at_chat_flutter_example/second_screen.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'client_sdk_service.dart';

final StreamController<ThemeMode> updateThemeMode = StreamController<ThemeMode>.broadcast();

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
    return StreamBuilder<ThemeMode>(
      stream: updateThemeMode.stream,
      initialData: ThemeMode.light,
      builder: (context, snapshot) {
        return MaterialApp(
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: Color(0xFF6200EE),
              accentColor: Color(0xFF03DAC6),
              backgroundColor: Colors.white,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              fontFamily: 'RobotoSlab',
              primaryColor: Color(0xFF3700B3),
              accentColor: Color(0xFF018786),
              backgroundColor: Colors.black,
            ),
            themeMode: snapshot.data,
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
                        child: TextButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.black12),
                            ),
                            onPressed: () async {
                              Onboarding(
                                context: context,
                                atClientPreference:
                                    clientSdkService.atClientPreference,
                                appAPIKey: MixedConstants.devAPIKey,
                                domain: MixedConstants.ROOT_DOMAIN,
                                appColor: Color.fromARGB(255, 240, 94, 62),
                                onboard: (Map<String?, AtClientService> value,
                                    String? atsign) async {
                                  clientSdkService.atClientServiceInstance =
                                      value[atsign];
                                  await Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SecondScreen()));
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
                            child: Text('Show QR scanner screen',
                                style: TextStyle(color: Colors.black)))),
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
                            child: Text('Already authenticated',
                                style: TextStyle(color: Colors.black)))),
                  ],
                ),
              )),
        );
      }
    );
  }
}
