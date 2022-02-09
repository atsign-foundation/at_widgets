import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

enum OnboardingState {
  initial,
  success,
  error,
}

void main() {
  runApp(const MyApp());
}

final StreamController<ThemeMode> updateThemeMode =
    StreamController<ThemeMode>.broadcast();

class MyApp extends StatefulWidget {
  static const appKey = Key('myapp');
  const MyApp({Key key = appKey}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  OnboardingState onboardingState = OnboardingState.initial;
  late Map<String?, AtClientService>? atClientServiceMap;
  String? atsign;
  final String rootDomain = 'root.atsign.org';

  @override
  void initState() {
    super.initState();
  }

  Future<AtClientPreference> getAtClientPreference() async {
    final appDocumentDirectory =
        await path_provider.getApplicationSupportDirectory();
    String path = appDocumentDirectory.path;
    var _atClientPreference = AtClientPreference()
      ..isLocalStoreRequired = true
      ..commitLogPath = path
      ..namespace = 'backupkeys'
      ..rootDomain = rootDomain
      ..hiveStoragePath = path;
    return _atClientPreference;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeMode>(
      stream: updateThemeMode.stream,
      initialData: ThemeMode.light,
      builder: (context, snapshot) {
        final themeMode = snapshot.data;
        return MaterialApp(
          theme: ThemeData().copyWith(
            brightness: Brightness.light,
            primaryColor: const Color(0xFFf4533d),
            colorScheme:
                ThemeData().colorScheme.copyWith(secondary: Colors.black),
            backgroundColor: Colors.white,
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData().copyWith(
            brightness: Brightness.dark,
            primaryColor: Colors.blue,
            colorScheme:
                ThemeData().colorScheme.copyWith(secondary: Colors.white),
            backgroundColor: Colors.grey[850],
            scaffoldBackgroundColor: Colors.grey[850],
          ),
          themeMode: themeMode,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
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
                ),
              ],
            ),
            body: Builder(
              builder: (context) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (onboardingState == OnboardingState.initial)
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          var _atClientPreference =
                              await getAtClientPreference();
                          Onboarding(
                            context: context,
                            domain: rootDomain,
                            rootEnvironment: RootEnvironment.Staging,
                            appColor: const Color.fromARGB(255, 240, 94, 62),
                            atClientPreference: _atClientPreference,
                            onboard: (map, atsign) {
                              atClientServiceMap = map;
                              this.atsign = atsign;
                              onboardingState = OnboardingState.success;
                              setState(() {});
                            },
                            onError: (error) {
                              onboardingState = OnboardingState.error;
                              setState(() {});
                            },
                          );
                        },
                        child: const Text('Onboard my @sign'),
                      ),
                    ),
                  if (onboardingState == OnboardingState.error ||
                      onboardingState == OnboardingState.success)
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          await KeyChainManager.getInstance()
                              .clearKeychainEntries();
                          atsign = null;
                          atClientServiceMap = null;
                          onboardingState = OnboardingState.initial;
                          setState(() {});
                        },
                        child: const Text('Clear onboarded @sign'),
                      ),
                    ),
                  if (onboardingState == OnboardingState.success)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 32),
                        const Text('Default button:'),
                        BackupKeyWidget(atsign: atsign ?? ''),
                        const SizedBox(height: 16),
                        const Text('Custom button:'),
                        ElevatedButton.icon(
                          icon: const Icon(
                            Icons.file_copy,
                            color: Colors.white,
                          ),
                          label: const Text('Backup your key'),
                          onPressed: () async {
                            BackupKeyWidget(atsign: atsign ?? '')
                                .showBackupDialog(context);
                          },
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
