import 'dart:async';

import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
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
        ..syncStrategy = SyncStrategy.onDemand
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // * The onboarding screen (first screen)
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AtLogin Example App'),
        ),
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () async {
                atClientPreference = await futurePreference;
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()));
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
              child: const Text(
                'Onboard an @sign',
                style: TextStyle(fontSize: 36),
              ),
            ),
          ),
        ),
      ),
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

    var currentAtSign = AtClientManager.getInstance().atClient.getCurrentAtSign();

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
            Text('Current @sign: $currentAtSign'),
          ],
        ),
      ),
    );
  }
}
