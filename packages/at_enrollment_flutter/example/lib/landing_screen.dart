import 'dart:io';

import 'package:at_enrollment_flutter/at_enrollment_flutter.dart';
import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_response_status.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path_provider/path_provider.dart';

class LandingPage extends StatefulWidget {
  static const String rootDomain = 'vip.ve.atsign.zone';

  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    initEnrollmentPackage();
    super.initState();
  }

  initEnrollmentPackage() async {
    AtEnrollment.init(await getAtClientPreferences());
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
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ThemeData.light()
            .colorScheme
            .copyWith(
              primary: const Color(0xFFf4533d),
            )
            .copyWith(surface: Colors.white),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Poppins',
        package: 'at_enrollment_flutter',
      ).copyWith(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFf4533d),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ThemeData.light()
            .colorScheme
            .copyWith(
              primary: const Color(0xFFf4533d),
            )
            .copyWith(surface: Colors.white),
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
                    var res =
                        await AtEnrollment.submitEnrollmentRequest(context);

                    //TODO: moving to onboarding screen upon enrollment approval
                    if (res != null &&
                        res.enrollmentStatus == EnrollmentStatus.approved) {
                      AtOnboardingResponseStatus atOnboardingResponse =
                          await EnrollmentServiceWrapper.getInstance()
                              .authenticateEnrollment();
                      if (atOnboardingResponse ==
                          AtOnboardingResponseStatus.authSuccess) {
                        AtEnrollment.manageEnrollmentRequest(context);
                      }
                    }
                  },
                  child: const Text('Enroll'),
                ),
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
      if (context.mounted) {
        AtEnrollment.manageEnrollmentRequest(context);
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
    Directory? downloadDirectory;
    if (Platform.isIOS || Platform.isWindows || Platform.isLinux) {
      downloadDirectory =
          await path_provider.getApplicationDocumentsDirectory();
    } else {
      downloadDirectory = await path_provider.getExternalStorageDirectory();
    }
    return AtClientPreference()
      ..rootDomain = LandingPage.rootDomain
      ..namespace = 'enroll'
      ..hiveStoragePath = directory.path
      ..downloadPath = downloadDirectory?.path
      ..commitLogPath = directory.path
      ..isLocalStoreRequired = true;
  }
}
