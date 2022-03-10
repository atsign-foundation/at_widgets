import 'package:at_backupkey_flutter/widgets/backup_key_widget.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:at_onboarding_flutter/utils/custom_textstyles.dart';
import 'package:at_onboarding_flutter/utils/images.dart';
import 'package:at_onboarding_flutter/utils/strings.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_button.dart';
import 'package:at_onboarding_flutter/widgets/custom_appbar.dart';
import 'package:at_onboarding_flutter/widgets/custom_button.dart';
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
  _AtOnboardingBackupScreenState createState() =>
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
      return const Text('An @sign is required.');
    }
    return Scaffold(
      backgroundColor: ColorConstants.light,
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(Strings.saveBackupKeyTitle),
        leading: Container(),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AtOnboardingDimens.paddingNormal),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 10),
            const Text(
              Strings.saveImportantTitle,
              style: TextStyle(
                  fontSize: AtOnboardingDimens.fontLarge,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              Strings.saveBackupDescription,
              style: TextStyle(fontSize: AtOnboardingDimens.fontNormal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Center(
                child: Image.asset(
              Images.backupZip,
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.6,
              fit: BoxFit.fill,
              package: AppConstants.package,
            )),
            const SizedBox(height: 40),
            Container(
              constraints: const BoxConstraints(
                maxWidth: 400,
              ),
              child: AtOnboardingPrimaryButton(
                height: 48,
                borderRadius: 24,
                child: const Text(Strings.saveButtonTitle),
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
                child: const Text(Strings.continueButtonTitle),
                onPressed: Navigator.of(context).pop,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
