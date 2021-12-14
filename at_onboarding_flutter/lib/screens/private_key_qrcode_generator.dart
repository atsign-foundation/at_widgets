import 'dart:ui';
import 'package:at_backupkey_flutter/widgets/backup_key_widget.dart';
import 'package:at_onboarding_flutter/services/onboarding_service.dart';
import 'package:at_onboarding_flutter/services/size_config.dart';
import 'package:at_onboarding_flutter/utils/app_constants.dart';
import 'package:at_onboarding_flutter/utils/color_constants.dart';
import 'package:at_onboarding_flutter/utils/custom_textstyles.dart';
import 'package:at_onboarding_flutter/utils/images.dart';
import 'package:at_onboarding_flutter/utils/strings.dart';
import 'package:at_onboarding_flutter/widgets/custom_appbar.dart';
import 'package:at_onboarding_flutter/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PrivateKeyQRCodeGenScreen extends StatefulWidget {
  PrivateKeyQRCodeGenScreen({Key? key}) : super(key: key);

  @override
  _PrivateKeyQRCodeGenScreenState createState() =>
      _PrivateKeyQRCodeGenScreenState();
}

class _PrivateKeyQRCodeGenScreenState extends State<PrivateKeyQRCodeGenScreen> {
  String? atsign;
  final OnboardingService _onboardingService = OnboardingService.getInstance();
  @override
  void initState() {
    super.initState();
    atsign = OnboardingService.getInstance().currentAtsign;
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (atsign == null) {
      return const Text('An @sign is required.');
    }
    return Opacity(
      opacity: _loading ? 0.2 : 1,
      child: AbsorbPointer(
        absorbing: _loading,
        child: Scaffold(
          backgroundColor: ColorConstants.light,
          key: _scaffoldKey,
          appBar: CustomAppBar(
            title: Strings.saveBackupKeyTitle,
            showBackButton: false,
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0.toFont),
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 10.toHeight,
                ),
                Text(
                  Strings.saveImportantTitle,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.fontBold18primary,
                ),
                SizedBox(
                  height: 10.toHeight,
                ),
                Text(
                  Strings.saveBackupDescription,
                  textAlign: TextAlign.center,
                  style: CustomTextStyles.fontR16primary,
                ),
                SizedBox(
                  height: 40.toHeight,
                ),
                Center(
                    child: Image.asset(
                  Images.backupZip,
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 0.6,
                  fit: BoxFit.fill,
                  package: AppConstants.package,
                )),
                SizedBox(
                  height: 30.toHeight,
                ),
                BackupKeyWidget(
                  atClientService: OnboardingService.getInstance()
                      .atClientServiceMap[atsign],
                  isButton: true,
                  buttonWidth: 230.toWidth,
                  atsign: atsign!,
                  buttonColor: ColorConstants.appColor,
                  buttonText: Strings.saveButtonTitle,
                ),
                SizedBox(
                  height: 10.toHeight,
                ),
                CustomButton(
                  width: 230.toWidth,
                  isInverted: true,
                  buttonText: Strings.coninueButtonTitle,
                  onPressed: () async {
                    if (OnboardingService.getInstance().fistTimeAuthScreen !=
                        null) {
                      _onboardingService.onboardFunc(
                          _onboardingService.atClientServiceMap,
                          _onboardingService.currentAtsign);
                      await Navigator.pushReplacement(
                          context,
                          MaterialPageRoute<OnboardingService>(
                              builder: (BuildContext context) =>
                                  OnboardingService.getInstance()
                                      .fistTimeAuthScreen!));
                    } else if (OnboardingService.getInstance().nextScreen !=
                        null) {
                      _onboardingService.onboardFunc(
                          _onboardingService.atClientServiceMap,
                          _onboardingService.currentAtsign);
                      await Navigator.pushReplacement(
                          context,
                          MaterialPageRoute<OnboardingService>(
                              builder: (BuildContext context) =>
                                  OnboardingService.getInstance().nextScreen!));
                    } else {
                      Navigator.pop(context);
                      _onboardingService.onboardFunc(
                          _onboardingService.atClientServiceMap,
                          _onboardingService.currentAtsign);
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
