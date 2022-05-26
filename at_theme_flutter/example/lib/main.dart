import 'dart:async';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart'
    show Onboarding;
import 'package:at_theme_flutter/at_theme_flutter.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;
import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:flutter_keychain/flutter_keychain.dart';

import 'src/pages/profile_page.dart';

final StreamController<AppTheme> appThemeController =
    StreamController<AppTheme>.broadcast();
Future<void> main() async {
  await AtEnv.load();
  runApp(const MyApp());
}

Future<AtClientPreference> loadAtClientPreference() async {
  var dir = await getApplicationSupportDirectory();
  return AtClientPreference()
    ..rootDomain = AtEnv.rootDomain
    ..namespace = AtEnv.appNamespace
    ..hiveStoragePath = dir.path
    ..commitLogPath = dir.path
    ..isLocalStoreRequired = true;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // * load the AtClientPreference in the background
  Future<AtClientPreference> futurePreference = loadAtClientPreference();
  AtClientPreference? atClientPreference;
  AtClientService? atClientService;

  final AtSignLogger _logger = AtSignLogger(AtEnv.appNamespace);

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
                // * The onboarding screen (first screen)
                home: Scaffold(
                    appBar: AppBar(
                      title: const Text('Plugin example app'),
                    ),
                    body: Builder(
                      builder: (context) => Column(
                        children: [
                          const SizedBox(
                            height: 25,
                          ),
                          Container(
                              padding: const EdgeInsets.all(10.0),
                              child: const Center(
                                child: Text(
                                    'A client service should create an atClient instance and call onboard method before navigating to QR scanner screen',
                                    textAlign: TextAlign.center),
                              )),
                          const SizedBox(
                            height: 25,
                          ),
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                var preference = await futurePreference;
                                setState(() {
                                  atClientPreference = preference;
                                });
                                Onboarding(
                                  context: context,
                                  atClientPreference: atClientPreference!,
                                  domain: AtEnv.rootDomain,
                                  rootEnvironment: AtEnv.rootEnvironment,
                                  appAPIKey: '477b-876u-bcez-c42z-6a3d',
                                  onboard: (Map<String?, AtClientService> value,
                                      String? atsign) async {
                                    atClientService = value[atsign];
                                    await Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ProfilePage()));
                                  },
                                  onError: (error) async {
                                    _logger.severe(
                                        'Onboarding throws $error error');
                                    await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: const Text(
                                                'Something went wrong'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('ok'))
                                            ],
                                          );
                                        });
                                  },
                                );
                              },
                              child: const Text('Start onboarding'),
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          Center(
                              child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.black12),
                                  ),
                                  onPressed: () {
                                    FlutterKeychain.remove(key: '@atsign');
                                  },
                                  child: const Text('Clear paired atsigns',
                                      style: TextStyle(color: Colors.black)))),
                        ],
                      ),
                    )),
              ));
        });
  }
}
