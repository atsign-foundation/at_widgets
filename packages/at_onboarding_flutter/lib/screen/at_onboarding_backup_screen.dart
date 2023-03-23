import 'dart:io';

import 'package:at_onboarding_flutter/at_onboarding_flutter.dart';
import 'package:at_onboarding_flutter/services/at_onboarding_backup_service.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_app_constants.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_dimens.dart';
import 'package:at_onboarding_flutter/utils/at_onboarding_strings.dart';
import 'package:at_onboarding_flutter/widgets/at_onboarding_button.dart';
import 'package:flutter/material.dart';

class AtOnboardingBackupScreen extends StatefulWidget {
  final AtOnboardingConfig config;

  const AtOnboardingBackupScreen({
    Key? key,
    required this.config,
  }) : super(key: key);

  static Future<void> push({
    required BuildContext context,
    required AtOnboardingConfig config,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AtOnboardingBackupScreen(
          config: config,
        ),
      ),
    );
  }

  @override
  State<AtOnboardingBackupScreen> createState() =>
      _AtOnboardingBackupScreenState();
}

class _AtOnboardingBackupScreenState extends State<AtOnboardingBackupScreen> {
  String? atsign;
  bool isSaveAtSign = false;

  @override
  void initState() {
    super.initState();
    atsign = OnboardingService.getInstance().currentAtsign;

    AtOnboardingBackupService.instance.setRemindBackup(remind: true);
    AtOnboardingBackupService.instance
        .setBackupOpenedTime(dateTime: DateTime.now());
  }

  GlobalKey globalKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(
      primaryColor: widget.config.theme?.primaryColor,
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: widget.config.theme?.primaryColor,
          ),
    );

    if (atsign == null) {
      return const Text('An atSign is required.');
    }

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text(
            AtOnboardingStrings.saveBackupKeyTitle,
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
                  color: Platform.isIOS || Platform.isAndroid
                      ? Theme.of(context).brightness == Brightness.light
                          ? Colors.black
                          : Colors.white
                      : null,
                ),
              ),
              Expanded(flex: 1, child: Container()),
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ),
                child: AtOnboardingPrimaryButton(
                  height: 48,
                  borderRadius: 24,
                  child: Text(
                    AtOnboardingStrings.saveButtonTitle,
                    style: TextStyle(
                      color: Platform.isIOS || Platform.isAndroid
                          ? Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Colors.black
                          : null,
                    ),
                  ),
                  onPressed: () async {
                    AtOnboardingBackupService.instance
                        .setRemindBackup(remind: false);
                    final widget = BackupKeyWidget(atsign: atsign ?? '');
                    final result = await widget.showBackupDialog(context);

                    if (result == true) {
                      setState(() {
                        isSaveAtSign = true;
                      });
                    }
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
                  onPressed: _handleRemindLatter,
                  child: Text(
                    isSaveAtSign
                        ? AtOnboardingStrings.continueButtonTitle
                        : AtOnboardingStrings.onboardingRemindLatter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRemindLatter() {
    Navigator.pop(context);
    if (!isSaveAtSign) {
      AtOnboardingBackupService.instance.setRemindBackup(remind: true);
      AtOnboardingBackupService.instance.setBackupOpenedTime(
        dateTime: DateTime.now(),
      );
    }
  }
}
