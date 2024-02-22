import 'package:at_enrollment_flutter/models/enrollment_config.dart';
import 'package:at_enrollment_flutter/screens/home/home.dart';
import 'package:at_enrollment_flutter/screens/key_authenticator_home_screen.dart';
import 'package:at_enrollment_flutter/services/enrollment_service.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_response_status.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

class LandingPage extends StatefulWidget {
  static const String rootDomain = 'root.atsign.org';

  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    EnrollmentService.getInstance().init(
      EnrollmentConfig(namespace: 'wavi'),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'At Enrollment Service',
      theme: ThemeData(
        fontFamily: 'Poppins',
        package: 'at_enrollment_flutter',
      ).copyWith(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFf4533d),
        colorScheme: ThemeData.light().colorScheme.copyWith(
              primary: const Color(0xFFf4533d),
            ),
        // ignore: deprecated_member_use
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        fontFamily: 'Poppins',
        package: 'at_enrollment_flutter',
      ).copyWith(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFf4533d),
        colorScheme: ThemeData.light().colorScheme.copyWith(
              primary: const Color(0xFFf4533d),
            ),
        // ignore: deprecated_member_use
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('At Enrollment Service'),
        ),
        body: Builder(
          builder: (context) => Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                ElevatedButton(
                  onPressed: () async {
                    await onboardAtSign(context);
                  },
                  child: const Text('Onboard'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    authenticateAtSign(context);
                  },
                  child: const Text('Authenticate'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const HomeScreen(),
                      ),
                    );
                  },
                  child: const Text('Enroll'),
                )
              ]),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: reset,
                    child: const Text('Reset'),
                  )
                ],
              )
            ],
          )),
        ),
      ),
    );
  }

  Future<void> onboardAtSign(BuildContext context) async {
    final result = await AtOnboarding.onboard(
      context: context,
      config: AtOnboardingConfig(
        atClientPreference: await getAtClientPreferences(),
        domain: LandingPage.rootDomain,
        rootEnvironment: RootEnvironment.Production,
        theme: AtOnboardingTheme(
          primaryColor: null,
        ),
        showPopupSharedStorage: true,
      ),
    );
    if (result.status == AtOnboardingResultStatus.success) {
      // setup of current atsign and atChops
      // AtChopsKeys atChopsKey = AtChopsKeys.create(atEncryptionKeyPair, _atPkamKeyPair);
      // AtClientManager.getInstance().setCurrentAtSign(
      //   result.atsign!,
      //   'enroll',
      //   await getAtClientPreferences(),
      //   atChops: AtChops(atChopsKey),
      // );

      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                const KeyAuthenticatorHomeScreen(),
          ),
        );
      }
    }
  }

  Future<void> authenticateAtSign(BuildContext context) async {
    // get AtSign from keychain manager
    String? atSign = await KeyChainManager.getInstance().getAtSign();
    if (atSign == null || atSign.isEmpty) {
      // TODO: Redirect to onboard or throw exception
    }

    OnboardingService onboardingService = OnboardingService.getInstance();
    onboardingService.setAtClientPreference = await getAtClientPreferences();

    AtOnboardingResponseStatus atOnboardingResponseStatus =
        await onboardingService.authenticate(atSign);

    if (atOnboardingResponseStatus == AtOnboardingResponseStatus.authSuccess) {
      if (context.mounted) {
        context.goNamed('HomePage');
      }
    }
  }

  Future<void> reset() async {
    String? atSign = await KeyChainManager.getInstance().getAtSign();
    bool isAtSignDeleted =
        await KeyChainManager.getInstance().deleteAtSignFromKeychain(atSign!);
    print('isAtSignDeleted: $isAtSignDeleted');
  }

  Future<AtClientPreference> getAtClientPreferences() async {
    var directory = await getApplicationSupportDirectory();
    return AtClientPreference()
      ..rootDomain = LandingPage.rootDomain
      ..namespace = 'enroll'
      ..hiveStoragePath = directory.path
      ..commitLogPath = directory.path
      ..isLocalStoreRequired = true
      ..enableEnrollmentDuringOnboard = true;
  }
}
