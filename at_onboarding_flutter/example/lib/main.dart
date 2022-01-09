import 'dart:async';

import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter_example/dashboard.dart';
import 'package:at_onboarding_flutter_example/services/at_service.dart';
import 'package:at_onboarding_flutter_example/utils/app_constants.dart';
import 'package:at_onboarding_flutter_example/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:at_onboarding_flutter/widgets/custom_reset_button.dart';

import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_utils/at_logger.dart';

void main() {
  runApp(const MyApp());
}

final StreamController<ThemeMode> updateThemeMode = StreamController<ThemeMode>.broadcast();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AtClientPreference atClientPrefernce;
  final AtSignLogger _logger = AtSignLogger('Plugin example app');
  @override
  void initState() {
    AtService.getInstance()
        .getAtClientPreference()
        .then((AtClientPreference value) => atClientPrefernce = value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeMode>(
        stream: updateThemeMode.stream,
        initialData: ThemeMode.light,
        builder: (BuildContext context, AsyncSnapshot<ThemeMode> snapshot) {
      ThemeMode themeMode = snapshot.data ?? ThemeMode.light;
      return MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: const Color(0xFFf4533d),
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
          builder: (BuildContext context) => Center(
            child: Column(
              children: <Widget>[
                TextButton(
                    onPressed: () async {
                      Onboarding(
                        context: context,
                        // This domain parameter is optional.
                        domain: AppConstants.rootDomain,
                        atClientPreference: atClientPrefernce,
                        appColor: const Color.fromARGB(255, 240, 94, 62),
                        onboard: (Map<String?, AtClientService> value,
                            String? atsign) {
                          AtService.getInstance().atClientServiceMap = value;
                          _logger.finer('Successfully onboarded $atsign');
                        },
                        onError: (Object? error) {
                          _logger.severe('Onboarding throws $error error');
                        },
                        rootEnvironment: RootEnvironment.staging,
                        // API Key is mandatory for production environment.
                        // appAPIKey: YOUR_API_KEY_HERE
                        nextScreen: const DashBoard(),
                      );
                    },
                    child: const Text(AppStrings.scan_qr)),
                CustomResetButton(
                  loading: false,
                  buttonText: 'Reset',
                  width: 90,
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),);}
    );
  }
}
