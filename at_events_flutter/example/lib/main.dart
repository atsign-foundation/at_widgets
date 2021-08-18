import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_events_flutter_example/client_sdk_service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:flutter/material.dart';
import 'package:at_events_flutter_example/second_screen.dart';

import 'constants.dart';

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
            primaryColor: Color(0xFFf4533d),
            accentColor: Colors.black,
            backgroundColor: Colors.white,
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.blue,
            accentColor: Colors.white,
            backgroundColor: Colors.grey[850],
            scaffoldBackgroundColor: Colors.grey[850],
          ),
          themeMode: snapshot.data,
          navigatorKey: NavService.navKey,
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black12),
                            ),
                            onPressed: () async {
                              Onboarding(
                                context: context,
                                atClientPreference:
                                    clientSdkService.atClientPreference,
                                domain: MixedConstants.ROOT_DOMAIN,
                                appColor: Color.fromARGB(255, 240, 94, 62),
                                appAPIKey: MixedConstants.devAPIKey,
                                onboard: (Map<String?, AtClientService> value,
                                    String? atsign) async {
                                  clientSdkService.atClientServiceInstance =
                                      value[atsign];
                                  await Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SecondScreen()));
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black12),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SecondScreen()));
                            },
                            child: Text('Already authenticated',
                                style: TextStyle(color: Colors.black)))),
                    TextButton(
                      onPressed: () async {
                        var _keyChainManager = KeyChainManager.getInstance();
                        var _atSignsList =
                            await _keyChainManager.getAtSignListFromKeychain();
                        _atSignsList?.forEach((element) {
                          _keyChainManager.deleteAtSignFromKeychain(element);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          'Keychain cleaned',
                          textAlign: TextAlign.center,
                        )));
                      },
                      child: Text(
                        'Reset keychain',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    )
                  ],
                ),
              )),
        );
      },
    );
  }
}

class NavService {
  static GlobalKey<NavigatorState> navKey = GlobalKey();
}
