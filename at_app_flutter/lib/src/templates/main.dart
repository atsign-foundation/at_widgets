import 'dart:async';

import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_utils/at_logger.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:at_app_flutter/at_app_flutter.dart';

void main() {
  AtEnv.load();
  runApp(const MyApp());
}

Future<AtClientPreference> loadAtClientPreference() async {
  var dir = await path_provider.getApplicationSupportDirectory();
  return AtClientPreference()
        ..rootDomain = AtEnv.rootDomain
        ..namespace = AtEnv.appNamespace
        ..hiveStoragePath = dir.path
        ..commitLogPath = dir.path
        ..isLocalStoreRequired = true
        ..syncStrategy = SyncStrategy.ONDEMAND
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

  AtClientService? atClientService;
  AtClientPreference? atClientPreference;

  final AtSignLogger _logger = AtSignLogger(AtEnv.appNamespace);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // * The onboarding screen (first screen)
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MyApp'),
        ),
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () async {
                atClientPreference = await futurePreference;
                Onboarding(
                  context: context,
                  atClientPreference: atClientPreference!,
                  domain: AtEnv.rootDomain,
                  onboard: (value, atsign) {
                    setState(() {
                      atClientService = value[atsign]!;
                    });
                    _logger.finer('Successfully onboarded $atsign');
                  },
                  onError: (error) {
                    _logger.severe('Onboarding throws $error error');
                  },
                  nextScreen: const HomeScreen(),
                  appAPIKey: AtEnv.appApiKey,
                );
              },
              child: const Text(
                'Onboard an @sign',
                style: TextStyle(fontSize: 36),
              ),
            ),
          ),
        ),
      ),

      // * The context provider for the app
      builder: (BuildContext context, Widget? child) {
        if (atClientService != null && atClientPreference != null) {
          return AtContext(
            atClientService: atClientService!,
            atClientPreference: atClientPreference!,
            child: child ?? Container(),
          );
        }
        return child ?? Container();
      },
    );
  }
}

//* The next screen after onboarding (second screen)
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // * Get the AtContext from build context
    // ! NOTE: Only use this after successfully onboarding the @sign
    AtContext atContext = AtContext.of(context);

    // * Example Uses
    /// AtClientService atClientService = atContext.atClientService;
    /// AtClientImpl? atClientInstance = atContext.atClient;
    /// String? currentAtSign = atContext.currentAtSign;
    /// AtClientPreference atClientPreference = atContext.atClientPreference;
    /// atContext.switchAtsign("@example");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
                'Successfully onboarded and navigated to FirstAppScreen'),
            Text('Current @sign: ${atContext.currentAtSign}'),
          ],
        ),
      ),
    );
  }
}
