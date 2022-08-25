import 'dart:io';

import 'package:at_backupkey_flutter/widgets/backup_key_widget.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_app_constants.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_strings.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_button.dart';
import 'package:flutter/material.dart';

class AtOnboardingBackupScreen extends StatefulWidget {
  const AtOnboardingBackupScreen({Key? key}) : super(key: key);

  static Future<void> push({
    required BuildContext context,
  }) {
    return Navigator.push(context,
        MaterialPageRoute(builder: (_) => const AtOnboardingBackupScreen()));
  }

  @override
  State<AtOnboardingBackupScreen> createState() =>
      _AtOnboardingBackupScreenState();
}

class _AtOnboardingBackupScreenState extends State<AtOnboardingBackupScreen> {
  String? atsign;

  @override
  void initState() {
    super.initState();
    atsign = OnboardingService.getInstance().currentAtsign;
  }

  GlobalKey globalKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (atsign == null) {
      return const Text('An atSign is required.');
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          AtOnboardingStrings.saveBackupKeyTitle,
          style: TextStyle(color: Colors.black),
        ),
        leading: Container(),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AtOnboardingDimens.paddingNormal),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 10),
            const Text(
              AtOnboardingStrings.saveImportantTitle,
              style: TextStyle(
                  fontSize: AtOnboardingDimens.fontLarge,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              AtOnboardingStrings.saveBackupDescription,
              style: TextStyle(fontSize: AtOnboardingDimens.fontNormal),
              textAlign: TextAlign.center,
            ),
            Expanded(flex: 1, child: Container()),
            Center(
                child: Image.asset(
              AtOnboardingStrings.backupZip,
              height: Platform.isAndroid || Platform.isIOS
                  ? MediaQuery.of(context).size.height * 0.3
                  : 250,
              width: Platform.isAndroid || Platform.isIOS
                  ? MediaQuery.of(context).size.height * 0.3
                  : 250,
              fit: BoxFit.fill,
              package: AtOnboardingConstants.package,
            )),
            Expanded(flex: 1, child: Container()),
            Container(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: AtOnboardingPrimaryButton(
                height: 48,
                borderRadius: 24,
                child: const Text(AtOnboardingStrings.saveButtonTitle),
                onPressed: () {
                  BackupKeyWidget(atsign: atsign ?? '')
                      .showBackupDialog(context);
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: AtOnboardingSecondaryButton(
                height: 48,
                borderRadius: 24,
                onPressed: Navigator.of(context).pop,
                child: const Text(AtOnboardingStrings.continueButtonTitle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
