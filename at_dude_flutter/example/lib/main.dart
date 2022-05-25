import 'dart:async';

import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_dude_flutter/screens/history_screen.dart';
import 'package:at_dude_flutter/screens/profile_screen.dart';
import 'package:at_dude_flutter/services/dude_service.dart';
import 'package:at_dude_flutter/services/local_notification_service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart'
    show Onboarding, RootEnvironment;
import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;
import 'package:provider/provider.dart';

import 'home_screen.dart';

final AtSignLogger _logger = AtSignLogger(AtEnv.appNamespace);

Future<void> main() async {
  // * AtEnv is an abtraction of the flutter_dotenv package used to
  // * load the environment variables set by at_app
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotificationService().initNotification();

  try {
    await AtEnv.load();
  } catch (e) {
    _logger.finer('Environment failed to load from .env: ', e);
  }
  runApp(
    MaterialApp(
      home: const MyApp(),
      routes: {
        HistoryScreen.routeName: (context) => const HistoryScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
      },
    ),
  );
}

Future<AtClientPreference> loadAtClientPreference() async {
  var dir = await getApplicationSupportDirectory();

  return AtClientPreference()
    ..rootDomain = AtEnv.rootDomain
    ..namespace = AtEnv.appNamespace
    ..hiveStoragePath = dir.path
    ..commitLogPath = dir.path
    ..isLocalStoreRequired = true;
  // TODO
  // * By default, this configuration is suitable for most applications
  // * In advanced cases you may need to modify [AtClientPreference]
  // * Read more here: https://pub.dev/documentation/at_client/latest/at_client/AtClientPreference-class.html
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // * load the AtClientPreference in the background
  Future<AtClientPreference> futurePreference = loadAtClientPreference();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // * The onboarding screen (first screen
      home: Scaffold(
        appBar: AppBar(
          title: const Text('MyApp'),
        ),
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                // * The Onboarding widget
                // * This widget contains the required logic for onboarding an @sign into the app
                // * Read more here: https://pub.dev/packages/at_onboarding_flutter
                Onboarding(
                  context: context,
                  atClientPreference: await futurePreference,
                  domain: AtEnv.rootDomain,
                  rootEnvironment: RootEnvironment.Production,
                  appAPIKey: AtEnv.appApiKey,
                  onboard: (value, atsign) async {
                    _logger.finer('Successfully onboarded $atsign');

                    _logger.finer('Successfully onboarded $atsign');
                  },
                  onError: (error) {
                    _logger.severe('Onboarding throws $error error');
                  },
                  nextScreen: HomeScreen(),
                );
              },
              child: const Text('Onboard an @sign'),
            ),
          ),
        ),
      ),
    );
  }
}
