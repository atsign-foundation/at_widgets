import 'dart:async';

import 'package:at_onboarding_flutter/screens/onboarding_widget.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_theme_flutter/at_theme_flutter.dart';
import 'package:example/client_sdk_service.dart';
import 'package:example/src/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'src/pages/profile_page.dart';

void main() {
  runApp(MyApp());
}

final StreamController<AppTheme> appThemeController =
    StreamController<AppTheme>.broadcast();

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
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
    return StreamBuilder<AppTheme>(
      stream: appThemeController.stream,
      initialData: AppTheme.from(),
      builder: (context, snapshot) {
        AppTheme appTheme = snapshot.data ?? AppTheme.from();
        return InheritedAppTheme(
          theme: appTheme,
          child: MaterialApp(
            title: 'Multi theme',
            theme: appTheme.toThemeData(),
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
                                appAPIKey: MixedConstants.devAPIKey,
                                appColor: Color.fromARGB(255, 240, 94, 62),
                                rootEnvironment: RootEnvironment.Staging,
                                onboard: (Map<String?, AtClientService> value,
                                    String? atsign) async {
                                  clientSdkService.atClientServiceInstance =
                                      value[atsign];
                                  clientSdkService.setCurrentAtsign = atsign;
                                  print(
                                      'clientSdkService.atClientServiceInstance 1 : ${clientSdkService.atClientServiceInstance}');
                                  await Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProfilePage()));
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black12),
                            ),
                            onPressed: () async {
                              if (clientSdkService.currentAtsign == null) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext c) {
                                      return AlertDialog(
                                        content: Text('Atsign not found.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Okay'),
                                          )
                                        ],
                                      );
                                    });
                                return;
                              }
                              await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfilePage()));
                            },
                            child: Text(
                              'Already authenticated',
                              style: TextStyle(color: Colors.black),
                            ))),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
