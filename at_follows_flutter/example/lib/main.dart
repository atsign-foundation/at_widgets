import 'dart:async';
import 'package:at_follows_flutter/utils/color_constants.dart';
import 'package:at_follows_flutter_example/screens/follows_screen.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart'
    show Onboarding;
import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;
import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;

import 'services/at_service.dart';

final StreamController<ThemeMode> updateThemeMode =
    StreamController<ThemeMode>.broadcast();

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
        ..isLocalStoreRequired = true
      // TODO set the rest of your AtClientPreference here
      ;
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
    return StreamBuilder<ThemeMode>(
      stream: updateThemeMode.stream,
      initialData: ThemeMode.light,
      builder: (context, snapshot) {
        final themeMode = snapshot.data;
        ColorConstants.darkTheme = themeMode != ThemeMode.light;
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
                title: const Text('at_follows_flutter example app'),
                actions: [
                  IconButton(
                    onPressed: () {
                      updateThemeMode.sink.add(themeMode == ThemeMode.light
                          ? ThemeMode.dark
                          : ThemeMode.light);
                    },
                    icon: Icon(
                      Theme.of(context).brightness == Brightness.light
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                    ),
                  )
                ],
              ),
              body: Builder(
                builder: (context) => Column(
                  children: [
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
                              AtService.getInstance().atClientServiceInstance =
                                  value[atsign];

                              await AtClientManager.getInstance()
                                  .setCurrentAtSign(
                                atsign!,
                                atClientPreference!.namespace!,
                                atClientPreference!,
                              );

                              await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => NextScreen()));
                            },
                            onError: (error) async {
                              _logger.severe('Onboarding throws $error error');
                              await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content:
                                          const Text('Something went wrong'),
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.black12),
                            ),
                            onPressed: () async {
                              var _atsignsList =
                                  await KeychainUtil.getAtsignList();
                              for (String atsign in (_atsignsList ?? [])) {
                                await KeychainUtil.resetAtSignFromKeychain(
                                    atsign);
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Cleared all paired atsigns')));
                            },
                            child: const Text('Clear paired atsigns',
                                style: TextStyle(color: Colors.black)))),
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
