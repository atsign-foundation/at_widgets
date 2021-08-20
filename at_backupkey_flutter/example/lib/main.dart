import 'package:at_backupkey_flutter_example/constants.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_backupkey_flutter/at_backupkey_flutter.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() {
  runApp(MyApp());
}

final StreamController<ThemeMode> updateThemeMode =
    StreamController<ThemeMode>.broadcast();

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = false;
  var atClientServiceMap;
  var atsign;

  @override
  void initState() {
    super.initState();
    // initPlatformState();
  }

  Future<AtClientPreference> getAtClientPreference() async {
    final appDocumentDirectory =
        await path_provider.getApplicationSupportDirectory();
    String path = appDocumentDirectory.path;
    var _atClientPreference = AtClientPreference()
      ..isLocalStoreRequired = true
      ..commitLogPath = path
      ..namespace = 'backupkeys'
      ..syncStrategy = SyncStrategy.ONDEMAND
      ..rootDomain = MixedConstants.ROOT_DOMAIN
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
                )
              ],
            ),
            body: Builder(
              builder: (context) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        ColorConstants.darkTheme = themeMode != ThemeMode.light;
                        var _atClientPreference = await getAtClientPreference();
                        Onboarding(
                            context: context,
                            domain: MixedConstants.ROOT_DOMAIN,
                            appAPIKey: MixedConstants.devAPIKey,
                            appColor: Color(0xFFf4533d),
                            atClientPreference: _atClientPreference,
                            onboard: (map, atsign) async {
                              this.atClientServiceMap = map;
                              this.atsign = atsign;
                              loading = true;
                              await Future.delayed(Duration(seconds: 1));
                              setState(() {});
                            },
                            onError: (error) {});
                      },
                      child: Text('Onboard my @sign'),
                    ),
                  ),
                  if (loading)
                    BackupKeyWidget(
                      atsign: this.atsign,
                      atClientService: this.atClientServiceMap[atsign],
                      isIcon: true,
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
