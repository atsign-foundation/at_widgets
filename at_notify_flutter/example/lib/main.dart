import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';

import 'client_sdk_service.dart';
import 'notify_example_screen.dart';
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
  var _showAlreadyAuthenticatedButton = false;
  @override
  void initState() {
    onboard();
    super.initState();
  }

  onboard() async {
    await clientSdkService.onboard();
    setState(() {
      _showAlreadyAuthenticatedButton = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          bottomSheet: _bottomSheet(),
          appBar: AppBar(
            title: const Text('At Notify Plugin Example'),
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
                            // appAPIKey: MixedConstants.devAPIKey,
                            appColor: Color.fromARGB(255, 240, 94, 62),
                            onboard: (Map<String?, AtClientService> value,
                                String? atsign) async {
                              clientSdkService.atClientServiceInstance =
                                  value[atsign];
                              await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          NotifyExampleScreen()));
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
                        onPressed: _showAlreadyAuthenticatedButton
                            ? () async {
                                await Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NotifyExampleScreen()));
                              }
                            : null,
                        child: Text(
                          'Already authenticated',
                          style: TextStyle(
                              color: _showAlreadyAuthenticatedButton
                                  ? Colors.black
                                  : Colors.black54),
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
                          await clientSdkService.deleteKey();
                        },
                        child: Text(
                          'Clear paired atsigns',
                          style: TextStyle(color: Colors.black),
                        ))),
              ],
            ),
          )),
    );
  }

  Widget _bottomSheet() {
    if (_showAlreadyAuthenticatedButton) {
      return SizedBox();
    } else {
      return Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.black87, boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0),
            blurRadius: 3.0,
          ),
        ]),
        child: Text(
          'Checking authentication state...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }
}
