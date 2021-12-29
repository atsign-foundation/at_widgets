import 'dart:async';
import 'package:at_onboarding_flutter_example/switch_atsign.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart'
    show Onboarding;
import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;
import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;
import 'package:at_onboarding_flutter/widgets/custom_reset_button.dart';

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
            child: Column(
              children: [
                ElevatedButton(
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
                      appAPIKey: AtEnv.appApiKey,
                      onboard: (value, atsign) {
                        _logger.finer('Successfully onboarded $atsign');
                      },
                      onError: (error) {
                        _logger.severe('Onboarding throws $error error');
                      },
                      nextScreen: const HomeScreen(),
                    );
                  },
                  child: const Text('Onboard an @sign'),
                ),
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
      ),
    );
  }
}

//* The next screen after onboarding (second screen)
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Get the AtClientManager instance
    var atClientManager = AtClientManager.getInstance();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.switch_account),
            tooltip: 'Switch @sign',
            onPressed: () async {
              var atSignList = await KeychainUtil.getAtsignList();
              await showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) =>
                    AtSignBottomSheet(atSignList: atSignList ?? []),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
                'Successfully onboarded and navigated to FirstAppScreen'),

            /// Use the AtClientManager instance to get the current atsign
            Text(
                'Current @sign: ${atClientManager.atClient.getCurrentAtSign()}'),
          ],
        ),
      ),
    );
  }
}
