import 'dart:async';

import 'package:at_backupkey_flutter/at_backupkey_flutter.dart';
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
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  OnboardingState onboardingState = OnboardingState.initial;
  Map<String, AtClientService> atClientServiceMap;
  String atsign;
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
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
                      var _atClientPreference = await getAtClientPreference();
                      Onboarding(
                        context: context,
                        domain: rootDomain,
                        appColor: Color.fromARGB(255, 240, 94, 62),
                        atClientPreference: _atClientPreference,
                        onboard: (map, atsign) {
                          this.atClientServiceMap = map;
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
                    child: Text('Onboard my @sign'),
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
                    child: Text('Clear onboarded @sign'),
                  ),
                ),
              if (onboardingState == OnboardingState.success)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 32),
                    Text('Default button:'),
                    BackupKeyWidget(
                      atsign: this.atsign,
                      atClientService: this.atClientServiceMap[atsign],
                    ),
                    SizedBox(height: 16),
                    Text('Custom button:'),
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.file_copy,
                        color: Colors.white,
                      ),
                      label: Text('Backup your key'),
                      onPressed: () async {
                        BackupKeyWidget(
                          atsign: atsign,
                          atClientService: atClientServiceMap[atsign],
                        ).showBackupDialog(context);
                      },
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
