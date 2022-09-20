import 'dart:async';
import 'package:at_follows_flutter_example/screens/follows_screen.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;
import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;

import 'services/at_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // * The onboarding screen (first screen)
      navigatorKey: NavService.navKey,
      home: Scaffold(
          appBar: AppBar(
            title: const Text('at_follows_flutter example app'),
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

                          final OnboardingService _onboardingService =
                              OnboardingService.getInstance();
                          atClientService = _onboardingService
                              .atClientServiceMap[result.atsign!];

                          AtService.getInstance().atClientServiceInstance =
                              _onboardingService
                                  .atClientServiceMap[result.atsign!];

                          await AtClientManager.getInstance().setCurrentAtSign(
                            result.atsign!,
                            atClientPreference!.namespace!,
                            atClientPreference!,
                          );

                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => NextScreen()));
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
                        onPressed: () async {
                          var _atsignsList = await KeychainUtil.getAtsignList();
                          for (String atsign in (_atsignsList ?? [])) {
                            await KeychainUtil.resetAtSignFromKeychain(atsign);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Cleared all paired atsigns')));
                        },
                        child: const Text('Clear paired atsigns',
                            style: TextStyle(color: Colors.black)))),
              ],
            ),
          )),
    );
  }
}

class NavService {
  static GlobalKey<NavigatorState> navKey = GlobalKey();
}
