import 'dart:async';
import 'package:at_onboarding_flutter_example/switch_atsign.dart';
import 'package:flutter/material.dart';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart'
    show AtOnboardingConfig, Onboarding;
import 'package:at_utils/at_logger.dart' show AtSignLogger;
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;
import 'package:at_app_flutter/at_app_flutter.dart' show AtEnv;
import 'package:at_onboarding_flutter/widgets/custom_reset_button.dart';
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
        ..isLocalStoreRequired = true
      // TODO set the rest of your AtClientPreference here
      ;
}

final StreamController<ThemeMode> updateThemeMode =
    StreamController<ThemeMode>.broadcast();

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
            ),
            backgroundColor: Colors.white,
            scaffoldBackgroundColor: Colors.white,
            textTheme: const TextTheme(
                bodyText1: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
                bodyText2: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                )),
          ),
          darkTheme: ThemeData().copyWith(
            brightness: Brightness.dark,
            primaryColor: Colors.blue,
            colorScheme: ThemeData.dark().colorScheme.copyWith(
              primary: Colors.blue,
            ),
            backgroundColor: Colors.grey[850],
            scaffoldBackgroundColor: Colors.grey[850],
            textTheme: const TextTheme(
                bodyText1: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
            )),
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
                        Onboarding(
                          context: context,
                          atClientPreference: atClientPreference!,
                          domain: AtEnv.rootDomain,
                          rootEnvironment: AtEnv.rootEnvironment,
                          appAPIKey: AtEnv.appApiKey,
                          appColor: Theme.of(context).primaryColor,
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
                    const SizedBox(height: 10),
                    const CustomResetButton(
                      buttonText: 'Reset',
                      width: 90,
                      height: 40,
                    ),
                    const SizedBox(height: 100),
                    ElevatedButton(
                      onPressed: () async {
                        var preference = await futurePreference;
                        setState(() {
                          atClientPreference = preference;
                        });
                        final result = await AtOnboarding.onboard(
                          context: context,
                          config: AtOnboardingConfig(
                            context: context,
                            atClientPreference: atClientPreference!,
                            domain: AtEnv.rootDomain,
                            rootEnvironment: AtEnv.rootEnvironment,
                            appAPIKey: AtEnv.appApiKey,
                            appColor: Theme.of(context).primaryColor,
                            onboard: (value, atsign) {
                              _logger.finer('Successfully onboarded $atsign');
                            },
                            onError: (error) {
                              _logger.severe('Onboarding throws $error error');
                            },
                            nextScreen: const HomeScreen(),
                          ),
                          // onSuccess: () {
                          //
                          // },
                          // onError: () {
                          //   //Do nothing
                          // },
                        );
                        switch (result) {
                          case AtOnboardingResult.success:
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const HomeScreen()));
                            break;
                          case AtOnboardingResult.error:
                            // TODO: Handle this case.
                            break;
                          case AtOnboardingResult.notFound:
                            // TODO: Handle this case.
                            break;
                          case AtOnboardingResult.cancel:
                            // TODO: Handle this case.
                            break;
                        }
                        // AtOnboarding.start(
                        //   context: context,
                        //   config: AtOnboardingConfig(
                        //     context: context,
                        //     atClientPreference: atClientPreference!,
                        //     domain: AtEnv.rootDomain,
                        //     rootEnvironment: AtEnv.rootEnvironment,
                        //     appAPIKey: AtEnv.appApiKey,
                        //     appColor: Theme.of(context).primaryColor,
                        //     onboard: (value, atsign) {
                        //       _logger.finer('Successfully onboarded $atsign');
                        //     },
                        //     onError: (error) {
                        //       _logger.severe('Onboarding throws $error error');
                        //     },
                        //     nextScreen: const HomeScreen(),
                        //   ),
                        // );
                      },
                      child: const Text('Onboard an @sign - 2'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        var preference = await futurePreference;
                        atClientPreference = preference;
                        AtOnboarding.reset(
                          context: context,
                          config: AtOnboardingConfig(
                            context: context,
                            atClientPreference: atClientPreference!,
                            domain: AtEnv.rootDomain,
                            rootEnvironment: AtEnv.rootEnvironment,
                            appAPIKey: AtEnv.appApiKey,
                            appColor: Theme.of(context).primaryColor,
                            onboard: (value, atsign) {
                              _logger.finer('Successfully onboarded $atsign');
                            },
                            onError: (error) {
                              _logger.severe('Onboarding throws $error error');
                            },
                            nextScreen: const HomeScreen(),
                          ),
                        );
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
