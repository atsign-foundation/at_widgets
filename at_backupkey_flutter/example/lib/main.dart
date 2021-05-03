import 'package:flutter/material.dart';
import 'dart:async';

import 'package:at_backupkey_flutter/at_backupkey_flutter.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = false;
  var atClientServiceMap;
  var atsign;
  var rootDomain = 'root.atsign.wtf';

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
              Center(
                child: TextButton(
                  onPressed: () async {
                    var _atClientPreference = await getAtClientPreference();
                    Onboarding(
                        context: context,
                        domain: rootDomain,
                        atClientPreference: _atClientPreference,
                        onboard: (map, atsign) {
                          this.atClientServiceMap = map;
                          this.atsign = atsign;
                          loading = true;
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
  }
}
