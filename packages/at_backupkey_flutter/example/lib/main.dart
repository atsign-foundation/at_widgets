import 'dart:async';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart'
    show AtOnboardingConfig, AtOnboardingResultStatus, BackupKeyWidget;

// import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;
import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;
import 'package:at_onboarding_flutter/at_onboarding.dart';

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
    ..isLocalStoreRequired = true;
}

final StreamController<ThemeMode> updateThemeMode =
    StreamController<ThemeMode>.broadcast();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // * load the AtClientPreference in the background
  Future<AtClientPreference> futurePreference = loadAtClientPreference();
  AtClientPreference? atClientPreference;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeMode>(
      stream: updateThemeMode.stream,
      initialData: ThemeMode.light,
      builder: (BuildContext context, AsyncSnapshot<ThemeMode> snapshot) {
        ThemeMode themeMode = snapshot.data ?? ThemeMode.light;
        return MaterialApp(
          // * The onboarding screen (first screen)
          theme: ThemeData().copyWith(
            brightness: Brightness.light,
            primaryColor: const Color(0xFFf4533d),
            colorScheme: ThemeData.light().colorScheme.copyWith(
                  primary: const Color(0xFFf4533d),
                  background: Colors.white,
                ),
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData().copyWith(
            brightness: Brightness.dark,
            primaryColor: Colors.blue,
            colorScheme: ThemeData.dark().colorScheme.copyWith(
                  primary: Colors.blue,
                  background: Colors.grey[850],
                ),
            scaffoldBackgroundColor: Colors.grey[850],
          ),
          themeMode: themeMode,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('MyApp'),
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
              builder: (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        var preference = await futurePreference;
                        setState(() {
                          atClientPreference = preference;
                        });
                        if (!context.mounted) return;
                        final result = await AtOnboarding.onboard(
                          context: context,
                          config: AtOnboardingConfig(
                            atClientPreference: atClientPreference!,
                            domain: AtEnv.rootDomain,
                            rootEnvironment: AtEnv.rootEnvironment,
                            appAPIKey: AtEnv.appApiKey,
                          ),
                        );
                        if (context.mounted) {
                          switch (result.status) {
                            case AtOnboardingResultStatus.success:
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HomeScreen()));
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
                        }
                      },
                      child: const Text('Onboard an @sign'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        var preference = await futurePreference;
                        atClientPreference = preference;
                        if (context.mounted) {
                          AtOnboarding.reset(
                            context: context,
                            config: AtOnboardingConfig(
                              atClientPreference: atClientPreference!,
                              domain: AtEnv.rootDomain,
                              rootEnvironment: AtEnv.rootEnvironment,
                              appAPIKey: AtEnv.appApiKey,
                            ),
                          );
                        }
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

//* The next screen after onboarding (second screen)
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    /// Get the AtClientManager instance
    var atClientManager = AtClientManager.getInstance();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text(
                'Successfully onboarded and navigated to FirstAppScreen'),

            /// Use the AtClientManager instance to get the current atsign
            Text(
                'Current @sign: ${atClientManager.atClient.getCurrentAtSign()}'),

            ElevatedButton.icon(
              icon: const Icon(
                Icons.file_copy,
                color: Colors.white,
              ),
              label: const Text('Backup your key'),
              onPressed: () async {
                BackupKeyWidget(
                        atsign:
                            atClientManager.atClient.getCurrentAtSign() ?? '')
                    .showBackupDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
