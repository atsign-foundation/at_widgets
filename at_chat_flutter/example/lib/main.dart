import 'dart:async';

import 'package:at_chat_flutter_example/second_screen.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart'
    show AtOnboarding, AtOnboardingConfig, AtOnboardingResultStatus, Onboarding;
import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;
import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;
import 'package:flutter_keychain/flutter_keychain.dart';

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
    return StreamBuilder<ThemeMode>(
      stream: updateThemeMode.stream,
      initialData: ThemeMode.light,
      builder: (context, snapshot) {
        ThemeMode themeMode = snapshot.data ?? ThemeMode.light;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF6200EE),
            accentColor: const Color(0xFF03DAC6),
            backgroundColor: Colors.white,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'RobotoSlab',
            primaryColor: const Color(0xFF3700B3),
            accentColor: const Color(0xFF018786),
            backgroundColor: Colors.black,
          ),
          themeMode: themeMode,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
              actions: <Widget>[
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
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: const Center(
                      child: Text(
                        'A client service should create an atClient instance and call onboard method before navigating to QR scanner screen',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
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
                        final result = await AtOnboarding.onboard(
                          context: context,
                          config: AtOnboardingConfig(
                            atClientPreference: atClientPreference!,
                            domain: AtEnv.rootDomain,
                            rootEnvironment: AtEnv.rootEnvironment,
                            appAPIKey: AtEnv.appApiKey,
                          ),
                        );
                        switch (result.status) {
                          case AtOnboardingResultStatus.success:
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SecondScreen()));
                            break;
                          case AtOnboardingResultStatus.error:
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('An error has occurred'),
                              ),
                            );
                            break;
                          case AtOnboardingResultStatus.cancel:
                            break;
                        }
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
                            MaterialStateProperty.all<Color>(Colors.black12),
                      ),
                      onPressed: () {
                        FlutterKeychain.remove(key: '@atsign');
                      },
                      child: const Text(
                        'Clear paired atsigns',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
